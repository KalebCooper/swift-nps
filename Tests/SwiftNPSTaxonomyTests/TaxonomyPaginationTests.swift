import Foundation
import HTTPCore
import HTTPTesting
import SwiftNPSDataTestSupport
import SwiftNPSTaxonomy
import SwiftNPSTaxonomyModels
import Testing

@Suite("Taxonomy pagination", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct TaxonomyPaginationTests {
  @Test("All mode fails before I/O while endpoint-only empty responses remain observable")
  func allAndEndpointOnly() async throws {
    let transport = MockTransport(results: [
      .success(.ok(json: Data("[]".utf8))), .success(.ok(json: Data("[]".utf8))),
    ])
    let client = NPSTaxonomyClient(transport: transport)
    let search = TaxonSearch.commonName("osprey", category: nil, source: nil)
    var basic = client.taxonSummaryPages(query: try TaxonSummaryQuery(search: search))
      .makeAsyncIterator()
    var profile = client.taxonProfilePages(query: try TaxonProfileQuery(search: search))
      .makeAsyncIterator()
    do { _ = try await basic.next(); Issue.record("All mode must fail") } catch {
      guard case .pagination(.allModeUnavailable) = error else {
        Issue.record("Wrong failure"); return
      }
    }
    do { _ = try await profile.next(); Issue.record("All mode must fail") } catch {
      guard case .pagination(.allModeUnavailable) = error else {
        Issue.record("Wrong failure"); return
      }
    }
    #expect(try await basic.next() == nil && transport.requests.isEmpty)
    let endpoint = TaxonomyEndpoint.taxonSummariesResponse(
      query: try TaxonSummaryQuery(search: search))
    var single = client.pages(for: NPSTaxonomyRequest(endpoint: endpoint)).makeAsyncIterator()
    #expect(try await single.next()?.isEmpty == true)
    #expect(try await single.next() == nil)
    let profileEndpoint = TaxonomyEndpoint.taxonProfilesResponse(
      query: try TaxonProfileQuery(search: search))
    var singleProfile = client.pages(for: NPSTaxonomyRequest(endpoint: profileEndpoint))
      .makeAsyncIterator()
    #expect(try await singleProfile.next()?.isEmpty == true)
    #expect(try await singleProfile.next() == nil)
    #expect(transport.requests.count == 2)
  }

  @Test("Cancelled lazy reads never reach transport")
  func cancellationBeforeLazyRead() async throws {
    let transport = MockTransport()
    let query = try TaxonSummaryQuery(
      paging: .page(size: 1, startIndex: 0),
      search: .codes(["81838"], kind: .nps, submission: .post))
    let profileQuery = try TaxonProfileQuery(
      paging: .page(size: 1, startIndex: 0),
      search: .codes(["81838"], kind: .itis, submission: .get))
    await withTaskGroup(of: Void.self) { group in
      group.cancelAll()
      group.addTask {
        var basic = NPSTaxonomyClient(transport: transport).taxonSummaryPages(query: query)
          .makeAsyncIterator()
        var profile = NPSTaxonomyClient(transport: transport).taxonProfilePages(query: profileQuery)
          .makeAsyncIterator()
        do { _ = try await basic.next(); Issue.record("Cancelled work must fail") } catch {
          guard case NPSTaxonomyError.transport(.cancelled) = error else {
            Issue.record("Wrong failure"); return
          }
        }
        do { _ = try await profile.next(); Issue.record("Cancelled work must fail") } catch {
          guard case NPSTaxonomyError.transport(.cancelled) = error else {
            Issue.record("Wrong failure"); return
          }
        }
      }
    }
    #expect(transport.requests.isEmpty)
  }

  @Test("Iterators independently include a terminal empty page")
  func independentIterators() async throws {
    let first = try IRMAFixture.taxonomyCommonSummaries.data()
    let empty = Data("[]".utf8)
    let transport = MockTransport(results: [
      .success(.ok(json: first)), .success(.ok(json: empty)),
      .success(.ok(json: first)), .success(.ok(json: empty)),
    ])
    let client = NPSTaxonomyClient(transport: transport)
    let query = try TaxonSummaryQuery(
      paging: .page(size: 1, startIndex: 0),
      search: .commonName("osprey", category: nil, source: nil))
    let pages = client.taxonSummaryPages(query: query)
    #expect(transport.requests.isEmpty)
    var a = pages.makeAsyncIterator()
    #expect(try await a.next()?.count == 1)
    #expect(try await a.next()?.isEmpty == true)
    #expect(try await a.next() == nil)
    var b = pages.makeAsyncIterator()
    #expect(try await b.next()?.count == 1)
    #expect(try await b.next()?.isEmpty == true)
    #expect(try await b.next() == nil)
    #expect(transport.requests.count == 4)
  }

  @Test("Profile items observe cancellation while a duplicate remains buffered")
  func profileBufferedCancellation() async throws {
    let first = try IRMAFixture.taxonomyCommonProfiles.data()
    let records = try JSONDecoder().decode([NPSTaxonProfile].self, from: first)
    let body = try JSONEncoder().encode(records + records)
    let transport = MockTransport(results: [.success(.ok(json: body))])
    let entered = AsyncStream<Void>.makeStream()
    let resume = AsyncStream<Void>.makeStream()
    let task = Task { () -> Bool in
      var items = NPSTaxonomyClient(transport: transport).taxonProfiles(
        query:
          try TaxonProfileQuery(
            paging: .page(size: 2, startIndex: 0),
            search: .commonName("osprey", category: nil, source: nil))
      ).makeAsyncIterator()
      _ = try await items.next()
      entered.continuation.yield(())
      var gate = resume.stream.makeAsyncIterator()
      _ = await gate.next()
      do { _ = try await items.next(); return false } catch {
        if case NPSTaxonomyError.transport(.cancelled) = error {
          return try await items.next() == nil
        };
        return false
      }
    }
    var gate = entered.stream.makeAsyncIterator()
    _ = await gate.next()
    task.cancel()
    resume.continuation.yield(())
    resume.continuation.finish()
    entered.continuation.finish()
    #expect(try await task.value)
    #expect(transport.requests.count == 1)
  }

  @Test("Profile failures and invalid pages terminate without yielding", arguments: [0, 1, 2, 3])
  func profileFailures(_ scenario: Int) async throws {
    let original = try IRMAFixture.taxonomyCommonProfiles.data()
    let rows = try JSONDecoder().decode([NPSTaxonProfile].self, from: original)
    let answer: Response
    switch scenario {
    case 0: answer = .ok(json: Data("malformed".utf8))
    case 1: answer = Response(body: Data("failure".utf8), status: .badRequest)
    case 2: answer = .ok(json: try JSONEncoder().encode(rows + rows))
    default: answer = .ok(json: original)
    }
    let transport = MockTransport(results: [.success(answer)])
    var pages = NPSTaxonomyClient(transport: transport).taxonProfilePages(
      query:
        try TaxonProfileQuery(
          paging: .page(size: 1, startIndex: scenario == 3 ? Int(Int32.max) : 0),
          search: .codes(["81838"], kind: .nps, submission: .post))
    ).makeAsyncIterator()
    do { _ = try await pages.next(); Issue.record("Invalid response must not be yielded") } catch {
      switch (scenario, error) {
      case (0, .transport(.decode)), (1, .transport(.httpStatus)), (2, .pagination(.oversizedPage)),
        (3, .pagination(.indexOverflow)):
        break
      default: Issue.record("Wrong failure")
      }
    }
    #expect(try await pages.next() == nil)
    #expect(transport.requests.count == 1)
  }

  @Test("Profile iterators independently include a terminal empty page")
  func profileIndependentIterators() async throws {
    let first = try IRMAFixture.taxonomyCommonProfiles.data()
    let empty = Data("[]".utf8)
    let transport = MockTransport(results: [
      .success(.ok(json: first)), .success(.ok(json: empty)),
      .success(.ok(json: first)), .success(.ok(json: empty)),
    ])
    let client = NPSTaxonomyClient(transport: transport)
    let query = try TaxonProfileQuery(
      paging: .page(size: 1, startIndex: 0),
      search: .commonName("osprey", category: nil, source: nil))
    let pages = client.taxonProfilePages(query: query)
    #expect(transport.requests.isEmpty)
    var a = pages.makeAsyncIterator()
    #expect(try await a.next()?.count == 1)
    #expect(try await a.next()?.isEmpty == true)
    #expect(try await a.next() == nil)
    var b = pages.makeAsyncIterator()
    #expect(try await b.next()?.count == 1)
    #expect(try await b.next()?.isEmpty == true)
    #expect(try await b.next() == nil)
    #expect(transport.requests.count == 4)
  }

  @Test("Profile short pages continue and duplicate records survive early break")
  func profileShortPagesAndEarlyBreak() async throws {
    let first = try IRMAFixture.taxonomyCommonProfiles.data()
    let transport = MockTransport(results: [
      .success(.ok(json: first)), .success(.ok(json: first)), .success(.ok(json: Data("[]".utf8))),
    ])
    let client = NPSTaxonomyClient(transport: transport)
    let query = try TaxonProfileQuery(
      paging: .page(size: 2, startIndex: 0),
      search: .commonName("osprey", category: "Bird", source: "ITIS"))
    var records: [NPSTaxonProfile] = []
    for try await value in client.taxonProfiles(query: query) { records.append(value) }
    #expect(records.count == 2 && records[0] == records[1])
    #expect(transport.requests.count == 3)
    #expect(
      transport.requests[1].request.path?.hasSuffix("pageSize=2&source=ITIS&startIndex=1") == true)
    let stopped = MockTransport(results: [.success(.ok(json: first))])
    for try await _ in NPSTaxonomyClient(transport: stopped).taxonProfiles(query: query) { break }
    #expect(stopped.requests.count == 1)
  }

  @Test("Scientific-name continuation retains encoded text and filters for both representations")
  func scientificNameContinuation() async throws {
    let basic = try IRMAFixture.taxonomyScientificPageBasic.data()
    let profile = try IRMAFixture.taxonomyScientificPageProfile.data()
    let empty = Data("[]".utf8)
    let transport = MockTransport(results: [
      .success(.ok(json: basic)), .success(.ok(json: empty)),
      .success(.ok(json: profile)), .success(.ok(json: empty)),
    ])
    let client = NPSTaxonomyClient(transport: transport)
    let search = TaxonSearch.scientificName("Bankia schrencki", category: nil, source: "ITIS")
    var basicCount = 0
    for try await row in client.taxonSummaries(
      query: try TaxonSummaryQuery(
        paging: .page(size: 2, startIndex: 0), search: search))
    {
      #expect(row.taxonCode == "719252")
      basicCount += 1
    }
    var profileCount = 0
    for try await row in client.taxonProfiles(
      query: try TaxonProfileQuery(
        deriveIfBroken: false, paging: .page(size: 2, startIndex: 0), search: search))
    {
      #expect(row.taxonCode == "719252")
      profileCount += 1
    }
    #expect(basicCount == 1 && profileCount == 1)
    #expect(
      transport.requests[1].request.path
        == "/taxonomy/v2/rest/searchByScientificName/Bankia%20schrencki?detail=basic&format=json&pageSize=2&source=ITIS&startIndex=1"
    )
    #expect(
      transport.requests[3].request.path
        == "/taxonomy/v2/rest/searchByScientificName/Bankia%20schrencki?deriveIfBroken=false&detail=profile&format=json&pageSize=2&source=ITIS&startIndex=1"
    )
  }

  @Test("Summary items observe cancellation while a duplicate remains buffered")
  func summaryBufferedCancellation() async throws {
    let first = try IRMAFixture.taxonomyCommonSummaries.data()
    let records = try JSONDecoder().decode([NPSTaxonSummary].self, from: first)
    let body = try JSONEncoder().encode(records + records)
    let transport = MockTransport(results: [.success(.ok(json: body))])
    let entered = AsyncStream<Void>.makeStream()
    let resume = AsyncStream<Void>.makeStream()
    let task = Task { () -> Bool in
      var items = NPSTaxonomyClient(transport: transport).taxonSummaries(
        query:
          try TaxonSummaryQuery(
            paging: .page(size: 2, startIndex: 0),
            search: .commonName("osprey", category: nil, source: nil))
      ).makeAsyncIterator()
      _ = try await items.next()
      entered.continuation.yield(())
      var gate = resume.stream.makeAsyncIterator()
      _ = await gate.next()
      do { _ = try await items.next(); return false } catch {
        if case NPSTaxonomyError.transport(.cancelled) = error {
          return try await items.next() == nil
        };
        return false
      }
    }
    var gate = entered.stream.makeAsyncIterator()
    _ = await gate.next()
    task.cancel()
    resume.continuation.yield(())
    resume.continuation.finish()
    entered.continuation.finish()
    #expect(try await task.value)
    #expect(transport.requests.count == 1)
  }

  @Test("Summary failures and invalid pages terminate without yielding", arguments: [0, 1, 2, 3])
  func summaryFailures(_ scenario: Int) async throws {
    let original = try IRMAFixture.taxonomyCommonSummaries.data()
    let rows = try JSONDecoder().decode([NPSTaxonSummary].self, from: original)
    let answer: Response
    switch scenario {
    case 0: answer = .ok(json: Data("malformed".utf8))
    case 1: answer = Response(body: Data("failure".utf8), status: .badRequest)
    case 2: answer = .ok(json: try JSONEncoder().encode(rows + rows))
    default: answer = .ok(json: original)
    }
    let transport = MockTransport(results: [.success(answer)])
    var pages = NPSTaxonomyClient(transport: transport).taxonSummaryPages(
      query:
        try TaxonSummaryQuery(
          paging: .page(size: 1, startIndex: scenario == 3 ? Int(Int32.max) : 0),
          search: .codes(["81838"], kind: .nps, submission: .post))
    ).makeAsyncIterator()
    do { _ = try await pages.next(); Issue.record("Invalid response must not be yielded") } catch {
      switch (scenario, error) {
      case (0, .transport(.decode)), (1, .transport(.httpStatus)), (2, .pagination(.oversizedPage)),
        (3, .pagination(.indexOverflow)):
        break
      default: Issue.record("Wrong failure")
      }
    }
    #expect(try await pages.next() == nil)
    #expect(transport.requests.count == 1)
  }

  @Test("Summary short pages continue and duplicate records survive early break")
  func summaryShortPagesAndEarlyBreak() async throws {
    let first = try IRMAFixture.taxonomyCommonSummaries.data()
    let transport = MockTransport(results: [
      .success(.ok(json: first)), .success(.ok(json: first)), .success(.ok(json: Data("[]".utf8))),
    ])
    let client = NPSTaxonomyClient(transport: transport)
    let query = try TaxonSummaryQuery(
      paging: .page(size: 2, startIndex: 0),
      search: .commonName("osprey", category: "Bird", source: "ITIS"))
    var records: [NPSTaxonSummary] = []
    for try await value in client.taxonSummaries(query: query) { records.append(value) }
    #expect(records.count == 2 && records[0] == records[1])
    #expect(transport.requests.count == 3)
    #expect(
      transport.requests[1].request.path?.hasSuffix("pageSize=2&source=ITIS&startIndex=1") == true)
    let stopped = MockTransport(results: [.success(.ok(json: first))])
    for try await _ in NPSTaxonomyClient(transport: stopped).taxonSummaries(query: query) { break }
    #expect(stopped.requests.count == 1)
  }
}
