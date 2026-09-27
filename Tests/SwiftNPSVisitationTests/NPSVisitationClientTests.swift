import Foundation
import HTTPCore
import HTTPTesting
import HTTPTypes
import SwiftNPSDataTestSupport
import SwiftNPSVisitation
import SwiftNPSVisitationModels
import Testing

@Suite("Visitation client", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct NPSVisitationClientTests {
  @Test("Cancellation before sending produces a typed failure without transport")
  func cancellationBeforeSendingProducesATypedFailureWithoutTransport() async throws {
    let transport = MockTransport()
    let client = NPSVisitationClient(transport: transport)
    await withTaskGroup(of: Void.self) { group in
      group.cancelAll()
      group.addTask {
        do throws(NPSVisitationError) {
          _ = try await client.nationalVisitation(year: 2025)
          Issue.record("Cancelled work must fail.")
        } catch {
          guard case .transport(.cancelled) = error else {
            Issue.record("Expected cancellation.")
            return
          }
        }
      }
    }
    #expect(transport.requests.isEmpty)
  }

  @Test("Cancellation during a suspended response produces a typed failure")
  func cancellationDuringASuspendedResponseProducesATypedFailure() async throws {
    let body = AsyncStream<Data>.makeStream()
    let entered = AsyncStream<Void>.makeStream()
    let transport = MockTransport()
    transport.setHandler(forPath: "/v3/rest/stats/total/2025") { _ in
      .success(
        MockTransport.Answer(
          body: {
            entered.continuation.yield(())
            return StreamedBody(body.stream)
          }, headers: [.contentType: "application/json"]))
    }
    let task = Task { () -> Bool in
      do throws(NPSVisitationError) {
        _ = try await NPSVisitationClient(transport: transport).nationalVisitation(year: 2025)
        return false
      } catch {
        if case .transport(.cancelled) = error { return true }
        return false
      }
    }
    var iterator = entered.stream.makeAsyncIterator()
    _ = await iterator.next()
    task.cancel()
    body.continuation.yield(Data("[]".utf8))
    body.continuation.finish()
    entered.continuation.finish()
    #expect(await task.value)
    #expect(transport.requests.count == 1)
  }

  @Test("Consumer responses and stored requests preserve concrete inference")
  func consumerResponsesAndStoredRequestsPreserveConcreteInference() async throws {
    struct Consumer: Decodable, Sendable { let count: Int }
    let endpoint = try #require(VisitationEndpoint<Consumer>(path: "/custom"))
    let request = NPSVisitationRequest(endpoint: endpoint)
    let transport = MockTransport(results: [.success(.ok(json: Data(#"{"count":7}"#.utf8)))])
    let value = try await NPSVisitationClient(transport: transport).value(for: request)
    #expect(value.count == 7)
    #expect(request.endpoint.path == "/custom")
  }

  @Test("Failures preserve HTTP bytes headers decoding and transport errors")
  func failuresPreserveHTTPBytesHeadersDecodingAndTransportErrors() async throws {
    let body = try IRMAFixture.visitationHTTPFailure.data()
    let transport = MockTransport(results: [
      .success(
        Response(body: body, headers: [.contentType: "text/html"], status: .internalServerError)),
      .success(.ok(json: Data("invalid JSON".utf8))),
      .failure(.cancelled),
    ])
    let client = NPSVisitationClient(transport: transport)
    do throws(NPSVisitationError) {
      _ = try await client.nationalVisitation(year: 2025)
      Issue.record("HTTP failure must throw.")
    } catch {
      guard case .transport(.httpStatus(let received, let status, let headers)) = error else {
        Issue.record("Expected HTTP failure."); return
      }
      #expect(received == body)
      #expect(status == 500)
      #expect(headers[.contentType] == "text/html")
    }
    do throws(NPSVisitationError) {
      _ = try await client.nationalVisitation(year: 2025)
      Issue.record("Malformed JSON must throw.")
    } catch {
      guard case .transport(.decode) = error else {
        Issue.record("Expected decoding failure."); return
      }
    }
    do throws(NPSVisitationError) {
      _ = try await client.nationalVisitation(year: 2025)
      Issue.record("Transport cancellation must throw.")
    } catch {
      guard case .transport(.cancelled) = error else {
        Issue.record("Expected cancellation."); return
      }
    }
  }

  @Test("Invalid national years fail before transport")
  func invalidNationalYearsFailBeforeTransport() async {
    let transport = MockTransport()
    do throws(NPSVisitationError) {
      _ = try await NPSVisitationClient(transport: transport).nationalVisitation(year: 0)
      Issue.record("Year zero must fail.")
    } catch {
      guard case .invalidYear = error else { Issue.record("Expected invalid year."); return }
    }
    #expect(transport.requests.isEmpty)
  }

  @Test("National entry points retain monthly null identifiers")
  func nationalEntryPointsRetainMonthlyNullIdentifiers() async throws {
    let body = try IRMAFixture.visitationNationalMonths.data()
    let transport = MockTransport(results: Array(repeating: .success(.ok(json: body)), count: 3))
    let client = NPSVisitationClient(transport: transport)
    let request = try NPSVisitationRequest.nationalVisitation(year: 2025)
    let a = try await client.nationalVisitation(year: 2025)
    let b = try await client.value(for: request)
    let c = try await client.send(.nationalVisitation(year: 2025))
    #expect(a == b && b == c)
    #expect(a.count == 12)
    #expect(a.allSatisfy { $0.unitCode == nil && $0.unitName == nil })
    #expect(
      transport.requests.allSatisfy { $0.request.path == "/v3/rest/stats/total/2025?format=json" })
  }

  @Test(
    "Redirects never escape the service",
    arguments: [
      "https://example.com/collect", "https://irmaservices.nps.gov/Unit/v2/api/ACAD",
    ])
  func redirectsNeverEscapeTheService(_ location: String) async throws {
    let transport = MockTransport(results: [
      .success(Response(body: Data(), headers: [.location: location], status: .found))
    ])
    do throws(NPSVisitationError) {
      _ = try await NPSVisitationClient(transport: transport).nationalVisitation(year: 2025)
      Issue.record("Redirect must fail.")
    } catch {
      guard case .transport = error else { Issue.record("Expected transport failure."); return }
    }
    #expect(transport.requests.count == 1)
  }

  @Test("Visitation entry points send the same key free request")
  func visitationEntryPointsSendTheSameKeyFreeRequest() async throws {
    let body = try IRMAFixture.visitationAcadiaMonths.data()
    let transport = MockTransport(results: Array(repeating: .success(.ok(json: body)), count: 3))
    let client = NPSVisitationClient(transport: transport)
    let query = try VisitationQuery(
      end: VisitationMonth(year: 2025, month: 2),
      start: VisitationMonth(year: 2025, month: 1), unitCodes: ["ACAD"])
    let a = try await client.visitation(query: query)
    let request = NPSVisitationRequest.visitation(query: query)
    let b = try await client.value(for: request)
    let c = try await client.send(.visitation(query: query))
    #expect(a == b && b == c)
    #expect(a.count == 2)
    #expect(a.first?.recreationVisitors == 13183)
    let key = try #require(HTTPField.Name("X-Api-Key"))
    for call in transport.requests {
      #expect(call.request.authority == "irmaservices.nps.gov")
      #expect(
        call.request.path
          == "/v3/rest/stats/visitation?endMonth=2&endYear=2025&format=json&startMonth=1&startYear=2025&unitCodes=ACAD"
      )
      #expect(call.request.headerFields[key] == nil)
      #expect(call.request.headerFields[.accept] == "application/json")
    }
  }
}
