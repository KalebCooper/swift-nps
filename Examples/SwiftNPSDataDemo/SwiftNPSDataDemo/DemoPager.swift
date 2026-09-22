import SwiftNPSData
import SwiftNPSDataModels

/// The inputs one group's search accepts.
enum DemoFilters {
  /// Comma-separated park and state code lists with text search.
  case codeListsAndText
  /// Comma-separated park and state code lists with text search, plus gallery identifiers.
  case codeListsTextAndGalleries
  /// One optional park code and one optional road event type.
  case optionalParkCodeAndType
  /// One required park code and nothing else.
  case requiredParkCode
  /// Text search only.
  case textOnly

  /// Whether results arrive a page at a time rather than as one complete response.
  var isPaged: Bool {
    switch self {
    case .codeListsAndText, .codeListsTextAndGalleries, .textOnly: true
    case .optionalParkCodeAndType, .requiredParkCode: false
    }
  }
}

/// The endpoint groups the demo can search.
enum DemoGroup: String, CaseIterable, Identifiable {
  // Cases follow the picker's display order, with parks first as the primary group.
  case parks = "Parks"
  case alerts = "Alerts"
  case visitorCenters = "Visitor Centers"
  case campgrounds = "Campgrounds"
  case thingsToDo = "Things to Do"
  case amenities = "Amenities"
  case places = "Places"
  case tours = "Tours"
  case webcams = "Webcams"
  case articles = "Articles"
  case newsReleases = "News Releases"
  case people = "People"
  case parkAudio = "Park Audio"
  case parkVideos = "Park Videos"
  case photoGalleries = "Photo Galleries"
  case photoGalleryAssets = "Photo Gallery Assets"
  case roadEvents = "Road Events"
  case parkBoundaries = "Park Boundaries"

  /// Names what a result's second line holds, read before its value by assistive technology.
  ///
  /// Amenities show a name alone, so they name nothing.
  var detailLabel: String? {
    switch self {
    case .alerts, .campgrounds, .parks, .tours, .visitorCenters: "Park code"
    case .amenities: nil
    case .newsReleases: "Release date"
    case .parkBoundaries: "Geometry type"
    case .articles, .parkAudio, .parkVideos, .people, .photoGalleries, .photoGalleryAssets, .places,
      .thingsToDo, .webcams:
      "Related park codes"
    case .roadEvents: "Road event type"
    }
  }

  /// The search inputs this group accepts.
  var filters: DemoFilters {
    switch self {
    case .alerts, .articles, .campgrounds, .newsReleases, .parkAudio, .parkVideos, .parks, .people,
      .photoGalleries, .places, .thingsToDo, .tours, .visitorCenters, .webcams:
      .codeListsAndText
    case .photoGalleryAssets:
      .codeListsTextAndGalleries
    case .amenities:
      .textOnly
    case .parkBoundaries:
      .requiredParkCode
    case .roadEvents:
      .optionalParkCodeAndType
    }
  }

  var id: Self { self }

  /// The plural noun used in status messages.
  var noun: String { rawValue.lowercased() }
}

/// One result shown by the demo: a display name and an optional second line, such as a park code,
/// a release date, a road event type, or a boundary's geometry type.
struct ResultRow {
  let detail: String?
  let title: String
}

/// One loaded page, reduced to rows.
struct ResultPage {
  let hasMore: Bool
  let rows: [ResultRow]
  /// The provider's total, kept as the string NPS sends.
  let total: String
}

/// How the demo reads one group: a page at a time, or as one complete response.
enum DemoLoad {
  case pages(any ResultPaging)
  case single(() async throws(NPSDataError) -> [ResultRow])
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
