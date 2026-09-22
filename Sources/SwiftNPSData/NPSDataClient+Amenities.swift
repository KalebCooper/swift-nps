import SwiftNPSDataModels

extension NPSDataClient {
  /// Iterates individual amenities, fetching the next page only when needed.
  /// - Parameter query: Validated query options, including page size and starting offset.
  /// - Returns: Amenities in provider order, without deduplication, throwing ``NPSDataError``.
  public func amenities(query: AmenityQuery) -> NPSItemSequence<Amenity> {
    items(for: .amenities(query: query))
  }

  /// Iterates complete amenities pages with identifiers, text search, and explicit pagination.
  /// - Parameter query: Validated options shared by each request except its advancing offset.
  /// - Returns: A lazy sequence retaining each provider envelope and throwing ``NPSDataError``.
  public func amenityPages(query: AmenityQuery) -> NPSPageSequence<Amenity> {
    pages(for: .amenities(query: query))
  }

  /// Iterates complete amenity park places pages, keeping the provider's per-amenity groups.
  /// - Parameter query: Validated options shared by each request except its advancing offset.
  /// - Returns: A lazy sequence retaining each provider envelope, whose `data` holds one group per
  ///   amenity, and throwing ``NPSDataError``.
  public func amenityParkPlacePages(
    query: AmenityParkPlacesQuery
  ) -> NPSPageSequence<[AmenityParkPlaces]> {
    pages(for: .amenityParkPlaces(query: query))
  }

  /// Iterates individual amenity park places values, flattening the provider's per-amenity groups.
  /// - Parameter query: Validated query options, including page size and starting offset.
  /// - Returns: Every value of every group in provider order, without deduplication, fetching the
  ///   next page only when needed and throwing ``NPSDataError``.
  public func amenityParkPlaces(
    query: AmenityParkPlacesQuery
  ) -> NPSFlattenedItemSequence<AmenityParkPlaces> {
    NPSFlattenedItemSequence(groups: items(for: .amenityParkPlaces(query: query)))
  }

  /// Iterates complete amenity park visitor centers pages, keeping the provider's per-amenity
  /// groups.
  /// - Parameter query: Validated options shared by each request except its advancing offset.
  /// - Returns: A lazy sequence retaining each provider envelope, whose `data` holds one group per
  ///   amenity, and throwing ``NPSDataError``.
  public func amenityParkVisitorCenterPages(
    query: AmenityParkVisitorCentersQuery
  ) -> NPSPageSequence<[AmenityParkVisitorCenters]> {
    pages(for: .amenityParkVisitorCenters(query: query))
  }

  /// Iterates individual amenity park visitor centers values, flattening the provider's
  /// per-amenity groups.
  /// - Parameter query: Validated query options, including page size and starting offset.
  /// - Returns: Every value of every group in provider order, without deduplication, fetching the
  ///   next page only when needed and throwing ``NPSDataError``.
  public func amenityParkVisitorCenters(
    query: AmenityParkVisitorCentersQuery
  ) -> NPSFlattenedItemSequence<AmenityParkVisitorCenters> {
    NPSFlattenedItemSequence(groups: items(for: .amenityParkVisitorCenters(query: query)))
  }
}
