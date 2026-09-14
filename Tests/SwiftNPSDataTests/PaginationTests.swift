import Foundation
import HTTPCore
import HTTPTesting
import HTTPTypes
import SwiftNPSData
import SwiftNPSDataModels
import SwiftNPSDataTestSupport
import Testing

@Suite("Lazy parks pagination", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct PaginationTests {
  @Test("Cancellation before iteration sends no request", arguments: [false, true])
  func cancellationBeforeIterationSendsNoRequest(_ items: Bool) async throws {
    let transport = MockTransport()
    let client = try makeClient(transport)
    let query = try ParkQuery()
    await withTaskGroup(of: Void.self) { group in
      group.cancelAll()
      group.addTask {
        do throws(NPSDataError) {
          if items {
            var iterator = client.parks(query: query).makeAsyncIterator()
            _ = try await iterator.next()
          } else {
            var iterator = client.parkPages(query: query).makeAsyncIterator()
            _ = try await iterator.next()
          }
          Issue.record("Cancelled iteration must fail.")
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

  @Test("Cancellation between reads ends pages and buffered parks", arguments: [false, true])
  func cancellationBetweenReadsEndsPagesAndBufferedParks(_ items: Bool) async throws {
    let transport = MockTransport(results: [.success(.ok(json: try Fixture.parksSearch.data()))])
    let client = try makeClient(transport)
    let query = try ParkQuery(limit: 2)
    let (ready, signalReady) = AsyncStream<Void>.makeStream()
    let (resume, finishResume) = AsyncStream<Void>.makeStream()
    defer { finishResume.finish() }
    let task = Task {
      defer { signalReady.finish() }
      var pages = client.parkPages(query: query).makeAsyncIterator()
      var parks = client.parks(query: query).makeAsyncIterator()
      if items { _ = try await parks.next() } else { _ = try await pages.next() }
      signalReady.yield()
      // The parent cancels after the first read; cancellation ends this suspended stream.
      for await _ in resume {}
      do throws(NPSDataError) {
        if items { _ = try await parks.next() } else { _ = try await pages.next() }
        Issue.record("The next read must observe cancellation.")
      } catch {
        guard case .transport(.cancelled) = error else {
          Issue.record("Expected typed cancellation.")
          return
        }
      }
      if items {
        #expect(try await parks.next() == nil)
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

  @Test("Custom response factories and one-page execution preserve inference")
  func customResponseFactoriesAndOnePageExecutionPreserveInference() async throws {
    let transport = MockTransport(
      results: Array(
        repeating: .success(.ok(json: try Fixture.parksPageFirst.data())), count: 3))
    let client = try makeClient(transport)
    let query = try makeQuery()
    let page = try await client.value(for: .parks(query: query))
    let direct = try await client.send(.parks(query: query))
    let request = ParkRequest.names(query: query)
    let names = try await client.value(for: request)
    let _: ParkRequest<QueryNames> = request
    #expect(page == direct)
    #expect(names.data.map(\.parkCode) == ["acad"])
    #expect(transport.requests.count == 3)
  }

  @Test("Derived requests retain text state filters and sorting")
  func derivedRequestsRetainTextStateFiltersAndSorting() async throws {
    let transport = MockTransport(
      results: try [
        .success(.ok(json: Fixture.parksPageFirst.data())),
        .success(.ok(json: Fixture.parksPageLast.data())),
      ])
    let query = try ParkQuery(
      limit: 1, parkCodes: [ParkCode("acad"), ParkCode("yell")], searchText: "national park",
      sort: [.fullName(.ascending), .parkCode(.descending)],
      stateCodes: [StateCode("ME"), StateCode("WY")])
    for try await _ in try makeClient(transport).parkPages(query: query) {}
    #expect(
      transport.requests.map(\.request.path) == [
        "/api/v1/parks?limit=1&parkCode=acad,yell&q=national%20park&sort=fullName,-parkCode&start=0&stateCode=ME,WY",
        "/api/v1/parks?limit=1&parkCode=acad,yell&q=national%20park&sort=fullName,-parkCode&start=1&stateCode=ME,WY",
      ])
  }

  @Test("Early break never fetches another page", arguments: [false, true])
  func earlyBreakNeverFetchesAnotherPage(_ items: Bool) async throws {
    let transport = MockTransport(results: [.success(.ok(json: try Fixture.parksPageFirst.data()))])
    let client = try makeClient(transport)
    let query = try makeQuery()
    if items {
      for try await park in client.parks(query: query) {
        #expect(park.parkCode == "acad")
        break
      }
    } else {
      for try await page in client.parkPages(query: query) {
        #expect(page.data.first?.parkCode == "acad")
        break
      }
    }
    #expect(transport.requests.count == 1)
  }

  @Test("Empty terminal pages yield a page and no parks", arguments: [false, true])
  func emptyTerminalPagesYieldAPageAndNoParks(_ items: Bool) async throws {
    let transport = MockTransport(results: [.success(.ok(json: try Fixture.parksBeyond.data()))])
    let client = try makeClient(transport)
    let query = try ParkQuery(limit: 1, start: 2)
    if items {
      var iterator = client.parks(query: query).makeAsyncIterator()
      #expect(try await iterator.next() == nil)
    } else {
      var iterator = client.parkPages(query: query).makeAsyncIterator()
      #expect(try await iterator.next()?.data.isEmpty == true)
      #expect(try await iterator.next() == nil)
    }
    #expect(transport.requests.count == 1)
  }

  @Test("Independent iterators start at the original offset")
  func independentIteratorsStartAtTheOriginalOffset() async throws {
    let transport = MockTransport(
      results: Array(
        repeating: .success(.ok(json: try Fixture.parksPageFirst.data())), count: 2))
    let sequence = try makeClient(transport).parkPages(query: makeQuery())
    var first = sequence.makeAsyncIterator()
    var second = sequence.makeAsyncIterator()
    #expect(try await first.next()?.start == "0")
    #expect(try await second.next()?.start == "0")
    #expect(
      transport.requests.map(\.request.path) == [
        "/api/v1/parks?limit=1&parkCode=acad,yell&sort=parkCode&start=0",
        "/api/v1/parks?limit=1&parkCode=acad,yell&sort=parkCode&start=0",
      ])
  }

  @Test("Invalid continuation metadata throws instead of ending quietly")
  func invalidContinuationMetadataThrowsInsteadOfEndingQuietly() async throws {
    let body = Data(#"{"data":[],"limit":"50","start":"0","total":"1"}"#.utf8)
    let transport = MockTransport(results: [.success(.ok(json: body))])
    var iterator = try makeClient(transport).parkPages(query: ParkQuery()).makeAsyncIterator()
    do throws(NPSDataError) {
      _ = try await iterator.next()
      Issue.record("An empty page before the total must not look complete.")
    } catch {
      guard case .pagination(.inconsistentPage) = error else {
        Issue.record("Expected a typed pagination failure.")
        return
      }
    }
    #expect(try await iterator.next() == nil)
    #expect(transport.requests.count == 1)
  }

  @Test("Item iteration drains the current page without prefetch")
  func itemIterationDrainsTheCurrentPageWithoutPrefetch() async throws {
    let transport = MockTransport(results: [.success(.ok(json: try Fixture.parksSearch.data()))])
    let request = try ParkRequest.parks(query: ParkQuery(limit: 2))
    var iterator = try makeClient(transport).parks(for: request).makeAsyncIterator()
    #expect(transport.requests.isEmpty)
    #expect(try await iterator.next()?.parkCode == "adam")
    #expect(try await iterator.next()?.parkCode == "bost")
    #expect(transport.requests.count == 1)
  }

  @Test("Page and item requests produce equivalent complete results")
  func pageAndItemRequestsProduceEquivalentCompleteResults() async throws {
    let responses: [Result<Response, TransportError>] = try [
      .success(.ok(json: Fixture.parksPageFirst.data())),
      .success(.ok(json: Fixture.parksPageLast.data())),
    ]
    let transport = MockTransport(results: responses + responses)
    let client = try makeClient(transport)
    let request = try ParkRequest.parks(query: makeQuery())
    var fromPages: [Park] = []
    for try await page in client.parkPages(for: request) { fromPages += page.data }
    var fromItems: [Park] = []
    for try await park in client.parks(for: request) { fromItems.append(park) }
    #expect(fromPages == fromItems)
    #expect(fromItems.map(\.parkCode) == ["acad", "yell"])
    #expect(transport.requests.count == 4)
  }

  @Test("Pages are lazy and preserve authenticated continuation requests")
  func pagesAreLazyAndPreserveAuthenticatedContinuationRequests() async throws {
    let transport = MockTransport(
      results: try [
        .success(.ok(json: Fixture.parksPageFirst.data())),
        .success(.ok(json: Fixture.parksPageLast.data())),
      ])
    let sequence = try makeClient(transport).parkPages(query: makeQuery())
    var iterator = sequence.makeAsyncIterator()
    #expect(transport.requests.isEmpty)
    #expect(try await iterator.next()?.data.first?.parkCode == "acad")
    #expect(transport.requests.count == 1)
    #expect(try await iterator.next()?.data.first?.parkCode == "yell")
    #expect(try await iterator.next() == nil)
    #expect(
      transport.requests.map(\.request.path) == [
        "/api/v1/parks?limit=1&parkCode=acad,yell&sort=parkCode&start=0",
        "/api/v1/parks?limit=1&parkCode=acad,yell&sort=parkCode&start=1",
      ])
    let key = try #require(HTTPField.Name("X-Api-Key"))
    for call in transport.requests {
      #expect(call.request.authority == "developer.nps.gov")
      #expect(call.request.headerFields[key] == "private-test-key")
      #expect(call.request.headerFields[.accept] == "application/json")
    }
  }

  @Test("Repeated offsets end iteration with a typed failure")
  func repeatedOffsetsEndIterationWithATypedFailure() async throws {
    let transport = MockTransport(
      results: Array(
        repeating: .success(.ok(json: try Fixture.parksPageFirst.data())), count: 2))
    var iterator = try makeClient(transport).parks(query: makeQuery()).makeAsyncIterator()
    #expect(try await iterator.next()?.parkCode == "acad")
    do throws(NPSDataError) {
      _ = try await iterator.next()
      Issue.record("A repeated page must fail.")
    } catch {
      guard case .pagination(.unexpectedStart(actual: 0, expected: 1)) = error else {
        Issue.record("Expected an offset mismatch.")
        return
      }
    }
    #expect(try await iterator.next() == nil)
    #expect(transport.requests.count == 2)
  }

  @Test("Second page failures retain service metadata and never retry")
  func secondPageFailuresRetainServiceMetadataAndNeverRetry() async throws {
    let transport = MockTransport(
      results: try [
        .success(.ok(json: Fixture.parksPageFirst.data())),
        .success(
          Response(
            body: Fixture.apiKeyMissing.data(), headers: [.retryAfter: "60"], status: .forbidden)),
      ])
    var iterator = try makeClient(transport).parkPages(query: makeQuery()).makeAsyncIterator()
    _ = try await iterator.next()
    do throws(NPSDataError) {
      _ = try await iterator.next()
      Issue.record("The second page must fail.")
    } catch {
      guard case .service(let body, .httpStatus(_, let status, let headers)) = error else {
        Issue.record("Expected the original gateway failure.")
        return
      }
      #expect(body.error.code == "API_KEY_MISSING")
      #expect(status == 403)
      #expect(headers[.retryAfter] == "60")
    }
    #expect(try await iterator.next() == nil)
    #expect(transport.requests.count == 2)
  }

  @Test("Second page redirects never forward the API key", arguments: [false, true])
  func secondPageRedirectsNeverForwardTheAPIKey(_ items: Bool) async throws {
    let transport = MockTransport(
      results: try [
        .success(.ok(json: Fixture.parksPageFirst.data())),
        .success(Response(headers: [.location: "https://example.com/parks"], status: .found)),
      ])
    let client = try makeClient(transport)
    let query = try makeQuery()
    var pages = client.parkPages(query: query).makeAsyncIterator()
    var parks = client.parks(query: query).makeAsyncIterator()
    if items { _ = try await parks.next() } else { _ = try await pages.next() }
    do throws(NPSDataError) {
      if items { _ = try await parks.next() } else { _ = try await pages.next() }
      Issue.record("Redirects must fail without following the location.")
    } catch {
      guard case .transport(.httpStatus(_, let status, _)) = error else {
        Issue.record("Expected the original redirect status.")
        return
      }
      #expect(status == 302)
    }
    #expect(transport.requests.count == 2)
    #expect(transport.requests.allSatisfy { $0.request.authority == "developer.nps.gov" })
    if items {
      #expect(try await parks.next() == nil)
    } else {
      #expect(try await pages.next() == nil)
    }
  }

  @Test(
    "Single endpoint and legacy sequences do not invent continuation", arguments: [false, true])
  func singleEndpointAndLegacySequencesDoNotInventContinuation(_ legacy: Bool) async throws {
    let transport = MockTransport(results: [.success(.ok(json: try Fixture.parksPageFirst.data()))])
    let request =
      legacy
      ? try ParkRequest.parks(parkCode: ParkCode("acad"))
      : try ParkRequest(endpoint: Endpoint.parks(query: makeQuery()))
    var iterator = try makeClient(transport).parkPages(for: request).makeAsyncIterator()
    #expect(try await iterator.next()?.total == "2")
    #expect(try await iterator.next() == nil)
    #expect(transport.requests.count == 1)
    if legacy {
      #expect(
        transport.requests.first?.request.path == "/api/v1/parks?parkCode=acad&limit=1&start=0")
    }
  }

  private func makeClient(_ transport: MockTransport) throws(NPSDataError) -> NPSDataClient {
    NPSDataClient(
      configuration: try NPSDataConfiguration(apiKey: "private-test-key"), transport: transport)
  }

  private func makeQuery() throws -> ParkQuery {
    try ParkQuery(
      limit: 1, parkCodes: [ParkCode("acad"), ParkCode("yell")], sort: [.parkCode(.ascending)])
  }
}

private struct QueryNames: Decodable, Sendable {
  struct Name: Decodable, Sendable {
    let parkCode: String
  }
  let data: [Name]
}

extension ParkRequest where Response == QueryNames {
  fileprivate static func names(query: ParkQuery) -> Self {
    guard let endpoint = Endpoint<QueryNames>(path: Endpoint.parks(query: query).path) else {
      preconditionFailure("The parks query endpoint has a validated path.")
    }
    return Self(endpoint: endpoint)
  }
}
