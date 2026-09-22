/// A parking lot returned by the NPS parking lots API.
///
/// Identity and name are required. Other documented fields are optional, preserving missing or
/// null values without substituting empty strings or arrays. ``latitude`` and ``longitude`` arrive
/// as JSON numbers and keep that type. Contacts, fees, and operating hours reuse the shared
/// ``NPSContacts``, ``NPSFee``, and ``NPSOperatingHours`` shapes, while ``accessibility`` and
/// ``liveStatus`` keep the provider's JSON numbers and Booleans in nested types. Despite its name,
/// the live status is not guaranteed to be current. Unknown JSON fields are ignored by Codable.
///
/// ```swift
/// let page = try JSONDecoder().decode(NPSCollection<ParkingLot>.self, from: data)
/// for lot in page.data {
///   print(lot.name, lot.accessibility?.totalSpaces ?? 0)
/// }
/// ```
public struct ParkingLot: Codable, Hashable, Sendable {
  /// Space counts and accessibility details for a parking lot, as the provider sends them.
  ///
  /// Counts are JSON integers. The provider's `numberofAda` keys and its misspelled
  /// `numberofAdaVanAccessbileSpaces` key decode into conventionally spelled properties without
  /// changing their values.
  ///
  /// ```swift
  /// if let accessibility = lot.accessibility, accessibility.isLotAccessibleToDisabled == true {
  ///   print(accessibility.numberOfAdaSpaces ?? 0)
  /// }
  /// ```
  public struct Accessibility: Codable, Hashable, Sendable {
    /// The provider's description of accessible facilities, including an empty string.
    public let adaFacilitiesDescription: String?

    /// Whether the provider reports the lot as accessible to people with disabilities.
    public let isLotAccessibleToDisabled: Bool?

    /// The number of accessible spaces, decoded from the provider's `numberofAdaSpaces` key.
    public let numberOfAdaSpaces: Int?

    /// The number of step-free accessible spaces, decoded from the provider's
    /// `numberofAdaStepFreeSpaces` key.
    public let numberOfAdaStepFreeSpaces: Int?

    /// The number of van-accessible spaces, decoded from the provider's misspelled
    /// `numberofAdaVanAccessbileSpaces` key.
    public let numberOfAdaVanAccessibleSpaces: Int?

    /// The number of spaces for oversize vehicles.
    public let numberOfOversizeVehicleSpaces: Int?

    /// The total number of spaces the provider reports for the lot.
    public let totalSpaces: Int?

    private enum CodingKeys: String, CodingKey {
      case adaFacilitiesDescription
      case isLotAccessibleToDisabled
      case numberOfAdaSpaces = "numberofAdaSpaces"
      case numberOfAdaStepFreeSpaces = "numberofAdaStepFreeSpaces"
      case numberOfAdaVanAccessibleSpaces = "numberofAdaVanAccessbileSpaces"
      case numberOfOversizeVehicleSpaces
      case totalSpaces
    }
  }

  /// The provider's status report for a parking lot, which is not guaranteed to be current.
  ///
  /// The provider publishes these fields as a live status, but most lots send an empty
  /// ``occupancy`` and a null wait time, and the ``expirationDate`` values it does send can lie
  /// years in the past. Nothing is inferred from ``isActive`` or from an expired report; every
  /// value is kept as sent.
  ///
  /// ```swift
  /// if let status = lot.liveStatus, let occupancy = status.occupancy, !occupancy.isEmpty {
  ///   print(occupancy, status.expirationDate ?? "")
  /// }
  /// ```
  public struct LiveStatus: Codable, Hashable, Sendable {
    /// The provider's status note, including an empty string.
    public let description: String?

    /// The provider's estimated wait, a JSON integer, or nil when it sends `null`.
    ///
    /// The provider's key names minutes; NPS documents no range, and most lots send `null`.
    public let estimatedWaitTimeInMinutes: Int?

    /// When the report expires, as the provider's text such as `"2019-11-25 14:00:00.0"`.
    ///
    /// The text is not ISO 8601, names no time zone, and is not parsed. It is usually an empty
    /// string, and a non-empty value is not guaranteed to be in the future.
    public let expirationDate: String?

    /// The provider's active flag, decoded from a JSON Boolean, with no documented meaning.
    public let isActive: Bool?

    /// The provider's occupancy text, such as `"Light"` or `"Busy"`, kept as an open string.
    ///
    /// It is usually an empty string and is not guaranteed to describe current conditions.
    public let occupancy: String?
  }

  /// Space counts and accessibility details, or nil when unavailable.
  public let accessibility: Accessibility?

  /// The provider's alternate name, including an empty string.
  public let altName: String?

  /// Published contacts for the lot, including empty contact arrays.
  public let contacts: NPSContacts?

  /// The provider's description of the lot, including an empty string.
  public let description: String?

  /// Published parking fees in the order sent, including an empty array.
  public let fees: [NPSFee]?

  /// The provider's geometry point-of-interest identifier, including an empty string.
  public let geometryPoiId: String?

  /// The parking lot identifier, preserved without UUID parsing.
  public let id: String

  /// Image references and attribution, including an empty array, with URL text kept as sent.
  public let images: [NPSImage]?

  /// The latitude as a JSON number, or nil when unavailable.
  public let latitude: Double?

  /// The provider's status report, which is not guaranteed to be current.
  public let liveStatus: LiveStatus?

  /// The longitude as a JSON number, or nil when unavailable.
  public let longitude: Double?

  /// The provider's managing organization text, kept as an open string.
  public let managedByOrganization: String?

  /// The parking lot's display name.
  public let name: String

  /// Published operating hours and exceptions, including an empty array.
  public let operatingHours: [NPSOperatingHours]?

  /// Parks NPS links to the lot, including an empty array.
  public let relatedParks: [NPSRelatedPark]?

  /// The provider's time zone abbreviation, such as `"CT"` or `"HAST"`, including an empty string.
  ///
  /// It is an abbreviation, not an IANA identifier, and is not converted to a time zone.
  public let timeZone: String?

  /// The provider's webcam URL text, including an empty string; it is not an API endpoint.
  public let webcamUrl: String?
}
