#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

/// One GET operation relative to `https://developer.nps.gov/api/v1`, with its response type.
///
/// Construction does no I/O. A custom executor sends ``path`` with `Accept: application/json`
/// and its own `X-Api-Key` header, then decodes `Response`. Credentials never belong in this value.
///
/// ```swift
/// let endpoint = Endpoint.parks(parkCode: try ParkCode("acad"))
/// print(endpoint.path) // "/parks?parkCode=acad&limit=1&start=0"
/// ```
public struct Endpoint<Response>: Hashable, Sendable {
  /// The encoded path and query relative to the API base, starting with one slash.
  public let path: String

  /// Accepts an absolute HTTPS NPS API link without credentials or a fragment.
  ///
  /// Only `developer.nps.gov`, port 443 or no port, and paths below `/api/v1/` are accepted.
  /// Public website and image links are not API endpoints. Encoded paths and queries are retained.
  /// - Parameter link: A provider link to interpret with a consumer-defined response type.
  public init?(link: URL) {
    guard let components = URLComponents(url: link, resolvingAgainstBaseURL: false),
      components.scheme?.lowercased() == "https",
      components.host?.lowercased() == "developer.nps.gov",
      components.port == nil || components.port == 443,
      components.user == nil, components.password == nil,
      components.fragment == nil,
      components.percentEncodedPath.hasPrefix("/api/v1/")
    else { return nil }
    let query = components.percentEncodedQuery.map { "?" + $0 } ?? ""
    self.init(path: String(components.percentEncodedPath.dropFirst("/api/v1".count)) + query)
  }

  /// Accepts an encoded relative API path for a consumer-defined response.
  ///
  /// Rejects absolute URLs, fragments, traversal segments, backslashes, whitespace, and
  /// `api_key` query parameters. The path cannot escape the configured API origin.
  /// - Parameter path: A path such as `/parks?parkCode=acad&limit=1&start=0`.
  public init?(path: String) {
    guard path.hasPrefix("/"), !path.hasPrefix("//"),
      path.utf8.allSatisfy({ (33...126).contains($0) }),
      let components = URLComponents(string: path),
      components.scheme == nil, components.host == nil,
      components.fragment == nil,
      components.percentEncodedPath == String(path.split(separator: "?", maxSplits: 1)[0]),
      !components.path.contains("\\"),
      !components.path.hasPrefix("//"),
      !components.path.split(separator: "/").contains(where: { $0 == "." || $0 == ".." }),
      !(components.queryItems ?? []).contains(where: { $0.name.lowercased() == "api_key" })
    else { return nil }
    self.path = path
  }
}

extension Endpoint {
  /// Describes one page of any offset-paginated collection from its validated query.
  ///
  /// Parameters are serialized in name order, each value percent-encoded and list values joined
  /// with commas, so equal queries always produce identical paths.
  /// - Parameter query: A validated collection query, including its explicit limit and start.
  /// - Returns: One endpoint returning the complete ``NPSCollection`` envelope for the page.
  public static func collection<Query: NPSCollectionQuery>(
    _ query: Query
  ) -> Self where Response == NPSCollection<Query.Item> {
    let items = query.queryItems.sorted { $0.name < $1.name }.map(\.encoded)
    guard let endpoint = Self(path: Query.path + "?" + items.joined(separator: "&")) else {
      preconditionFailure(
        "Validated query values and percent-encoded parameters form a relative endpoint.")
    }
    return endpoint
  }
}

extension Endpoint where Response == NPSCollection<ParkAlert> {
  /// Describes one alerts page with filters, text search, and explicit pagination.
  ///
  /// ```swift
  /// let endpoint = Endpoint.alerts(query: try AlertQuery(limit: 2, parkCodes: [ParkCode("acad")]))
  /// print(endpoint.path) // "/alerts?limit=2&parkCode=acad&start=0"
  /// ```
  /// - Parameter query: Validated options, encoded without changing their values or order.
  /// - Returns: One endpoint returning the complete ``NPSCollection`` envelope, the same as
  ///   ``collection(_:)``.
  public static func alerts(query: AlertQuery) -> Self {
    collection(query)
  }
}

extension Endpoint where Response == NPSCollection<Amenity> {
  /// Describes one amenities page with identifiers, text search, and explicit pagination.
  ///
  /// ```swift
  /// let endpoint = Endpoint.amenities(query: try AmenityQuery(limit: 2, searchText: "restroom"))
  /// print(endpoint.path) // "/amenities?limit=2&q=restroom&start=0"
  /// ```
  /// - Parameter query: Validated options, encoded without changing their values or order.
  /// - Returns: One endpoint returning the complete ``NPSCollection`` envelope, the same as
  ///   ``collection(_:)``.
  public static func amenities(query: AmenityQuery) -> Self {
    collection(query)
  }
}

