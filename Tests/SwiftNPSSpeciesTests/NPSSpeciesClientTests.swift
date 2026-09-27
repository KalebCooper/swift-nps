import Foundation
import HTTPCore
import HTTPTesting
import HTTPTypes
import SwiftNPSDataTestSupport
import SwiftNPSSpecies
import SwiftNPSSpeciesModels
import Testing

@Suite("Species client", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct NPSSpeciesClientTests {
  @Test("Cancellation before send performs no transport")
  func cancellationBeforeSendPerformsNoTransport() async throws {
    let query = try SpeciesQuery(unitCode: "ACAD")
    let transport = MockTransport()
    await withTaskGroup(of: Void.self) { group in
      group.cancelAll()
      group.addTask {
        do throws(NPSSpeciesError) {
          _ = try await NPSSpeciesClient(transport: transport).species(query: query)
          Issue.record("Cancelled work must fail.")
        } catch {
          guard case .transport(.cancelled) = error else {
            Issue.record("Expected cancellation."); return
          }
        }
      }
    }
    #expect(transport.requests.isEmpty)
  }

  @Test("Cancellation during a suspended response produces a typed failure")
  func cancellationDuringASuspendedResponseProducesATypedFailure() async throws {
    let query = try SpeciesQuery(unitCode: "ACAD")
    let body = AsyncStream<Data>.makeStream()
    let entered = AsyncStream<Void>.makeStream()
    let transport = MockTransport()
    transport.setHandler(forPath: "/NPSpecies/v3/rest/fulllist/ACAD/") { _ in
      .success(
        MockTransport.Answer(
          body: {
            entered.continuation.yield(())
            return StreamedBody(body.stream)
          }, headers: [.contentType: "application/json"]))
    }
    let task = Task { () -> Bool in
      do throws(NPSSpeciesError) {
        _ = try await NPSSpeciesClient(transport: transport).species(query: query)
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

  @Test("Consumer responses and stored requests preserve inference")
  func consumerResponsesAndStoredRequestsPreserveInference() async throws {
    struct Consumer: Decodable, Sendable { let count: Int }
    let endpoint = try #require(SpeciesEndpoint<Consumer>(path: "/custom"))
    let request = NPSSpeciesRequest(endpoint: endpoint)
    let transport = MockTransport(results: [.success(.ok(json: Data(#"{"count":7}"#.utf8)))])
    #expect(try await NPSSpeciesClient(transport: transport).value(for: request).count == 7)
  }

  @Test(
    "Each list uses all three equivalent entry points",
    arguments: ["checklist", "detaillist", "fulllist"])
  func eachListUsesAllThreeEquivalentEntryPoints(_ route: String) async throws {
    let fixture: IRMAFixture =
      route == "checklist"
      ? .speciesAcadiaChecklist
      : (route == "detaillist" ? .speciesAcadiaDetails : .speciesAcadiaFull)
    let transport = MockTransport(
      results: Array(repeating: .success(.ok(json: try fixture.data())), count: 3))
    let client = NPSSpeciesClient(transport: transport)
    let query = try SpeciesQuery(categories: ["birds"], unitCode: "ACAD")
    switch route {
    case "checklist":
      let a = try await client.speciesChecklist(query: query)
      let request = NPSSpeciesRequest.speciesChecklist(query: query)
      let b = try await client.value(for: request)
      let c = try await client.send(.speciesChecklist(query: query))
      #expect(a == b && b == c && a.count == 215)
    case "detaillist":
      let a = try await client.speciesDetails(query: query)
      let request = NPSSpeciesRequest.speciesDetails(query: query)
      let b = try await client.value(for: request)
      let c = try await client.send(.speciesDetails(query: query))
      #expect(a == b && b == c && a.count == 364)
    default:
      let a = try await client.species(query: query)
      let request = NPSSpeciesRequest.species(query: query)
      let b = try await client.value(for: request)
      let c = try await client.send(.species(query: query))
      #expect(a == b && b == c && a.count == 364)
    }
    let key = try #require(HTTPField.Name("X-Api-Key"))
    for call in transport.requests {
      #expect(call.request.path == "/NPSpecies/v3/rest/\(route)/ACAD/birds?format=json")
      #expect(call.request.authority == "irmaservices.nps.gov")
      #expect(call.request.headerFields[.accept] == "application/json")
      #expect(call.request.headerFields[key] == nil)
    }
  }

  @Test("HTTP and decoding failures remain typed without retries")
  func httpAndDecodingFailuresRemainTypedWithoutRetries() async throws {
    let body = try IRMAFixture.speciesHTTPFailure.data()
    let transport = MockTransport(results: [
      .success(Response(body: body, headers: [.contentType: "text/html"], status: .badRequest)),
      .success(.ok(json: Data("bad JSON".utf8))),
    ])
    let client = NPSSpeciesClient(transport: transport)
    let query = try SpeciesQuery(unitCode: "ACAD")
    do throws(NPSSpeciesError) {
      _ = try await client.species(query: query)
      Issue.record("Expected HTTP failure.")
    } catch {
      guard case .transport(.httpStatus(let received, let status, let headers)) = error else {
        Issue.record("Expected HTTP status."); return
      }
      #expect(received == body && status == 400)
      #expect(headers[.contentType] == "text/html")
    }
    do throws(NPSSpeciesError) {
      _ = try await client.species(query: query)
      Issue.record("Expected decoding failure.")
    } catch {
      guard case .transport(.decode) = error else { Issue.record("Expected decode error."); return }
    }
    #expect(transport.requests.count == 2)
  }

  @Test(
    "Redirects cannot leave the Species base",
    arguments: ["https://example.com", "https://irmaservices.nps.gov/v3/rest/stats/total/2025"])
  func redirectsCannotLeaveTheSpeciesBase(_ location: String) async throws {
    let query = try SpeciesQuery(unitCode: "ACAD")
    let transport = MockTransport(results: [
      .success(Response(body: Data(), headers: [.location: location], status: .found))
    ])
    do throws(NPSSpeciesError) {
      _ = try await NPSSpeciesClient(transport: transport).species(query: query)
      Issue.record("Redirect must fail.")
    } catch {
      guard case .transport = error else { Issue.record("Expected transport failure."); return }
    }
    #expect(transport.requests.count == 1)
  }
}
