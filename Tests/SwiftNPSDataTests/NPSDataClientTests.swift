import Foundation
import HTTPCore
import HTTPTesting
import HTTPTypes
import SwiftNPSData
import SwiftNPSDataModels
import SwiftNPSDataTestSupport
import Testing

@Suite("NPS client", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct NPSDataClientTests {
  @Test("All entry points send equivalent authenticated requests")
  func allEntryPointsSendEquivalentAuthenticatedRequests() async throws {
    let recording = try Fixture.parksAcadia.data()
    let transport = MockTransport(
      results: Array(repeating: .success(.ok(json: recording)), count: 3))
    let client = try makeClient(transport)
    let code = try ParkCode("acad")
    let everyday = try await client.parks(parkCode: code)
    let request = ParkRequest.parks(parkCode: code)
    let reusable = try await client.value(for: request)
    let endpoint = try await client.send(.parks(parkCode: code))
    #expect(everyday == reusable)
    #expect(reusable == endpoint)
    #expect(everyday.data.first?.fullName == "Acadia National Park")
    #expect(transport.requests.count == 3)
    let field = try #require(HTTPField.Name("X-Api-Key"))
    for call in transport.requests {
      #expect(call.request.method == .get)
      #expect(call.request.scheme == "https")
      #expect(call.request.authority == "developer.nps.gov")
      #expect(call.request.path == "/api/v1/parks?parkCode=acad&limit=1&start=0")
      #expect(call.request.headerFields[.accept] == "application/json")
      #expect(call.request.headerFields[field] == "private-test-key")
      #expect(call.request.path?.contains("private-test-key") == false)
      #expect(call.body == .none)
    }
  }

  @Test("Cancellation before any entry point sends nothing", arguments: [0, 1, 2])
  func cancellationBeforeAnyEntryPointSendsNothing(_ entry: Int) async throws {
    let transport = MockTransport()
    let client = try makeClient(transport)
    let code = try ParkCode("acad")
    await withTaskGroup(of: Void.self) { group in
      group.cancelAll()
      group.addTask {
        do throws(NPSDataError) {
          switch entry {
          case 0: _ = try await client.parks(parkCode: code)
          case 1: _ = try await client.value(for: .parks(parkCode: code))
          default: _ = try await client.send(.parks(parkCode: code))
          }
          Issue.record("Cancellation must fail the lookup.")
        } catch {
          guard case .transport(.cancelled) = error else {
            Issue.record("Expected typed cancellation, received \(error).")
            return
          }
        }
      }
    }
    #expect(transport.requests.isEmpty)
  }

  @Test("Configuration descriptions redact the credential")
  func configurationDescriptionsRedactTheCredential() throws {
    let configuration = try NPSDataConfiguration(apiKey: "private-test-key")
    #expect(!String(describing: configuration).contains("private-test-key"))
    #expect(!String(reflecting: configuration).contains("private-test-key"))
  }

  @Test("Consumer defined responses execute through reusable requests")
  func consumerDefinedResponsesExecuteThroughReusableRequests() async throws {
    let transport = MockTransport(results: [.success(.ok(json: try Fixture.parksAcadia.data()))])
    let client = try makeClient(transport)
    let request = ParkRequest.nameLookup
    let response = try await client.value(for: request)
    let _: NamesResponse = response
    #expect(response.data.first?.fullName == "Acadia National Park")
    #expect(transport.requests.count == 1)
  }

  @Test("Empty results preserve provider metadata")
  func emptyResultsPreserveProviderMetadata() async throws {
    let transport = MockTransport(results: [.success(.ok(json: try Fixture.parksEmpty.data()))])
    let page = try await makeClient(transport).parks(parkCode: ParkCode("zzzz"))
    #expect(page.data.isEmpty)
    #expect(page.total == "0")
    #expect(page.limit == "1")
    #expect(page.start == "0")
    #expect(transport.requests.count == 1)
  }

  @Test("Gateway failures retain the body status and headers")
  func gatewayFailuresRetainTheBodyStatusAndHeaders() async throws {
    let body = try Fixture.apiKeyMissing.data()
    let transport = MockTransport(results: [
      .success(Response(body: body, headers: [.retryAfter: "60"], status: .forbidden))
    ])
    do {
      _ = try await makeClient(transport).parks(parkCode: ParkCode("acad"))
      Issue.record("A gateway failure must be thrown.")
    } catch let error as NPSDataError {
      guard case .service(let response, let failure) = error,
        case .httpStatus(let received, let code, let headers) = failure
      else {
        Issue.record("Expected a typed gateway response.")
        return
      }
      #expect(response.error.code == "API_KEY_MISSING")
      #expect(received == body)
      #expect(code == 403)
      #expect(headers[.retryAfter] == "60")
    }
    #expect(transport.requests.count == 1)
  }

  @Test(
    "Invalid API keys fail without retaining the rejected credential",
    arguments: [
      "", " ", " key", "key ", "key\nvalue", "key\rvalue", "key\tvalue", "clé",
    ])
  func invalidAPIKeysFailWithoutRetainingTheRejectedCredential(_ key: String) {
    do {
      _ = try NPSDataConfiguration(apiKey: key)
      Issue.record("Invalid configuration must fail.")
    } catch {
      guard case .invalidAPIKey = error else {
        Issue.record("Expected invalidAPIKey.")
        return
      }
    }
  }

  @Test("Malformed successful bodies produce typed decoding failures")
  func malformedSuccessfulBodiesProduceTypedDecodingFailures() async throws {
    let transport = MockTransport(results: [.success(.ok(json: Data("not JSON".utf8)))])
    do {
      _ = try await makeClient(transport).parks(parkCode: ParkCode("acad"))
      Issue.record("An invalid response must fail decoding.")
    } catch let error as NPSDataError {
      guard case .transport(.decode) = error else {
        Issue.record("Expected a typed decoding failure.")
        return
      }
    }
  }

  @Test("Rate limiting preserves unknown error codes without retrying")
  func rateLimitingPreservesUnknownErrorCodesWithoutRetrying() async throws {
    // A constructed response exercises future gateway codes without exhausting a real API key.
    let body = Data(#"{"error":{"code":"FUTURE_LIMIT","message":"Wait before retrying."}}"#.utf8)
    let transport = MockTransport(results: [
      .success(Response(body: body, headers: [.retryAfter: "120"], status: .tooManyRequests))
    ])
    do {
      _ = try await makeClient(transport).parks(parkCode: ParkCode("acad"))
      Issue.record("Rate limiting must be returned to the caller.")
    } catch let error as NPSDataError {
      guard case .service(let response, let failure) = error,
        case .httpStatus(_, let code, let headers) = failure
      else {
        Issue.record("Expected the gateway error and HTTP metadata.")
        return
      }
      #expect(response.error.code == "FUTURE_LIMIT")
      #expect(code == 429)
      #expect(headers[.retryAfter] == "120")
    }
    #expect(transport.requests.count == 1)
  }

  @Test(
    "Redirect responses are never followed with credentials",
    arguments: [
      "https://example.com/collect", "https://developer.nps.gov/api/v1/parks", "/api/v1/parks",
    ])
  func redirectResponsesAreNeverFollowedWithCredentials(_ location: String) async throws {
    let transport = MockTransport(results: [
      .success(Response(headers: [.location: location], status: .found)),
      .success(.ok(json: try Fixture.parksAcadia.data())),
    ])
    do {
      _ = try await makeClient(transport).parks(parkCode: ParkCode("acad"))
      Issue.record("A redirect must be returned as a failure.")
    } catch let error as NPSDataError {
      guard case .transport(.httpStatus(_, let code, _)) = error else {
        Issue.record("Expected an HTTP redirect failure.")
        return
      }
      #expect(code == 302)
    }
    #expect(transport.requests.count == 1)
  }

  @Test("Transport cancellation remains typed cancellation")
  func transportCancellationRemainsTypedCancellation() async throws {
    let transport = MockTransport(results: [.failure(.cancelled)])
    do {
      _ = try await makeClient(transport).parks(parkCode: ParkCode("acad"))
      Issue.record("Transport cancellation must fail.")
    } catch let error as NPSDataError {
      guard case .transport(.cancelled) = error else {
        Issue.record("Expected cancellation.")
        return
      }
    }
  }

  @Test("Transport failures preserve their category")
  func transportFailuresPreserveTheirCategory() async throws {
    let transport = MockTransport(results: [.failure(.transport(kind: .timedOut, underlying: nil))])
    do {
      _ = try await makeClient(transport).parks(parkCode: ParkCode("acad"))
      Issue.record("The failed transport must fail the lookup.")
    } catch let error as NPSDataError {
      guard case .transport(let failure) = error else {
        Issue.record("Expected a transport failure.")
        return
      }
      #expect(failure.isTimeout)
    }
    #expect(transport.requests.count == 1)
  }

  @Test("Unrecognized HTTP bodies remain inspectable", arguments: [401, 403, 404, 429, 500, 503])
  func unrecognizedHTTPBodiesRemainInspectable(_ status: Int) async throws {
    let body = Data("<html>Unavailable</html>".utf8)
    let transport = MockTransport(results: [
      .success(Response(body: body, status: .init(code: status)))
    ])
    do {
      _ = try await makeClient(transport).parks(parkCode: ParkCode("acad"))
      Issue.record("The HTTP failure must be thrown.")
    } catch let error as NPSDataError {
      guard case .transport(.httpStatus(let received, let code, _)) = error else {
        Issue.record("Expected the original HTTP failure.")
        return
      }
      #expect(code == status)
      #expect(received == body)
    }
    #expect(transport.requests.count == 1)
  }

  private func makeClient(_ transport: MockTransport) throws(NPSDataError) -> NPSDataClient {
    NPSDataClient(
      configuration: try NPSDataConfiguration(apiKey: "private-test-key"), transport: transport)
  }
}

private struct NamesResponse: Decodable, Sendable {
  struct Name: Decodable, Sendable {
    let fullName: String
  }

  let data: [Name]
}

extension ParkRequest where Response == NamesResponse {
  fileprivate static var nameLookup: Self {
    guard let endpoint = Endpoint<NamesResponse>(path: "/parks?parkCode=acad&limit=1&start=0")
    else {
      preconditionFailure("The fixed Acadia path is valid.")
    }
    return Self(endpoint: endpoint)
  }
}
