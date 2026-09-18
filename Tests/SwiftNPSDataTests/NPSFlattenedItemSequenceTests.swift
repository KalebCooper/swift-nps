import Foundation
import HTTPTesting
import SwiftNPSData
import SwiftNPSDataModels
import SwiftNPSDataTestSupport
import Testing

@Suite("Flattened item sequences", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct NPSFlattenedItemSequenceTests {
  // Constructed, not recorded: every recorded amenity group holds exactly one entry, so these
  // bodies exercise a group of two and an empty group.
  private static let groupedFirst = Data(
    #"""
    {"total":"3","limit":"2","start":"0","data":[[{"id":"A1","name":"First"},
    {"id":"A2","name":"Second"}],[]]}
    """#.utf8)
  private static let groupedLast = Data(
    #"{"total":"3","limit":"2","start":"2","data":[[{"id":"A3","name":"Third"}]]}"#.utf8)

  @Test("Cancellation before iteration sends no request")
  func cancellationBeforeIterationSendsNoRequest() async throws {
    let transport = MockTransport()
    let client = try makeClient(transport)
    let query = try AmenityParkPlacesQuery()
    await withTaskGroup(of: Void.self) { group in
      group.cancelAll()
      group.addTask {
        do throws(NPSDataError) {
          var iterator = client.amenityParkPlaces(query: query).makeAsyncIterator()
          _ = try await iterator.next()
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

  @Test("Cancellation is observed while group entries remain buffered")
  func cancellationIsObservedWhileGroupEntriesRemainBuffered() async throws {
    let transport = MockTransport(results: [.success(.ok(json: Self.groupedFirst))])
    let client = try makeClient(transport)
    let query = try AmenityParkPlacesQuery(limit: 2)
    let (ready, signalReady) = AsyncStream<Void>.makeStream()
    let (resume, finishResume) = AsyncStream<Void>.makeStream()
    defer { finishResume.finish() }
    let task = Task {
      defer { signalReady.finish() }
      var iterator = client.amenityParkPlaces(query: query).makeAsyncIterator()
      let first = try await iterator.next()
      #expect(first?.id == "A1")
      signalReady.yield()
      // The parent cancels after the first read; cancellation ends this suspended stream.
      for await _ in resume {}
      do throws(NPSDataError) {
        _ = try await iterator.next()
        Issue.record("The buffered second entry must not be yielded after cancellation.")
      } catch {
        guard case .transport(.cancelled) = error else {
          Issue.record("Expected typed cancellation.")
          return
        }
      }
      let afterCancellation = try await iterator.next()
      #expect(afterCancellation == nil)
    }
    var readiness = ready.makeAsyncIterator()
    _ = await readiness.next()
    task.cancel()
    try await task.value
    #expect(transport.requests.count == 1)
  }

  @Test("Every entry of every group is yielded lazily in provider order")
  func everyEntryOfEveryGroupIsYieldedLazilyInProviderOrder() async throws {
    let transport = MockTransport(
      results: [.success(.ok(json: Self.groupedFirst)), .success(.ok(json: Self.groupedLast))])
    let sequence = try makeClient(transport).amenityParkPlaces(
      query: AmenityParkPlacesQuery(limit: 2))
    var iterator = sequence.makeAsyncIterator()
    #expect(transport.requests.isEmpty)
    #expect(try await iterator.next()?.id == "A1")
    #expect(transport.requests.count == 1)
    #expect(try await iterator.next()?.id == "A2")
    #expect(transport.requests.count == 1)
    #expect(try await iterator.next()?.id == "A3")
    #expect(transport.requests.count == 2)
    #expect(try await iterator.next() == nil)
    #expect(try await iterator.next() == nil)
    #expect(
      transport.requests.map(\.request.path) == [
        "/api/v1/amenities/parksplaces?limit=2&start=0",
        "/api/v1/amenities/parksplaces?limit=2&start=2",
      ])
  }

  @Test("Independent iterators start at the original offset")
  func independentIteratorsStartAtTheOriginalOffset() async throws {
    let transport = MockTransport(
      results: Array(repeating: .success(.ok(json: Self.groupedFirst)), count: 2))
    let sequence = try makeClient(transport).amenityParkVisitorCenters(
      query: AmenityParkVisitorCentersQuery(limit: 2))
    var first = sequence.makeAsyncIterator()
    var second = sequence.makeAsyncIterator()
    #expect(try await first.next()?.id == "A1")
    #expect(try await first.next()?.id == "A2")
    #expect(try await second.next()?.id == "A1")
    #expect(
      transport.requests.map(\.request.path) == [
        "/api/v1/amenities/parksvisitorcenters?limit=2&start=0",
        "/api/v1/amenities/parksvisitorcenters?limit=2&start=0",
      ])
  }

  @Test("Invalid pagination metadata throws before any entry is yielded")
  func invalidPaginationMetadataThrowsBeforeAnyEntryIsYielded() async throws {
    // More groups than the reported limit is an inconsistent page.
    let body = Data(
      #"""
      {"total":"5","limit":"1","start":"0","data":[[{"id":"A1","name":"First"}],
      [{"id":"A2","name":"Second"}]]}
      """#.utf8)
    let transport = MockTransport(results: [.success(.ok(json: body))])
    var iterator = try makeClient(transport).amenityParkPlaces(
      query: AmenityParkPlacesQuery(limit: 1)
    ).makeAsyncIterator()
    do throws(NPSDataError) {
      let entry = try await iterator.next()
      Issue.record("An inconsistent page must not yield \(String(describing: entry?.id)).")
    } catch {
      guard case .pagination(.inconsistentPage) = error else {
        Issue.record("Expected a typed pagination failure.")
        return
      }
    }
    #expect(try await iterator.next() == nil)
    #expect(transport.requests.count == 1)
  }

  private func makeClient(_ transport: MockTransport) throws(NPSDataError) -> NPSDataClient {
    NPSDataClient(
      configuration: try NPSDataConfiguration(apiKey: "private-test-key"), transport: transport)
  }
}
