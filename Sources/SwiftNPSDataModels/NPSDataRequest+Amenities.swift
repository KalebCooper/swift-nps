extension NPSDataRequest where Response == NPSCollection<Amenity> {
  /// Describes an amenities query usable for one page or lazy iteration.
  ///
  /// A custom executor sends ``NPSCollectionResolution/endpoint`` and uses
  /// ``NPSCollectionResolution/next(after:)`` when more pages are desired. No request is sent
  /// during construction.
  /// - Parameter query: Validated query options.
  /// - Returns: An inspectable request whose individual response is ``NPSCollection`` of
  ///   ``Amenity``.
  public static func amenities(query: AmenityQuery) -> Self {
    Self(resolution: .collection(NPSCollectionResolution(query)))
  }
}

extension NPSDataRequest where Response == NPSCollection<[AmenityParkPlaces]> {
  /// Describes an amenity park places query usable for one page or lazy iteration.
  ///
  /// A custom executor sends ``NPSCollectionResolution/endpoint`` and uses
  /// ``NPSCollectionResolution/next(after:)`` when more pages are desired. No request is sent
  /// during construction.
  /// - Parameter query: Validated query options.
  /// - Returns: An inspectable request whose individual response is ``NPSCollection`` of
  ///   per-amenity groups of ``AmenityParkPlaces``.
  public static func amenityParkPlaces(query: AmenityParkPlacesQuery) -> Self {
    Self(resolution: .collection(NPSCollectionResolution(query)))
  }
}

extension NPSDataRequest where Response == NPSCollection<[AmenityParkVisitorCenters]> {
  /// Describes an amenity park visitor centers query usable for one page or lazy iteration.
  ///
  /// A custom executor sends ``NPSCollectionResolution/endpoint`` and uses
  /// ``NPSCollectionResolution/next(after:)`` when more pages are desired. No request is sent
  /// during construction.
  /// - Parameter query: Validated query options.
  /// - Returns: An inspectable request whose individual response is ``NPSCollection`` of
  ///   per-amenity groups of ``AmenityParkVisitorCenters``.
  public static func amenityParkVisitorCenters(query: AmenityParkVisitorCentersQuery) -> Self {
    Self(resolution: .collection(NPSCollectionResolution(query)))
  }
}
