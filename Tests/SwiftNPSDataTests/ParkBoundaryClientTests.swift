import Foundation
import HTTPCore
import HTTPTesting
import HTTPTypes
import SwiftNPSData
import SwiftNPSDataModels
import SwiftNPSDataTestSupport
import Testing

@Suite("Park boundaries client", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct ParkBoundaryClientTests {
  @Test("A park boundary lookup sends one authenticated request for the park")
  func aParkBoundaryLookupSendsOneAuthenticatedRequestForThePark() async throws {
    let body = try Fixture.parkBoundaryYellowstone.data()
    let transport = MockTransport(results: [.success(.ok(json: body))])
    let boundary = try await makeClient(transport).parkBoundary(parkCode: ParkCode("yell"))
    #expect(boundary == (try JSONDecoder().decode(ParkBoundary.self, from: body)))
    #expect(boundary.features?.first?.geometry?.polygon?.first?.count == 1494)
    let call = try #require(transport.requests.first)
    let field = try #require(HTTPField.Name("X-Api-Key"))
    #expect(transport.requests.count == 1)
    #expect(call.request.method == .get)
    #expect(call.request.authority == "developer.nps.gov")
    #expect(call.request.path == "/api/v1/mapdata/parkboundaries/yell")
    #expect(call.request.headerFields[.accept] == "application/json")
    #expect(call.request.headerFields[field] == "private-test-key")
    #expect(call.body == .none)
  }

  @Test("Cancellation before any park boundary entry point sends nothing", arguments: [0, 1, 2])
  func cancellationBeforeAnyParkBoundaryEntryPointSendsNothing(_ entry: Int) async throws {
    let transport = MockTransport()
    let client = try makeClient(transport)
    let code = try ParkCode("drto")
    await withTaskGroup(of: Void.self) { group in
      group.cancelAll()
      group.addTask {
        do throws(NPSDataError) {
          switch entry {
          case 0: _ = try await client.parkBoundary(parkCode: code)
          case 1: _ = try await client.value(for: .parkBoundary(parkCode: code))
          default: _ = try await client.send(.parkBoundary(parkCode: code))
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

  @Test("Every park boundary entry point returns the same boundary")
  func everyParkBoundaryEntryPointReturnsTheSameBoundary() async throws {
    let body = try Fixture.parkBoundaryDryTortugas.data()
    let transport = MockTransport(results: Array(repeating: .success(.ok(json: body)), count: 3))
    let client = try makeClient(transport)
    let code = try ParkCode("drto")
    let everyday = try await client.parkBoundary(parkCode: code)
    let reusable = try await client.value(for: .parkBoundary(parkCode: code))
    let endpoint = try await client.send(.parkBoundary(parkCode: code))
    #expect(everyday == reusable)
    #expect(reusable == endpoint)
    #expect(everyday.features?.first?.geometry?.multiPolygon?.count == 2)
    #expect(
      transport.requests.map(\.request.path)
        == Array(repeating: "/api/v1/mapdata/parkboundaries/drto", count: 3))
  }

  @Test("Park boundary failures map to typed errors")
  func parkBoundaryFailuresMapToTypedErrors() async throws {
    let gateway = try Fixture.apiKeyMissing.data()
    let unknown = try Fixture.parkBoundaryUnknown.data()
    let transport = MockTransport(results: [
      .success(Response(body: gateway, headers: [:], status: .forbidden)),
      .success(Response(body: unknown, headers: [:], status: .notFound)),
      .success(.ok(json: Data("not JSON".utf8))),
    ])
    let client = try makeClient(transport)
    let code = try ParkCode("zzzz")
    do {
      _ = try await client.parkBoundary(parkCode: code)
      Issue.record("A gateway failure must be thrown.")
    } catch {
      guard case .service(let response, _) = error else {
        Issue.record("Expected a typed gateway response, received \(error).")
        return
      }
      #expect(response.error.code == "API_KEY_MISSING")
    }
    do {
      _ = try await client.parkBoundary(parkCode: code)
      Issue.record("An unknown park code must be thrown.")
    } catch {
      guard case .transport(.httpStatus(let received, let status, _)) = error else {
        Issue.record("Expected the original HTTP failure, received \(error).")
        return
      }
      #expect(status == 404)
      #expect(received == unknown)
    }
    do {
      _ = try await client.parkBoundary(parkCode: code)
      Issue.record("An invalid response must fail decoding.")
    } catch {
      guard case .transport(.decode) = error else {
        Issue.record("Expected a typed decoding failure, received \(error).")
        return
      }
    }
    #expect(
      transport.requests.map(\.request.path)
        == Array(repeating: "/api/v1/mapdata/parkboundaries/zzzz", count: 3))
  }

  private func makeClient(_ transport: MockTransport) throws(NPSDataError) -> NPSDataClient {
    NPSDataClient(
      configuration: try NPSDataConfiguration(apiKey: "private-test-key"), transport: transport)
  }
}
