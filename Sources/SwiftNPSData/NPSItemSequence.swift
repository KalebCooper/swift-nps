import SwiftNPSDataModels

/// Individual collection items yielded lazily from the same pages as ``NPSPageSequence``.
///
/// Fetches a whole page, yields its items in provider order, then fetches another page only when
/// needed. It retains at most the current page and never deduplicates or reorders items.
///
/// ```swift
/// for try await park in client.parks(query: query) {
///   print(park.fullName)
/// }
/// ```
public struct NPSItemSequence<Item: Codable & Hashable & Sendable>: AsyncSequence, Sendable {
  /// One item in the provider's result order.
  public typealias Element = Item
  /// The only failure produced by iteration.
  public typealias Failure = NPSDataError

  /// An independent iterator that consumes one page at a time.
  public struct Iterator: AsyncIteratorProtocol {
    /// One item from the current page.
    public typealias Element = Item
    /// The same typed failure as page iteration.
    public typealias Failure = NPSDataError

    private var current = [Item]().makeIterator()
    private var finished = false
    private var pages: NPSPageSequence<Item>.Iterator

    init(pages: NPSPageSequence<Item>.Iterator) {
      self.pages = pages
    }

    /// Yields an item, fetching a page only when the current page is exhausted.
    /// - Returns: The next item, or nil after completion or failure.
    /// - Throws: The same ``NPSDataError`` as page iteration, including cancellation even while
    ///   items remain buffered in the current page.
    public mutating func next(
      isolation actor: isolated (any Actor)? = #isolation
    ) async throws(NPSDataError) -> Item? {
      guard !finished else { return nil }
      finished = true
      guard !Task.isCancelled else { throw .transport(.cancelled) }
      if let item = current.next() {
        finished = false
        return item
      }
      while let page = try await pages.next(isolation: actor) {
        current = page.data.makeIterator()
        if let item = current.next() {
          finished = false
          return item
        }
      }
      return nil
    }
  }

  private let pages: NPSPageSequence<Item>

  init(pages: NPSPageSequence<Item>) {
    self.pages = pages
  }

  /// Creates an iterator without fetching or buffering results.
  /// - Returns: An independent item traversal.
  public func makeAsyncIterator() -> Iterator {
    Iterator(pages: pages.makeAsyncIterator())
  }
}