extension Endpoint where Response == NPSCollection<[AmenityParkPlaces]> {
  /// Describes one amenity park places page with identifiers, filters, sorting, and pagination.
  ///
  /// Each element of the page's `data` is the provider's per-amenity group, kept as sent.
  ///
  /// ```swift
  /// let query = try AmenityParkPlacesQuery(limit: 1, parkCodes: [ParkCode("acad")])
  /// print(Endpoint.amenityParkPlaces(query: query).path)
  /// // "/amenities/parksplaces?limit=1&parkCode=acad&start=0"
  /// ```
  /// - Parameter query: Validated options, encoded without changing their values or order.
  /// - Returns: One endpoint returning the complete ``NPSCollection`` envelope, the same as
  ///   ``collection(_:)``.
  public static func amenityParkPlaces(query: AmenityParkPlacesQuery) -> Self {
    collection(query)
  }
}

extension Endpoint where Response == NPSCollection<[AmenityParkVisitorCenters]> {
  /// Describes one amenity park visitor centers page with identifiers, filters, sorting, and
  /// pagination.
  ///
  /// Each element of the page's `data` is the provider's per-amenity group, kept as sent.
  ///
  /// ```swift
  /// let query = try AmenityParkVisitorCentersQuery(limit: 1, parkCodes: [ParkCode("acad")])
  /// print(Endpoint.amenityParkVisitorCenters(query: query).path)
  /// // "/amenities/parksvisitorcenters?limit=1&parkCode=acad&start=0"
  /// ```
  /// - Parameter query: Validated options, encoded without changing their values or order.
  /// - Returns: One endpoint returning the complete ``NPSCollection`` envelope, the same as
  ///   ``collection(_:)``.
  public static func amenityParkVisitorCenters(query: AmenityParkVisitorCentersQuery) -> Self {
    collection(query)
  }
}

extension Endpoint where Response == NPSCollection<Campground> {
  /// Describes one campgrounds page with filters, text search, sorting, and pagination.
  ///
  /// ```swift
  /// let query = try CampgroundQuery(
  ///   limit: 1, parkCodes: [ParkCode("acad")], sort: [.ascending("name")])
  /// print(Endpoint.campgrounds(query: query).path)
  /// // "/campgrounds?limit=1&parkCode=acad&sort=name&start=0"
  /// ```
  /// - Parameter query: Validated options, encoded without changing their values or order.
  /// - Returns: One endpoint returning the complete ``NPSCollection`` envelope, the same as
  ///   ``collection(_:)``.
  public static func campgrounds(query: CampgroundQuery) -> Self {
    collection(query)
  }
}

extension Endpoint where Response == ParkBoundary {
  /// Describes one park's boundary as a GeoJSON feature collection.
  ///
  /// The park code is a path segment and the operation takes no query parameters. The response is
  /// one value with no pagination. The provider matched codes case-insensitively in the recordings,
  /// and an unknown code returns HTTP 404 with an `application/problem+json` body rather than the
  /// NPS error envelope.
  ///
  /// ```swift
  /// let endpoint = Endpoint.parkBoundary(parkCode: try ParkCode("drto"))
  /// print(endpoint.path) // "/mapdata/parkboundaries/drto"
  /// ```
  /// - Parameter parkCode: The park whose boundary is described, sent as given.
  /// - Returns: One endpoint returning the complete ``ParkBoundary``.
  public static func parkBoundary(parkCode: ParkCode) -> Self {
    guard let endpoint = Self(path: "/mapdata/parkboundaries/" + parkCode.rawValue) else {
      preconditionFailure("A validated park code forms a relative endpoint path segment.")
    }
    return endpoint
  }
}

extension Endpoint where Response == NPSCollection<Park> {
  /// Looks up one code using `/parks`, explicitly requesting one result starting at zero.
  ///
  /// The provider envelope is retained, including an empty data array for an unknown code.
  /// No subsequent page is fetched and no result is selected from the response.
  /// - Parameter parkCode: A validated single park code.
  /// - Returns: A transport-independent endpoint returning ``NPSCollection`` of ``Park``.
  public static func parks(parkCode: ParkCode) -> Self {
    guard let endpoint = Self(path: "/parks?parkCode=\(parkCode.rawValue)&limit=1&start=0") else {
      preconditionFailure("A validated park code produces a valid relative parks endpoint.")
    }
    return endpoint
  }

  /// Describes one parks page with filters, text search, sorting, and explicit pagination.
  /// - Parameter query: Validated options, encoded without changing their values or order.
  /// - Returns: One endpoint returning the complete ``NPSCollection`` envelope, the same as
  ///   ``collection(_:)``.
  public static func parks(query: ParkQuery) -> Self {
    collection(query)
  }
}

