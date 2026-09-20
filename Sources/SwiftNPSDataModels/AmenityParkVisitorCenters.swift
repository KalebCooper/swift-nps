/// An amenity with the parks and visitor centers NPS lists as offering it.
///
/// Identity and name are required. Parks and visitor centers are optional, preserving missing or
/// null values, and keep the provider's order and text, including links. Unknown JSON fields are
/// ignored by Codable.
///
/// The `/amenities/parksvisitorcenters` endpoint wraps its results in an extra array: each element
/// of a page's `data` is the provider's group of these values for one amenity, observed so far with
/// one entry each. Pages therefore decode as `NPSCollection<[AmenityParkVisitorCenters]>`.
///
/// ```swift
/// let page = try JSONDecoder().decode(
///   NPSCollection<[AmenityParkVisitorCenters]>.self, from: data)
/// for amenity in page.data.joined() {
///   print(amenity.name, amenity.parks?.first?.visitorCenters?.first?.name ?? "")
/// }
/// ```
public struct AmenityParkVisitorCenters: Codable, Hashable, Sendable {
  /// A park offering the amenity, as NPS summarizes it, with the visitor centers that offer it.
  ///
  /// The provider sends one flat object: the ``NPSRelatedPark`` fields alongside the lowercase
  /// `visitorcenters` key. The park summary decodes from that same object, so `park` is never
  /// nil, and the visitor centers array is kept in provider order.
  public struct RelatedPark: Codable, Hashable, Sendable {
    private enum CodingKeys: String, CodingKey {
      case visitorCenters = "visitorcenters"
    }

    /// The park summary, read from the same object as the visitor centers.
    public let park: NPSRelatedPark

    /// Visitor centers in the park offering the amenity, in provider order, from the lowercase
    /// `visitorcenters` key.
    public let visitorCenters: [VisitorCenterSummary]?

    /// Decodes the park summary and its visitor centers from one provider object.
    ///
    /// - Parameter decoder: The decoder positioned at the park entry.
    /// - Throws: `DecodingError` when the object is malformed.
    public init(from decoder: any Decoder) throws {
      park = try NPSRelatedPark(from: decoder)
      let container = try decoder.container(keyedBy: CodingKeys.self)
      visitorCenters = try container.decodeIfPresent(
        [VisitorCenterSummary].self, forKey: .visitorCenters)
    }

    /// Encodes the park summary and its visitor centers into one object, matching the
    /// provider's shape.
    ///
    /// - Parameter encoder: The encoder to write the park entry into.
    /// - Throws: `EncodingError` when a value cannot be encoded.
    public func encode(to encoder: any Encoder) throws {
      try park.encode(to: encoder)
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encodeIfPresent(visitorCenters, forKey: .visitorCenters)
    }
  }

  /// A visitor center where NPS lists the amenity, as NPS summarizes it.
  ///
  /// This is a summary, not the full ``VisitorCenter`` from the visitor centers endpoint.
  public struct VisitorCenterSummary: Codable, Hashable, Sendable {
    /// The provider's visitor center identifier, preserved as sent.
    public let id: String?

    /// The visitor center name, such as `"Hulls Cove Visitor Center"`.
    public let name: String?

    /// The web page URL text the provider links, not an API endpoint.
    public let url: String?
  }

  /// The provider's amenity identifier, preserved as sent.
  public let id: String

  /// The amenity name, such as `"Automated Entrance"`.
  public let name: String

  /// Parks offering the amenity, in provider order.
  public let parks: [RelatedPark]?
}
