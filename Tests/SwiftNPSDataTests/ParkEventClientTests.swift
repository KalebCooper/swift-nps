import Foundation
import HTTPCore
import HTTPTesting
import HTTPTypes
import SwiftNPSData
import SwiftNPSDataModels
import SwiftNPSDataTestSupport
import Testing

@Suite("Event client", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct ParkEventClientTests {
  @Test("Cancellation before event execution sends nothing", arguments: [false, true])
  func cancellationBeforeEventExecutionSendsNothing(_ request: Bool) async throws {
    let transport = MockTransport()
    let client = try Self.client(transport)
    let query = try ParkEventQuery()
    await withTaskGroup(of: Void.self) { group in
      group.cancelAll()
      group.addTask {
        do throws(NPSDataError) {
          if request {
            _ = try await client.value(for: .parkEvents(query: query))
          } else {
            _ = try await client.send(.parkEvents(query: query))
          }
          Issue.record("Cancelled execution must fail.")
        } catch {
          guard case .transport(.cancelled) = error else {
            Issue.record("Expected typed cancellation.")
            return
          }
        }
      }
    }
    #expect(transport.requests.isEmpty)
  }

  @Test("Custom event factories and response types preserve inference")
  func customEventFactoriesAndResponseTypesPreserveInference() async throws {
    let transport = MockTransport(
      results: Array(
        repeating:
          .success(.ok(json: try Fixture.eventsPageFirst.data())), count: 2))
    let client = try Self.client(transport)
    let request = NPSDataRequest.eventTitles
    let _: NPSDataRequest<EventTitles> = request
    let titles = try await client.value(for: request)
    #expect(titles.data.first?.title == "Ranger Program (Canyon Area) - Artist Point Talk")
    let stored = try NPSDataRequest.yellowstoneEvents
    let _: NPSDataRequest<ParkEventCollection> = stored
    #expect(try await client.value(for: stored).data.count == 2)
    #expect(transport.requests.count == 2)
  }

  @Test("Endpoint and stored request send the same authenticated event operation")
  func endpointAndStoredRequestSendTheSameAuthenticatedEventOperation() async throws {
    let transport = MockTransport(
      results: Array(
        repeating:
          .success(.ok(json: try Fixture.eventsPageFirst.data())), count: 2))
    let client = try Self.client(transport)
    let query = try ParkEventQuery(
      dateEnd: .init("2026-10-02"), dateStart: .init("2026-09-26"), pageSize: 2,
      parkCodes: [ParkCode("yell")])
    let request = NPSDataRequest.parkEvents(query: query)
    let first = try await client.value(for: request)
    #expect(transport.requests.count == 1)
    let second = try await client.send(.parkEvents(query: query))
    #expect(first == second)
    #expect(transport.requests.count == 2)
    let field = try #require(HTTPField.Name("X-Api-Key"))
    for call in transport.requests {
      #expect(
        call.request.path
          == "/api/v1/events?dateEnd=2026-10-02&dateStart=2026-09-26&expandRecurring=false&pageNumber=1&pageSize=2&parkCode=yell"
      )
      #expect(call.request.headerFields[field] == "private-test-key")
      #expect(call.request.headerFields[.accept] == "application/json")
      #expect(call.request.authority == "developer.nps.gov")
      #expect(call.request.method == .get)
      #expect(call.request.path?.contains("private-test-key") == false)
    }
  }

  @Test("Event service errors retain their envelope status and headers", arguments: [false, true])
  func eventServiceErrorsRetainTheirEnvelopeStatusAndHeaders(_ request: Bool) async throws {
    let body = Data(
      #"{"data":[],"errors":[{"code":"future"}],"pagenumber":"1","pagesize":"10","total":"0"}"#.utf8
    )
    let transport = MockTransport(results: [
      .success(Response(body: body, headers: [.retryAfter: "60"], status: .ok))
    ])
    let client = try Self.client(transport)
    let query = try ParkEventQuery()
    do throws(NPSDataError) {
      if request {
        _ = try await client.value(for: .parkEvents(query: query))
      } else {
        _ = try await client.send(.parkEvents(query: query))
      }
      Issue.record("Reported errors must not become an empty successful response.")
    } catch {
      guard case .eventService(let response) = error else {
        Issue.record("Expected the event-specific service failure.")
        return
      }
      #expect(response.value.page?.errors == [.object(["code": .string("future")])])
      #expect(response.status.code == 200)
      #expect(response.headers[.retryAfter] == "60")
    }
    #expect(transport.requests.count == 1)
  }

  @Test("Expanded single-page execution keeps repeated occurrences")
  func expandedSinglePageExecutionKeepsRepeatedOccurrences() async throws {
    let transport = MockTransport(results: [
      .success(.ok(json: try Fixture.eventsExpanded.data()))
    ])
    let query = try ParkEventQuery(
      dateEnd: .init("2026-10-07"), dateStart: .init("2026-10-01"),
      expandRecurring: true, pageSize: 2, parkCodes: [ParkCode("yell")])
    let request = NPSDataRequest.parkEvents(query: query)
    let endpoint = Endpoint.parkEvents(query: query)
    let _: Endpoint<ParkEventCollection> = endpoint
    let response = try await Self.client(transport).value(for: request)
    #expect(response.page == nil)
    #expect(response.data.count == 6)
    #expect(Set(response.data.map(\.id)).count == 1)
    #expect(transport.requests.count == 1)
  }

  @Test("HTTP and decoding failures remain typed without retries", arguments: [false, true])
  func httpAndDecodingFailuresRemainTypedWithoutRetries(_ http: Bool) async throws {
    let body = http ? try Fixture.eventsInvalidDate.data() : Data("not JSON".utf8)
    let transport = MockTransport(results: [
      .success(Response(body: body, headers: [.retryAfter: "60"], status: http ? .badRequest : .ok))
    ])
    do {
      _ = try await Self.client(transport).value(for: .parkEvents(query: ParkEventQuery()))
      Issue.record("Invalid responses must fail.")
    } catch let error as NPSDataError {
      if http {
        guard case .transport(.httpStatus(let received, let code, let headers)) = error else {
          Issue.record("Expected the original HTTP failure.")
          return
        }
        #expect(received == body)
        #expect(code == 400)
        #expect(headers[.retryAfter] == "60")
      } else {
        guard case .transport(.decode) = error else {
          Issue.record("Expected a decoding failure.")
          return
        }
      }
    }
    #expect(transport.requests.count == 1)
  }

  private static func client(_ transport: MockTransport) throws -> NPSDataClient {
    NPSDataClient(
      configuration: try NPSDataConfiguration(apiKey: "private-test-key"), transport: transport)
  }
}

private struct EventTitles: Decodable, Sendable {
  struct Title: Decodable, Sendable {
    let title: String
  }
  let data: [Title]
}

extension NPSDataRequest where Response == EventTitles {
  fileprivate static var eventTitles: Self {
    guard let endpoint = Endpoint<EventTitles>(path: "/events?pageNumber=1&pageSize=2") else {
      preconditionFailure("The test uses a valid relative endpoint.")
    }
    return Self(endpoint: endpoint)
  }
}

extension NPSDataRequest where Response == ParkEventCollection {
  fileprivate static var yellowstoneEvents: Self {
    get throws {
      .parkEvents(query: try ParkEventQuery(pageSize: 2, parkCodes: [ParkCode("yell")]))
    }
  }
}
