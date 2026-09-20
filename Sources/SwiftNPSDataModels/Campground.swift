/// A campground returned by the NPS campgrounds API.
///
/// Identity and name are required. Other documented fields are optional, preserving missing or
/// null values without substituting empty strings or arrays. Counts, coordinates, flags, lengths,
/// links, and timestamps retain their provider representation, including empty strings. Unknown
/// JSON fields are ignored by Codable. Campground data describes facilities and published fees; it
/// is not live campsite availability or a reservation service.
///
/// ```swift
/// let page = try JSONDecoder().decode(NPSCollection<Campground>.self, from: data)
/// for campground in page.data {
///   print(campground.parkCode ?? "", campground.name, campground.campsites?.totalSites ?? "")
/// }
/// ```
public struct Campground: Codable, Hashable, Sendable {
  /// Published accessibility and vehicle details, with every value kept as sent.
  public struct Accessibility: Codable, Hashable, Sendable {
    /// Access road descriptions, in provider order.
    public let accessRoads: [String]?

    /// The provider's ADA accessibility text.
    public let adaInfo: String?

    /// Additional accessibility text, including an empty string.
    public let additionalInfo: String?

    /// The provider's cell phone coverage text, including an empty string.
    public let cellPhoneInfo: String?

    /// Campground classifications, in provider order.
    public let classifications: [String]?

    /// The provider's fire and stove policy text.
    public let fireStovePolicy: String?

    /// The provider's internet access text, including an empty string.
    public let internetInfo: String?

    /// The RV flag exactly as sent, such as `"0"` or `"1"`, without Boolean parsing.
    public let rvAllowed: String?

    /// The provider's RV text.
    public let rvInfo: String?

    /// The maximum RV length text exactly as sent, without unit or numeric conversion.
    public let rvMaxLength: String?

    /// The trailer flag exactly as sent, such as `"0"` or `"1"`, without Boolean parsing.
    public let trailerAllowed: String?

    /// The maximum trailer length text exactly as sent, without unit or numeric conversion.
    public let trailerMaxLength: String?

    /// The provider's wheelchair access text.
    public let wheelchairAccess: String?
  }

  /// Published amenity descriptions, such as `"Yes - seasonal"`, kept as open text.
  public struct Amenities: Codable, Hashable, Sendable {
    /// The amphitheater description.
    public let amphitheater: String?

    /// The camp store description.
    public let campStore: String?

    /// The cell phone reception description.
    public let cellPhoneReception: String?

    /// The dump station description.
    public let dumpStation: String?

    /// The firewood sales description.
    public let firewoodForSale: String?

    /// The food storage lockers description.
    public let foodStorageLockers: String?

    /// The ice sales description.
    public let iceAvailableForSale: String?

    /// The internet connectivity description.
    public let internetConnectivity: String?

    /// The laundry description.
    public let laundry: String?

    /// Potable water descriptions, in provider order.
    public let potableWater: [String]?

    /// Shower descriptions, in provider order.
    public let showers: [String]?

    /// The on-site staff or volunteer host description.
    public let staffOrVolunteerHostOnsite: String?

    /// Toilet descriptions, in provider order.
    public let toilets: [String]?

    /// The trash and recycling collection description.
    public let trashRecyclingCollection: String?
  }

  /// Published campsite counts, each kept as the provider's text without numeric parsing.
  public struct Campsites: Codable, Hashable, Sendable {
    /// The count of sites with electrical hookups.
    public let electricalHookups: String?

    /// The count of group sites.
    public let group: String?

    /// The count of horse sites.
    public let horse: String?

    /// The count of other sites.
    public let other: String?

    /// The count of RV-only sites.
    public let rvOnly: String?

    /// The count of tent-only sites.
    public let tentOnly: String?

    /// The total count of sites.
    public let totalSites: String?

    /// The count of walk-to or boat-to sites.
    public let walkBoatTo: String?
  }

  // The provider sends `regulationsurl` in lowercase; every other key matches its property name.
  private enum CodingKeys: String, CodingKey {
    case accessibility
    case addresses
    case amenities
    case audioDescription
    case campsites
    case contacts
    case description
    case directionsOverview
    case directionsUrl
    case fees
    case geometryPoiId
    case id
    case images
    case isPassportStampLocation
    case lastIndexedDate
    case latLong
    case latitude
    case longitude
    case multimedia
    case name
    case numberOfSitesFirstComeFirstServe
    case numberOfSitesReservable
    case operatingHours
    case parkCode
    case passportStampImages
    case passportStampLocationDescription
    case regulationsOverview
    case regulationsUrl = "regulationsurl"
    case relevanceScore
    case reservationInfo
    case reservationUrl
    case url
    case weatherOverview
  }

  /// Published accessibility and vehicle details.
  public let accessibility: Accessibility?

  /// Physical and mailing addresses.
  public let addresses: [NPSAddress]?

  /// Published amenity descriptions.
  public let amenities: Amenities?

  /// The provider's audio description text, including an empty string.
  public let audioDescription: String?

  /// Published campsite counts.
  public let campsites: Campsites?

  /// Published contact information.
  public let contacts: NPSContacts?

  /// The campground's description.
  public let description: String?

  /// The provider's directions overview text.
  public let directionsOverview: String?

  /// The original directions link, including an empty string.
  public let directionsUrl: String?

  /// Published camping fees, without numeric or currency conversion.
  public let fees: [NPSFee]?

  /// The provider's geometry point-of-interest identifier, including an empty string.
  public let geometryPoiId: String?

  /// The campground identifier, preserved without UUID parsing.
  public let id: String

  /// Image references and attribution.
  public let images: [NPSImage]?

  /// The passport stamp flag exactly as sent, such as `"0"` or `"1"`, without Boolean parsing.
  public let isPassportStampLocation: String?

  /// When NPS last indexed the record, as the provider's text, including an empty string.
  public let lastIndexedDate: String?

  /// The combined coordinate text without parsing.
  public let latLong: String?

  /// The latitude as supplied, with its original precision.
  public let latitude: String?

  /// The longitude as supplied, with its original precision.
  public let longitude: String?

  /// Published multimedia references.
  public let multimedia: [NPSMultimedia]?

  /// The campground's display name.
  public let name: String

  /// The published first-come, first-served site count as text; not live availability.
  public let numberOfSitesFirstComeFirstServe: String?

  /// The published reservable site count as text; not live availability.
  public let numberOfSitesReservable: String?

  /// Descriptive hours and seasons; these are not a live open-or-closed status.
  public let operatingHours: [NPSOperatingHours]?

  /// The code of the park the campground belongs to, without validation.
  public let parkCode: String?

  /// Passport stamp images, including an empty array, or nil when absent.
  public let passportStampImages: [NPSImage]?

  /// The provider's passport stamp description, including an empty string.
  public let passportStampLocationDescription: String?

  /// The provider's regulations overview text.
  public let regulationsOverview: String?

  /// The regulations link text, including an empty string, decoded from `regulationsurl`.
  public let regulationsUrl: String?

  /// The provider's numeric relevance score, when supplied.
  public let relevanceScore: Double?

  /// The provider's reservation text; not a booking or availability guarantee.
  public let reservationInfo: String?

  /// The reservation link text, including an empty string; not an API endpoint.
  public let reservationUrl: String?

  /// The campground's web page URL text.
  public let url: String?

  /// The provider's weather overview text, including an empty string.
  public let weatherOverview: String?
}
