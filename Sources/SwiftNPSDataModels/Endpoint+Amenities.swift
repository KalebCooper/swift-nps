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
