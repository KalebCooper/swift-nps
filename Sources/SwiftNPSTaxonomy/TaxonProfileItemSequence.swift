import SwiftNPSTaxonomyModels

/// Lazy records in provider order, buffering at most one page without deduplication.
public struct TaxonProfileItemSequence: AsyncSequence, Sendable {
  /// One provider record.
  public typealias Element = NPSTaxonProfile
  /// Typed transport and pagination failures.
  public typealias Failure = NPSTaxonomyError

  /// An independent item traversal.
  public struct Iterator: AsyncIteratorProtocol {
    /// One provider record.
    public typealias Element = NPSTaxonProfile
    /// Typed iteration failure.
    public typealias Failure = NPSTaxonomyError

    private var current = [Element]().makeIterator()
    private var finished = false
    private var pages: TaxonProfilePageSequence.Iterator

    init(pages: TaxonProfilePageSequence.Iterator) { self.pages = pages }

    /// Returns a buffered item or consumes the next page on demand.
    /// - Throws: Cancellation even with buffered items, or the page iterator's failure.
    public mutating func next(isolation actor: isolated (any Actor)? = #isolation)
      async throws(NPSTaxonomyError) -> Element?
    {
      guard !finished else { return nil }
      finished = true
      guard !Task.isCancelled else { throw .transport(.cancelled) }
      if let item = current.next() {
        finished = false
        return item
      }
      while let page = try await pages.next(isolation: actor) {
        current = page.makeIterator()
        if let item = current.next() {
          finished = false
          return item
        }
      }
      return nil
    }
  }

  private let pages: TaxonProfilePageSequence
  init(pages: TaxonProfilePageSequence) { self.pages = pages }

  /// Creates an independent iterator without I/O.
  public func makeAsyncIterator() -> Iterator { Iterator(pages: pages.makeAsyncIterator()) }
}