extension Endpoint where Response == NPSCollection<Place> {
  /// Describes one places page with filters, text search, and explicit pagination.
  ///
  /// ```swift
  /// let query = try PlaceQuery(limit: 1, parkCodes: [ParkCode("acad")])
  /// print(Endpoint.places(query: query).path)
  /// // "/places?limit=1&parkCode=acad&start=0"
  /// ```
  /// - Parameter query: Validated options, encoded without changing their values or order.
  /// - Returns: One endpoint returning the complete ``NPSCollection`` envelope, the same as
  ///   ``collection(_:)``.
  public static func places(query: PlaceQuery) -> Self {
    collection(query)
  }
}

extension Endpoint where Response == RoadEventFeed {
  /// Describes the road events feed, optionally narrowed to one park and one event type.
  ///
  /// The feed is one response with no pagination. Omitted parameters are not sent, so passing
  /// neither describes `/roadevents`, the feed for every park. The provider silently ignores a park
  /// code it does not recognize and returns every park's events, while a recognized code with no
  /// events returns an empty feed.
  ///
  /// ```swift
  /// let endpoint = Endpoint.roadEvents(parkCode: try ParkCode("yell"), type: .workZone)
  /// print(endpoint.path) // "/roadevents?parkCode=yell&type=WorkZone"
  /// ```
  /// - Parameters:
  ///   - parkCode: One park code, or nil for every park.
  ///   - type: One event type sent in the provider's spelling, or nil for every type.
  /// - Returns: One endpoint returning the complete ``RoadEventFeed``.
  public static func roadEvents(parkCode: ParkCode? = nil, type: RoadEventType? = nil) -> Self {
    var items: [String] = []
    if let parkCode { items.append("parkCode=" + parkCode.rawValue) }
    if let type { items.append("type=" + type.rawValue) }
    let query = items.isEmpty ? "" : "?" + items.joined(separator: "&")
    guard let endpoint = Self(path: "/roadevents" + query) else {
      preconditionFailure("A validated park code and a known event type form a relative endpoint.")
    }
    return endpoint
  }
}

extension Endpoint where Response == NPSCollection<ThingToDo> {
  /// Describes one things to do page with identifiers, filters, text search, sorting, and pagination.
  ///
  /// ```swift
  /// let query = try ThingToDoQuery(
  ///   limit: 1, parkCodes: [ParkCode("acad")], sort: [.descending("relevanceScore")])
  /// print(Endpoint.thingsToDo(query: query).path)
  /// // "/thingstodo?limit=1&parkCode=acad&sort=-relevanceScore&start=0"
  /// ```
  /// - Parameter query: Validated options, encoded without changing their values or order.
  /// - Returns: One endpoint returning the complete ``NPSCollection`` envelope, the same as
  ///   ``collection(_:)``.
  public static func thingsToDo(query: ThingToDoQuery) -> Self {
    collection(query)
  }
}

extension Endpoint where Response == NPSCollection<Tour> {
  /// Describes one tours page with identifiers, filters, text search, sorting, and pagination.
  ///
  /// ```swift
  /// let query = try TourQuery(
  ///   limit: 1, parkCodes: [ParkCode("cavo")], sort: [.descending("relevanceScore")])
  /// print(Endpoint.tours(query: query).path)
  /// // "/tours?limit=1&parkCode=cavo&sort=-relevanceScore&start=0"
  /// ```
  /// - Parameter query: Validated options, encoded without changing their values or order.
  /// - Returns: One endpoint returning the complete ``NPSCollection`` envelope, the same as
  ///   ``collection(_:)``.
  public static func tours(query: TourQuery) -> Self {
    collection(query)
  }
}

extension Endpoint where Response == NPSCollection<VisitorCenter> {
  /// Describes one visitor centers page with filters, text search, sorting, and pagination.
  ///
  /// ```swift
  /// let query = try VisitorCenterQuery(
  ///   limit: 1, parkCodes: [ParkCode("acad")], sort: [.ascending("name")])
  /// print(Endpoint.visitorCenters(query: query).path)
  /// // "/visitorcenters?limit=1&parkCode=acad&sort=name&start=0"
  /// ```
  /// - Parameter query: Validated options, encoded without changing their values or order.
  /// - Returns: One endpoint returning the complete ``NPSCollection`` envelope, the same as
  ///   ``collection(_:)``.
  public static func visitorCenters(query: VisitorCenterQuery) -> Self {
    collection(query)
  }
}

extension Endpoint where Response == NPSCollection<Webcam> {
  /// Describes one webcams page with identifiers, filters, text search, and explicit pagination.
  ///
  /// ```swift
  /// let query = try WebcamQuery(limit: 1, parkCodes: [ParkCode("grte")])
  /// print(Endpoint.webcams(query: query).path)
  /// // "/webcams?limit=1&parkCode=grte&start=0"
  /// ```
  /// - Parameter query: Validated options, encoded without changing their values or order.
  /// - Returns: One endpoint returning the complete ``NPSCollection`` envelope, the same as
  ///   ``collection(_:)``.
  public static func webcams(query: WebcamQuery) -> Self {
    collection(query)
  }
}
