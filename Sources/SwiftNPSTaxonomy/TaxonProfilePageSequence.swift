import HTTPCore
import SwiftNPSTaxonomyModels

/// Lazy bare-array pages with checked continuation, independent iterators and no prefetch.
/// The terminal empty page is observable; endpoint-only requests yield exactly one response.
public struct TaxonProfilePageSequence: AsyncSequence, Sendable {
  /// One unmodified provider array.
  public typealias Element = [NPSTaxonProfile]
  /// Typed transport and pagination failures.
  public typealias Failure = NPSTaxonomyError

  /// An independent traversal retaining its current query.
  public struct Iterator: AsyncIteratorProtocol {
    /// One provider array.
    public typealias Element = [NPSTaxonProfile]
    /// Typed iteration failure.
    public typealias Failure = NPSTaxonomyError

    private var base: PageSequence<Element>.Iterator
    private var finished = false
    private var query: TaxonProfileQuery?

    init(base: PageSequence<Element>.Iterator, query: TaxonProfileQuery?) {
      self.base = base
      self.query = query
    }

    /// Fetches and validates one response. Any failure permanently ends this iterator.
    /// - Throws: All mode before I/O, invalid pages before yielding, or transport/cancellation.
    public mutating func next(isolation actor: isolated (any Actor)? = #isolation)
      async throws(NPSTaxonomyError) -> Element?
    {
      guard !finished else { return nil }
      finished = true
      guard !Task.isCancelled else { throw .transport(.cancelled) }
      if let query, query.paging == .all { throw .pagination(.allModeUnavailable) }
      let response: DecodedResponse<Element>
      do throws(TransportError) {
        guard let page = try await base.next(isolation: actor) else { return nil }
        response = page
      } catch { throw .transport(error) }
      guard !Task.isCancelled else { throw .transport(.cancelled) }
      if let query {
        do { self.query = try query.next(after: response.value) } catch { throw .pagination(error) }
        finished = self.query == nil
      }
      return response.value
    }
  }

  private let base: PageSequence<Element>
  private let query: TaxonProfileQuery?

  init(base: PageSequence<Element>, query: TaxonProfileQuery?) {
    self.base = base
    self.query = query
  }

  /// Creates an independent traversal without sending a request.
  public func makeAsyncIterator() -> Iterator {
    Iterator(base: base.makeAsyncIterator(), query: query)
  }
}
