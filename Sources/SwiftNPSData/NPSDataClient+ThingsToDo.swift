import SwiftNPSDataModels

extension NPSDataClient {
  /// Iterates complete things to do pages with identifiers, filters, sorting, and pagination.
  /// - Parameter query: Validated options shared by each request except its advancing offset.
  /// - Returns: A lazy sequence retaining each provider envelope and throwing ``NPSDataError``.
  public func thingToDoPages(query: ThingToDoQuery) -> NPSPageSequence<ThingToDo> {
    pages(for: .thingsToDo(query: query))
  }

  /// Iterates individual things to do, fetching the next page only when needed.
  /// - Parameter query: Validated query options, including page size and starting offset.
  /// - Returns: Things to do in provider order, without deduplication, throwing ``NPSDataError``.
  public func thingsToDo(query: ThingToDoQuery) -> NPSItemSequence<ThingToDo> {
    items(for: .thingsToDo(query: query))
  }
}
