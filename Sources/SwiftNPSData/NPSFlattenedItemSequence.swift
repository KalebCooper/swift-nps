import SwiftNPSDataModels

/// Individual values yielded lazily from collections whose items are provider groups.
///
/// Some NPS collections, such as amenity park places, return each item as an array. This sequence
/// iterates the same groups as ``NPSItemSequence`` and yields every element of every group in
/// provider order, including every element of a group holding more than one and none for an empty
/// group. It fetches a page only when the current page is exhausted, retains at most the current
/// page, and never deduplicates or reorders values. Pages remain available unflattened through
/// ``NPSPageSequence``.
///
/// ```swift
/// for try await amenity in client.amenityParkPlaces(query: query) {
///   print(amenity.name)
/// }
/// ```
public struct NPSFlattenedItemSequence<Item: Codable & Hashable & Sendable>: AsyncSequence,
  Sendable
{
  /// One value from a provider group, in the provider's result order.
  public typealias Element = Item
  /// The only failure produced by iteration.
  public typealias Failure = NPSDataError

  /// An independent iterator that consumes one page at a time.
  public struct Iterator: AsyncIteratorProtocol {
    /// One value from the current group.
    public typealias Element = Item
    /// The same typed failure as page iteration.
    public typealias Failure = NPSDataError

    private var current = [Item]().makeIterator()
    private var finished = false
    private var groups: NPSItemSequence<[Item]>.Iterator

    init(groups: NPSItemSequence<[Item]>.Iterator) {
      self.groups = groups
    }

    /// Yields a value, fetching a page only when the current page is exhausted.
    /// - Returns: The next value, or nil after completion or failure.
    /// - Throws: The same ``NPSDataError`` as page iteration, including cancellation even while
    ///   values remain buffered in the current group or page.
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
      while let group = try await groups.next(isolation: actor) {
        current = group.makeIterator()
        if let item = current.next() {
          finished = false
          return item
        }
      }
      return nil
    }
  }

  private let groups: NPSItemSequence<[Item]>

  init(groups: NPSItemSequence<[Item]>) {
    self.groups = groups
  }

  /// Creates an iterator without fetching or buffering results.
  /// - Returns: An independent traversal of the flattened values.
  public func makeAsyncIterator() -> Iterator {
    Iterator(groups: groups.makeAsyncIterator())
  }
}
