import SwiftNPSData
import SwiftNPSDataModels

/// The endpoint groups the demo can search.
enum DemoGroup: String, CaseIterable, Identifiable {
  // Cases follow the picker's display order, with parks first as the primary group.
  case parks = "Parks"
  case alerts = "Alerts"
  case visitorCenters = "Visitor Centers"
  case campgrounds = "Campgrounds"
  case thingsToDo = "Things to Do"
  case amenities = "Amenities"

  /// Whether the group's query accepts park and state codes.
  var filtersByCode: Bool { self != .amenities }

  var id: Self { self }

  /// The plural noun used in status messages.
  var noun: String { rawValue.lowercased() }
}

/// One result shown by the demo: a display name and, where the item has one, a park code.
struct ResultRow {
  let parkCode: String?
  let title: String
}

/// One loaded page, reduced to rows.
struct ResultPage {
  let hasMore: Bool
  let rows: [ResultRow]
  /// The provider's total, kept as the string NPS sends.
  let total: String
}

/// Loads one page per call, so the view can show any group through a single stored value.
protocol ResultPaging {
  mutating func nextPage() async throws(NPSDataError) -> ResultPage?
}

/// Pages through one collection query on demand, validating continuation metadata before rows
/// are shown.
struct DemoPager<Query: NPSCollectionQuery>: ResultPaging {
  private var iterator: NPSPageSequence<Query.Item>.Iterator
  private var nextQuery: Query?
  private let row: (Query.Item) -> ResultRow

  init(
    pages: NPSPageSequence<Query.Item>, query: Query, row: @escaping (Query.Item) -> ResultRow
  ) {
    iterator = pages.makeAsyncIterator()
    nextQuery = query
    self.row = row
  }

  mutating func nextPage() async throws(NPSDataError) -> ResultPage? {
    // The iterator is advanced through a local copy because main actor isolated storage cannot be
    // mutated across the suspension point.
    var pages = iterator
    guard let query = nextQuery, let page = try await pages.next() else { return nil }
    iterator = pages
    guard !Task.isCancelled else { throw .transport(.cancelled) }
    let following: Query?
    do throws(NPSPaginationError) {
      following = try query.next(after: page)
    } catch {
      throw .pagination(error)
    }
    nextQuery = following
    return ResultPage(hasMore: following != nil, rows: page.data.map(row), total: page.total)
  }
}
