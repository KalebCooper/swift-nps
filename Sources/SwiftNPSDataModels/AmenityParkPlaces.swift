/// An amenity with the parks and places NPS lists as offering it.
///
/// Identity and name are required. Parks and places are optional, preserving missing or null
/// values, and keep the provider's order and text, including links. Unknown JSON fields are
/// ignored by Codable.
///
/// The `/amenities/parksplaces` endpoint wraps its results in an extra array: each element of a
/// page's `data` is the provider's group of these values for one amenity, observed so far with one
/// entry each. Pages therefore decode as `NPSCollection<[AmenityParkPlaces]>`.
///
/// ```swift
/// let page = try JSONDecoder().decode(NPSCollection<[AmenityParkPlaces]>.self, from: data)
/// for amenity in page.data.joined() {
///   print(amenity.name, amenity.parks?.first?.places?.first?.title ?? "")
/// }
/// ```
public struct AmenityParkPlaces: Codable, Hashable, Sendable {
  /// A place in a park where NPS lists the amenity.
  public struct Place: Codable, Hashable, Sendable {
    /// The provider's place identifier, preserved as sent.
    public let id: String?

    /// The place title, such as `"Jordan Pond House"`.
    public let title: String?

    /// The place's public web page URL text, not an API endpoint.
    public let url: String?
  }

  /// A park offering the amenity, as NPS summarizes it, with the places that offer it.
  ///
  /// The provider sends one flat object: the ``NPSRelatedPark`` fields alongside `places`. The
  /// park summary decodes from that same object, so `park` is never nil, and the places array
  /// is kept in provider order.
  public struct RelatedPark: Codable, Hashable, Sendable {
    private enum CodingKeys: String, CodingKey {
      case places
    }

    /// The park summary, read from the same object as the places.
    public let park: NPSRelatedPark

    /// Places in the park offering the amenity, in provider order.
    public let places: [Place]?

    /// Decodes the park summary and its places from one provider object.
    ///
    /// - Parameter decoder: The decoder positioned at the park entry.
    /// - Throws: `DecodingError` when the object is malformed.
    public init(from decoder: any Decoder) throws {
      park = try NPSRelatedPark(from: decoder)
      let container = try decoder.container(keyedBy: CodingKeys.self)
      places = try container.decodeIfPresent([Place].self, forKey: .places)
    }

    /// Encodes the park summary and its places into one object, matching the provider's shape.
    ///
    /// - Parameter encoder: The encoder to write the park entry into.
    /// - Throws: `EncodingError` when a value cannot be encoded.
    public func encode(to encoder: any Encoder) throws {
      try park.encode(to: encoder)
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encodeIfPresent(places, forKey: .places)
    }
  }

  /// The provider's amenity identifier, preserved as sent.
  public let id: String

  /// The amenity name, such as `"Accessible Rooms"`.
  public let name: String

  /// Parks offering the amenity, in provider order.
  public let parks: [RelatedPark]?
}
