import Foundation
import HTTPCore
import HTTPTesting
import HTTPTypes
import SwiftNPSData
import SwiftNPSDataModels
import SwiftNPSDataTestSupport
import Testing

@Suite("Road events client", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct RoadEventClientTests {
  @Test("A road events lookup sends one authenticated request for the feed")
  func aRoadEventsLookupSendsOneAuthenticatedRequestForTheFeed() async throws {
    let body = try Fixture.roadEventsType.data()
    let transport = MockTransport(results: [.success(.ok(json: body))])
    let feed = try await makeClient(transport).roadEvents(
      parkCode: ParkCode("yell"), type: .workZone)
    #expect(feed == (try JSONDecoder().decode(RoadEventFeed.self, from: body)))
    #expect(feed.features?.count == 2)
    let call = try #require(transport.requests.first)
    let field = try #require(HTTPField.Name("X-Api-Key"))
    #expect(transport.requests.count == 1)
    #expect(call.request.method == .get)
    #expect(call.request.authority == "developer.nps.gov")
    #expect(call.request.path == "/api/v1/roadevents?parkCode=yell&type=WorkZone")
    #expect(call.request.headerFields[.accept] == "application/json")
    #expect(call.request.headerFields[field] == "private-test-key")
    #expect(call.body == .none)
  }

  @Test("An empty road events feed is returned without another request")
  func anEmptyRoadEventsFeedIsReturnedWithoutAnotherRequest() async throws {
    let transport = MockTransport(results: [
      .success(.ok(json: try Fixture.roadEventsEmpty.data()))
    ])
    let feed = try await makeClient(transport).roadEvents(parkCode: ParkCode("acad"))
    #expect(feed.features == [])
    #expect(feed.roadEventFeedInfo?.publisher == "National Park Service")
    #expect(transport.requests.map(\.request.path) == ["/api/v1/roadevents?parkCode=acad"])
  }

  @Test("Cancellation before any road events entry point sends nothing", arguments: [0, 1, 2])
  func cancellationBeforeAnyRoadEventsEntryPointSendsNothing(_ entry: Int) async throws {
    let transport = MockTransport()
    let client = try makeClient(transport)
    await withTaskGroup(of: Void.self) { group in
      group.cancelAll()
      group.addTask {
        do throws(NPSDataError) {
          switch entry {
          case 0: _ = try await client.roadEvents()
          case 1: _ = try await client.value(for: .roadEvents())
          default: _ = try await client.send(.roadEvents())
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

  @Test("Road events failures map to typed errors")
  func roadEventsFailuresMapToTypedErrors() async throws {
    let body = try Fixture.apiKeyMissing.data()
    let transport = MockTransport(results: [
      .success(Response(body: body, headers: [:], status: .forbidden)),
      .success(.ok(json: Data("not JSON".utf8))),
    ])
    let client = try makeClient(transport)
    do {
      _ = try await client.roadEvents(type: .incident)
      Issue.record("A gateway failure must be thrown.")
    } catch {
      guard case .service(let response, _) = error else {
        Issue.record("Expected a typed gateway response, received \(error).")
        return
      }
      #expect(response.error.code == "API_KEY_MISSING")
    }
    do {
      _ = try await client.roadEvents(type: .incident)
      Issue.record("An invalid response must fail decoding.")
    } catch {
      guard case .transport(.decode) = error else {
        Issue.record("Expected a typed decoding failure, received \(error).")
        return
      }
    }
    #expect(
      transport.requests.map(\.request.path) == [
        "/api/v1/roadevents?type=Incident", "/api/v1/roadevents?type=Incident",
      ])
  }

  @Test("Every road events entry point returns the same feed")
  func everyRoadEventsEntryPointReturnsTheSameFeed() async throws {
    let body = try Fixture.roadEventsDelawareWaterGap.data()
    let transport = MockTransport(results: Array(repeating: .success(.ok(json: body)), count: 3))
    let client = try makeClient(transport)
    let code = try ParkCode("dewa")
    let everyday = try await client.roadEvents(parkCode: code)
    let reusable = try await client.value(for: .roadEvents(parkCode: code))
    let endpoint = try await client.send(.roadEvents(parkCode: code))
    #expect(everyday == reusable)
    #expect(reusable == endpoint)
    #expect(everyday.features?.count == 8)
    #expect(
      transport.requests.map(\.request.path)
        == Array(
          repeating: "/api/v1/roadevents?parkCode=dewa", count: 3))
  }

  private func makeClient(_ transport: MockTransport) throws(NPSDataError) -> NPSDataClient {
    NPSDataClient(
      configuration: try NPSDataConfiguration(apiKey: "private-test-key"), transport: transport)
  }
}
