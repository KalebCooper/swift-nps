import Foundation
import HTTPCore
import HTTPTesting
import HTTPTypes
import SwiftNPSData
import SwiftNPSDataModels
import SwiftNPSDataTestSupport
import Testing

@Suite("Lazy events", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct ParkEventPaginationTests {
  @Test(
    "Arbitrary starting pages and full terminal pages stop correctly", arguments: [false, true])
  func arbitraryStartingPagesAndFullTerminalPagesStopCorrectly(_ full: Bool) async throws {
    let fixture: Fixture = full ? .eventsFullTerminal : .eventsPageLast
    let transport = MockTransport(results: [.success(.ok(json: try fixture.data()))])
    let query = try ParkEventQuery(pageNumber: full ? 1 : 2, pageSize: full ? 3 : 2)
    var iterator = try Self.client(transport).parkEventPages(query: query).makeAsyncIterator()
    #expect(try await iterator.next()?.data.count == (full ? 3 : 1))
    #expect(try await iterator.next() == nil)
    #expect(try await iterator.next() == nil)
    #expect(transport.requests.count == 1)
  }

  @Test("Cancellation before iteration sends nothing", arguments: [false, true])
  func cancellationBeforeIterationSendsNothing(_ items: Bool) async throws {
    let transport = MockTransport()
    let client = try Self.client(transport)
    let query = try ParkEventQuery()
    await withTaskGroup(of: Void.self) { group in
      group.cancelAll()
      group.addTask {
        var pages = client.parkEventPages(query: query).makeAsyncIterator()
        var events = client.parkEvents(query: query).makeAsyncIterator()
        do throws(NPSDataError) {
          if items { _ = try await events.next() } else { _ = try await pages.next() }
          Issue.record("Cancelled iteration must fail.")
        } catch {
          guard case .transport(.cancelled) = error else {
            Issue.record("Expected cancellation."); return
          }
        }
        if items {
          #expect((try? await events.next()) == nil)
        } else {
          #expect((try? await pages.next()) == nil)
        }
      }
    }
    #expect(transport.requests.isEmpty)
  }

  @Test("Cancellation between reads stops buffered items and pages", arguments: [false, true])
  func cancellationBetweenReadsStopsBufferedItemsAndPages(_ items: Bool) async throws {
    let transport = MockTransport(results: [.success(.ok(json: try Fixture.eventsPageFirst.data()))]
    )
    let client = try Self.client(transport)
    let query = try ParkEventQuery(pageSize: 2)
    let (ready, signal) = AsyncStream<Void>.makeStream()
    let (resume, finish) = AsyncStream<Void>.makeStream()
    defer { finish.finish() }
    let task = Task { () async throws -> Void in
      defer { signal.finish() }
      var pages = client.parkEventPages(query: query).makeAsyncIterator()
      var events = client.parkEvents(query: query).makeAsyncIterator()
      if items { _ = try await events.next() } else { _ = try await pages.next() }
      signal.yield()
      for await _ in resume {}
      do throws(NPSDataError) {
        if items { _ = try await events.next() } else { _ = try await pages.next() }
        Issue.record("Cancelled iteration must fail.")
      } catch {
        guard case .transport(.cancelled) = error else {
          Issue.record("Expected cancellation."); return
        }
      }
      if items {
        #expect(try await events.next() == nil)
      } else {
        #expect(try await pages.next() == nil)
      }
    }
    var readiness = ready.makeAsyncIterator()
    _ = await readiness.next()
    task.cancel()
    try await task.value
    #expect(transport.requests.count == 1)
  }

  @Test("Cancellation during body delivery terminates the iterator")
  func cancellationDuringBodyDeliveryTerminatesTheIterator() async throws {
    let (body, finish) = AsyncStream<Data>.makeStream()
    let (ready, signal) = AsyncStream<Void>.makeStream()
    defer { finish.finish(); signal.finish() }
    let transport = MockTransport(answers: [
      .success(
        .init(body: {
          signal.yield()
          return StreamedBody(body)
        }))
    ])
    let client = try Self.client(transport)
    let query = try ParkEventQuery()
    let task = Task { () async throws -> Void in
      var iterator = client.parkEventPages(query: query).makeAsyncIterator()
      do throws(NPSDataError) {
        _ = try await iterator.next()
        Issue.record("A cancelled body must fail.")
      } catch {
        guard case .transport(.cancelled) = error else {
          Issue.record("Expected cancellation."); return
        }
      }
      #expect(try await iterator.next() == nil)
    }
    var readiness = ready.makeAsyncIterator()
    _ = await readiness.next()
    task.cancel()
    try await task.value
    #expect(transport.requests.count == 1)
  }

  @Test("Continuation retains every filter and authenticated request")
  func continuationRetainsEveryFilterAndAuthenticatedRequest() async throws {
    let transport = MockTransport(
      results: try [
        .success(.ok(json: Fixture.eventsPageFirst.data())),
        .success(.ok(json: Fixture.eventsPageLast.data())),
      ])
    let query = try ParkEventQuery(
      dateEnd: .init("2026-10-02"), dateStart: .init("2026-09-26"),
      eventTypes: ["Talk", "Walk"], identifier: "id & one", organizations: ["org"], pageSize: 2,
      parkCodes: [ParkCode("yell")], portals: ["portal"], searchText: "Ranger talk",
      stateCodes: [StateCode("WY")], tagsAll: ["a"], tagsNone: ["b"], tagsOne: ["c", "d"])
    let sequence = try Self.client(transport).pages(for: .parkEvents(query: query))
    var iterator = sequence.makeAsyncIterator()
    #expect(transport.requests.isEmpty)
    #expect(try await iterator.next()?.data.count == 2)
    #expect(transport.requests.count == 1)
    #expect(try await iterator.next()?.data.count == 1)
    #expect(try await iterator.next() == nil)
    let paths = [1, 2].map {
      "/api/v1/events?dateEnd=2026-10-02&dateStart=2026-09-26&eventType=Talk,Walk&expandRecurring=false&id=id%20%26%20one&organization=org&pageNumber=\($0)&pageSize=2&parkCode=yell&portal=portal&q=Ranger%20talk&stateCode=WY&tagsAll=a&tagsNone=b&tagsOne=c,d"
    }
    #expect(transport.requests.map(\.request.path) == paths)
    let key = try #require(HTTPField.Name("X-Api-Key"))
    for call in transport.requests {
      #expect(call.request.headerFields[key] == "private-test-key")
      #expect(call.request.headerFields[.accept] == "application/json")
      #expect(call.request.authority == "developer.nps.gov")
    }
  }

  @Test("Early break and independent iterators never prefetch", arguments: [false, true])
  func earlyBreakAndIndependentIteratorsNeverPrefetch(_ items: Bool) async throws {
    let transport = MockTransport(
      results: Array(
        repeating: .success(.ok(json: try Fixture.eventsPageFirst.data())), count: 2))
    let client = try Self.client(transport)
    let query = try ParkEventQuery(pageSize: 2)
    let pages = client.parkEventPages(query: query)
    let events = client.parkEvents(query: query)
    #expect(transport.requests.isEmpty)
    for _ in 0..<2 {
      if items { for try await _ in events { break } } else { for try await _ in pages { break } }
    }
    #expect(transport.requests.count == 2)
    #expect(transport.requests.first?.request.path == transport.requests.last?.request.path)
  }

  @Test("Empty terminal pages produce no items", arguments: [false, true])
  func emptyTerminalPagesProduceNoItems(_ items: Bool) async throws {
    let transport = MockTransport(results: [.success(.ok(json: try Fixture.eventsEmpty.data()))])
    let client = try Self.client(transport)
    let query = try ParkEventQuery(pageSize: 50)
    if items {
      var iterator = client.parkEvents(query: query).makeAsyncIterator()
      #expect(try await iterator.next() == nil)
      #expect(try await iterator.next() == nil)
    } else {
      var iterator = client.parkEventPages(query: query).makeAsyncIterator()
      #expect(try await iterator.next()?.data.isEmpty == true)
      #expect(try await iterator.next() == nil)
    }
    #expect(transport.requests.count == 1)
  }

  @Test("Endpoint-only expansion preserves all repeated occurrences in order")
  func endpointOnlyExpansionPreservesAllRepeatedOccurrencesInOrder() async throws {
    let data = try Fixture.eventsExpanded.data()
    let expected = try JSONDecoder().decode(ParkEventCollection.self, from: data)
    let transport = MockTransport(results: [.success(.ok(json: data))])
    let request = NPSDataRequest(
      endpoint: Endpoint.parkEvents(query: try ParkEventQuery(expandRecurring: true)))
    var received: [ParkEvent] = []
    for try await event in try Self.client(transport).items(for: request) { received.append(event) }
    #expect(received == expected.data)
    #expect(received.count == 6)
    #expect(Set(received.map(\.id)).count == 1)
    #expect(transport.requests.count == 1)
  }

  @Test("Expanded query traversal fails before sending", arguments: [false, true])
  func expandedQueryTraversalFailsBeforeSending(_ items: Bool) async throws {
    let transport = MockTransport()
    let client = try Self.client(transport)
    let query = try ParkEventQuery(expandRecurring: true)
    var pages = client.parkEventPages(query: query).makeAsyncIterator()
    var events = client.parkEvents(query: query).makeAsyncIterator()
    do throws(NPSDataError) {
      if items { _ = try await events.next() } else { _ = try await pages.next() }
      Issue.record("Expansion cannot be traversed safely.")
    } catch {
      guard case .pagination(.eventExpansionUnavailable) = error else {
        Issue.record("Expected expansion refusal."); return
      }
    }
    if items {
      #expect(try await events.next() == nil)
    } else {
      #expect(try await pages.next() == nil)
    }
    #expect(transport.requests.isEmpty)
  }

  @Test(
    "Invalid metadata is never yielded",
    arguments: [
      ("pagenumber", "2"), ("pagenumber", "0"), ("pagenumber", "oops"),
      ("pagesize", "3"), ("pagesize", "0"), ("pagesize", "-1"),
      ("total", "1"), ("total", " 3"), ("total", "999999999999999999999999"),
    ])
  func invalidMetadataIsNeverYielded(_ field: String, _ value: String) async throws {
    var object = try #require(
      JSONSerialization.jsonObject(with: Fixture.eventsPageFirst.data()) as? [String: Any])
    object[field] = value
    let data = try JSONSerialization.data(withJSONObject: object)
    let transport = MockTransport(results: [.success(.ok(json: data))])
    var iterator = try Self.client(transport).parkEventPages(query: ParkEventQuery(pageSize: 2))
      .makeAsyncIterator()
    do throws(NPSDataError) {
      _ = try await iterator.next()
      Issue.record("Invalid metadata must not be yielded.")
    } catch {
      guard case .pagination = error else { Issue.record("Expected pagination failure."); return }
    }
    #expect(try await iterator.next() == nil)
    #expect(transport.requests.count == 1)
  }

  @Test("Items buffer one page and match page traversal")
  func itemsBufferOnePageAndMatchPageTraversal() async throws {
    let data = try [Fixture.eventsPageFirst.data(), Fixture.eventsPageLast.data()]
    let transport = MockTransport(results: (data + data).map { .success(.ok(json: $0)) })
    let client = try Self.client(transport)
    let request = NPSDataRequest.parkEvents(query: try ParkEventQuery(pageSize: 2))
    var expected: [ParkEvent] = []
    for try await page in client.pages(for: request) { expected += page.data }
    var iterator = client.items(for: request).makeAsyncIterator()
    var received: [ParkEvent] = []
    received.append(try #require(try await iterator.next()))
    received.append(try #require(try await iterator.next()))
    #expect(transport.requests.count == 3)
    received.append(try #require(try await iterator.next()))
    #expect(try await iterator.next() == nil)
    #expect(received == expected)
    #expect(transport.requests.count == 4)
  }

  @Test(
    "Second-page failures end iteration without retries",
    arguments: ["decode", "http", "service", "echo"])
  func secondPageFailuresEndIterationWithoutRetries(_ kind: String) async throws {
    let data: Data
    switch kind {
    case "decode": data = Data("invalid JSON".utf8)
    case "http": data = try Fixture.eventsInvalidDate.data()
    case "service":
      data = Data(
        #"{"data":[],"errors":["future"],"pagenumber":"wrong","pagesize":"2","total":"0"}"#.utf8)
    default: data = try Fixture.eventsPageFirst.data()
    }
    let transport = MockTransport(results: [
      .success(.ok(json: try Fixture.eventsPageFirst.data())),
      .success(
        Response(
          body: data, headers: [.retryAfter: "60"], status: kind == "http" ? .badRequest : .ok)),
    ])
    var iterator = try Self.client(transport).parkEventPages(query: ParkEventQuery(pageSize: 2))
      .makeAsyncIterator()
    _ = try await iterator.next()
    do throws(NPSDataError) {
      _ = try await iterator.next()
      Issue.record("The second page must fail.")
    } catch {
      switch (kind, error) {
      case ("decode", .transport(.decode)): break
      case ("echo", .pagination(.unexpectedPageNumber(actual: 1, expected: 2))): break
      case ("http", .transport(.httpStatus(let body, let code, let headers))):
        #expect(body == data); #expect(code == 400); #expect(headers[.retryAfter] == "60")
      case ("service", .eventService(let response)):
        #expect(response.value.page?.errors == [.string("future")])
        #expect(response.headers[.retryAfter] == "60")
        #expect(response.status.code == 200)
      default: Issue.record("Unexpected failure: \(error)")
      }
    }
    #expect(try await iterator.next() == nil)
    #expect(transport.requests.count == 2)
  }

  private static func client(_ transport: MockTransport) throws -> NPSDataClient {
    NPSDataClient(
      configuration: try NPSDataConfiguration(apiKey: "private-test-key"), transport: transport)
  }
}
