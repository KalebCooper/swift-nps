import HTTPCore
import SwiftNPSDataModels

/// Lazy event pages in provider order, with no prefetch or deduplication.
///
/// Ordinary event requests validate page-number metadata before yielding. Expanded request-based
/// traversal fails before sending because the provider does not expose reliable continuation.
/// Endpoint-only requests yield exactly one response, including a bare expanded array.
public struct ParkEventPageSequence: AsyncSequence, Sendable {
  /// One unmodified provider response.
  public typealias Element = ParkEventCollection
  /// The only failure produced by iteration.
  public typealias Failure = NPSDataError

  /// An independent traversal starting at the original query page number.
  public struct Iterator: AsyncIteratorProtocol {
    /// One provider response.
    public typealias Element = ParkEventCollection
    /// The typed iteration failure.
    public typealias Failure = NPSDataError

    private var base: PageSequence<ParkEventCollection>.Iterator
    private var finished = false
    private var resolution: ParkEventResolution<ParkEventCollection>?

    init(
      base: PageSequence<ParkEventCollection>.Iterator,
      resolution: ParkEventResolution<ParkEventCollection>?
    ) {
      self.base = base
      self.resolution = resolution
    }

    /// Fetches and validates one page. Completion or any failure permanently ends this iterator.
    /// - Returns: The next provider response, or nil after completion or failure.
    /// - Throws: Cancellation, transport, service, or pagination errors. Invalid pages are not yielded.
    public mutating func next(
      isolation actor: isolated (any Actor)? = #isolation
    ) async throws(NPSDataError) -> ParkEventCollection? {
      guard !finished else { return nil }
      finished = true
      guard !Task.isCancelled else { throw .transport(.cancelled) }
      guard resolution?.query.expandRecurring != true else {
        throw .pagination(.eventExpansionUnavailable)
      }
      let response: DecodedResponse<ParkEventCollection>
      do throws(TransportError) {
        guard let page = try await base.next(isolation: actor) else { return nil }
        response = page
      } catch {
        throw NPSDataError(error)
      }
      guard !Task.isCancelled else { throw .transport(.cancelled) }
      if let page = response.value.page, !page.errors.isEmpty {
        throw .eventService(response)
      }
      if let resolution {
        do {
          self.resolution = try resolution.next(after: response.value)
        } catch {
          throw .pagination(error)
        }
        finished = self.resolution == nil
      }
      return response.value
    }
  }

  private let base: PageSequence<ParkEventCollection>
  private let resolution: ParkEventResolution<ParkEventCollection>?

  init(
    base: PageSequence<ParkEventCollection>,
    resolution: ParkEventResolution<ParkEventCollection>?
  ) {
    self.base = base
    self.resolution = resolution
  }

  /// Creates an independent iterator without sending a request.
  public func makeAsyncIterator() -> Iterator {
    Iterator(base: base.makeAsyncIterator(), resolution: resolution)
  }
}
