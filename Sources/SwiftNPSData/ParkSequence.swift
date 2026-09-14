import SwiftNPSDataModels

/// Individual parks yielded lazily from the same pages as ``ParkPageSequence``.
///
/// Fetches a whole page, yields its parks in provider order, then fetches another page only when
/// needed. It retains at most the current page and never deduplicates or reorders parks.
///
/// ```swift
/// for try await park in client.parks(query: query) {
///   print(park.fullName)
/// }
/// ```
public struct ParkSequence: AsyncSequence, Sendable {
  /// One park in the provider's result order.
  public typealias Element = Park
  /// The only failure produced by iteration.
  public typealias Failure = NPSDataError

  /// An independent iterator that consumes one page at a time.
  public struct Iterator: AsyncIteratorProtocol {
    /// One park from the current page.
    public typealias Element = Park
    /// The same typed failure as page iteration.
    public typealias Failure = NPSDataError

    private var current = [Park]().makeIterator()
    private var finished = false
    private var pages: ParkPageSequence.Iterator

    init(pages: ParkPageSequence.Iterator) {
      self.pages = pages
    }

    /// Yields a park, fetching a page only when the current page is exhausted.
    /// - Returns: The next park, or nil after completion or failure.
    /// - Throws: The same ``NPSDataError`` as page iteration, including cancellation even while
    ///   parks remain buffered in the current page.
    public mutating func next(
      isolation actor: isolated (any Actor)? = #isolation
    ) async throws(NPSDataError) -> Park? {
      guard !finished else { return nil }
      finished = true
      guard !Task.isCancelled else { throw .transport(.cancelled) }
      if let park = current.next() {
        finished = false
        return park
      }
      while let page = try await pages.next(isolation: actor) {
        current = page.data.makeIterator()
        if let park = current.next() {
          finished = false
          return park
        }
      }
      return nil
    }
  }

  private let pages: ParkPageSequence

  init(pages: ParkPageSequence) {
    self.pages = pages
  }

  /// Creates an iterator without fetching or buffering results.
  /// - Returns: An independent park traversal.
  public func makeAsyncIterator() -> Iterator {
    Iterator(pages: pages.makeAsyncIterator())
  }
}
