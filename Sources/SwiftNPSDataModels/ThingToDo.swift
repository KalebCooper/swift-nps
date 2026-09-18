/// A thing to do returned by the NPS things to do API.
///
/// Identity and title are required. Other documented fields are optional, preserving missing or
/// null values without substituting empty strings or arrays. Coordinates, flags, durations, links,
/// and descriptions retain their provider representation, including empty strings and HTML.
/// Flags such as ``isReservationRequired`` stay the provider's `"true"` or `"false"` text.
/// Unknown JSON fields are ignored by Codable.
///
/// The provider's `relatedOrganizations` and `amenities` arrays are not decoded. Both are empty in
/// every recorded response, so their element shape is unknown; the specification types related
/// organizations as untyped objects and omits amenities.
///
/// ```swift
/// let page = try JSONDecoder().decode(NPSCollection<ThingToDo>.self, from: data)
/// for thing in page.data {
///   print(thing.title, thing.duration ?? "", thing.relatedParks?.first?.parkCode ?? "")
/// }
/// ```
public struct ThingToDo: Codable, Hashable, Sendable {
  /// An image reference with attribution, accessibility text, and published crops.
  ///
  /// Things to do images carry a description and crops whose aspect ratio is text, so they are not
  /// the shared ``NPSImage``. Upstream rights still apply.
  public struct Image: Codable, Hashable, Sendable {
    /// The alternative text.
    public let altText: String?

    /// The original caption, including an empty string.
    public let caption: String?

    /// The attribution, including an empty string; upstream rights still apply.
    public let credit: String?

    /// Published crops, including an empty array, or nil when absent.
    public let crops: [ImageCrop]?

    /// The provider's description, including an empty string.
    public let description: String?

    /// The image title.
    public let title: String?

    /// The image URL text, not an API endpoint.
    public let url: String?
  }

  /// A published crop of a things to do image.
  ///
  /// The aspect ratio arrives as text, such as `"1.78"`, and is kept as sent.
  public struct ImageCrop: Codable, Hashable, Sendable {
    /// The width-to-height ratio text, without numeric conversion.
    public let aspectRatio: String?

    /// The cropped image URL text, not an API endpoint.
    public let url: String?
  }

  /// A park associated with a thing to do, as NPS summarizes it.
  public struct RelatedPark: Codable, Hashable, Sendable {
    /// The park designation, such as `"National Park"`.
    public let designation: String?

    /// The full park name, including its designation.
    public let fullName: String?

    /// The short park name.
    public let name: String?

    /// The park code text, including codes unknown to this package.
    public let parkCode: String?

    /// The comma-separated state text, without splitting or sorting.
    public let states: String?

    /// The park's public website URL text.
    public let url: String?
  }

  /// Accessibility information, which may contain HTML.
  public let accessibilityInformation: String?

  /// Activities identified by NPS.
  public let activities: [NPSNamedItem]?

  /// The provider's activity description, such as a difficulty.
  public let activityDescription: String?

  /// The provider's age text, including an empty string.
  public let age: String?

  /// The provider's age description.
  public let ageDescription: String?

  /// The provider's `"true"` or `"false"` text for whether pets are permitted.
  public let arePetsPermitted: String?

  /// The provider's `"true"` or `"false"` text for whether pets are permitted with restrictions.
  public let arePetsPermittedWithRestrictions: String?

  /// The attribution for the thing to do, including an empty string.
  public let credit: String?

  /// The provider's `"true"` or `"false"` text for whether fees apply.
  public let doFeesApply: String?

  /// The published duration text, such as `"1-2 Hours"`, without conversion.
  public let duration: String?

  /// The provider's duration description.
  public let durationDescription: String?

  /// The fee description, which may contain HTML.
  public let feeDescription: String?

  /// The geometry point of interest identifier, including an empty string.
  public let geometryPoiId: String?

  /// The provider's thing to do identifier.
  public let id: String

  /// Published images.
  public let images: [Image]?

  /// The provider's `"true"` or `"false"` text for whether a reservation is required.
  public let isReservationRequired: String?

  /// The latitude text, including an empty string.
  public let latitude: String?

  /// The location text.
  public let location: String?

  /// The location description.
  public let locationDescription: String?

  /// The full description, which may contain HTML.
  public let longDescription: String?

  /// The longitude text, including an empty string.
  public let longitude: String?

  /// The pets description, which may contain HTML.
  public let petsDescription: String?

  /// Parks associated with this thing to do.
  public let relatedParks: [RelatedPark]?

  /// The provider's numeric relevance score, when supplied.
  public let relevanceScore: Double?

  /// The reservation description.
  public let reservationDescription: String?

  /// Seasons as sent, such as `"Summer"`, without a closed set.
  public let season: [String]?

  /// The season description.
  public let seasonDescription: String?

  /// The short description.
  public let shortDescription: String?

  /// Tags in provider order.
  public let tags: [String]?

  /// Times of day as sent, such as `"Dawn"`, without a closed set.
  public let timeOfDay: [String]?

  /// The time of day description.
  public let timeOfDayDescription: String?

  /// The thing to do title.
  public let title: String

  /// Topics identified by NPS.
  public let topics: [NPSNamedItem]?

  /// The thing to do's public page URL text.
  public let url: String?
}
