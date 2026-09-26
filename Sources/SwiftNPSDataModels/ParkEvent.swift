/// An event definition or provider-expanded occurrence from the NPS events API.
///
/// Dates, local times, flags, coordinates, HTML, and image paths remain provider strings.
/// Expanded occurrences can share an identifier. Other than identity and title, fields may be
/// absent or null; no scheduling timezone or recurrence interpretation is supplied.
///
/// ```swift
/// for event in response.data {
///   print(event.title, event.date ?? "")
/// }
/// ```
public struct ParkEvent: Codable, Hashable, Sendable {
  /// An event-specific image, whose URL and path can both be relative.
  public struct EventImage: Codable, Hashable, Sendable {
    /// Alternative text as published.
    public let altText: String?
    /// The image caption.
    public let caption: String?
    /// The published attribution.
    public let credit: String?
    /// The image record identifier, including an empty string.
    public let id: String?
    /// The provider's image identifier text.
    public let imageID: String?
    /// The provider's ordering text.
    public let ordinal: String?
    /// The raw image path.
    public let path: String?
    /// The image title.
    public let title: String?
    /// The raw image URL, which may be relative.
    public let url: String?

    private enum CodingKeys: String, CodingKey {
      case altText, caption, credit, id
      case imageID = "imageid"
      case ordinal, path, title, url
    }
  }

  /// Local clock text and sunrise/sunset flags for one published time interval.
  public struct EventTime: Codable, Hashable, Sendable {
    /// The provider's Boolean-like sunrise flag, without conversion.
    public let sunriseStart: String?
    /// The provider's Boolean-like sunset flag, without conversion.
    public let sunsetEnd: String?
    /// The local ending time text, with no inferred timezone.
    public let timeEnd: String?
    /// The local starting time text, with no inferred timezone.
    public let timeStart: String?

    private enum CodingKeys: String, CodingKey {
      case sunriseStart = "sunrisestart"
      case sunsetEnd = "sunsetend"
      case timeEnd = "timeend"
      case timeStart = "timestart"
    }
  }

  /// Cancellation dates as published, observed as MM/dd/yyyy.
  public let cancelledDates: [String]?

  /// The open event category.
  public let category: String?

  /// The category identifier text.
  public let categoryID: String?

  /// The published contact email address.
  public let contactEmailAddress: String?

  /// The published contact name.
  public let contactName: String?

  /// The published contact telephone number.
  public let contactTelephoneNumber: String?

  /// The provider's selected occurrence date.
  public let date: String?

  /// The event or occurrence ending date text.
  public let dateEnd: String?

  /// Occurrence dates as supplied, which may differ from expanded records.
  public let dates: [String]?

  /// The event or occurrence starting date text.
  public let dateStart: String?

  /// The creation timestamp text, without an inferred timezone.
  public let dateTimeCreated: String?

  /// The optional update timestamp text.
  public let dateTimeUpdated: String?

  /// The description, including unmodified HTML.
  public let description: String?

  /// The provider's numeric-looking event identifier text.
  public let eventID: String?

  /// Published fee information.
  public let feeInformation: String?

  /// The record identifier, shared by expanded occurrences.
  public let id: String

  /// The provider's image identifier list as one raw string.
  public let imageIDList: String?

  /// Event-specific images in provider order.
  public let images: [EventImage]?

  /// The information link as published.
  public let informationURL: String?

  /// The Boolean-like all-day flag as text.
  public let isAllDay: String?

  /// The Boolean-like free-admission flag as text.
  public let isFree: String?

  /// The Boolean-like recurrence flag as text.
  public let isRecurring: String?

  /// The Boolean-like registration or reservation flag as text.
  public let isRegistrationRequired: String?

  /// The latitude text, without conversion.
  public let latitude: String?

  /// The published location description.
  public let location: String?

  /// The longitude text, without conversion.
  public let longitude: String?

  /// The related organization's name.
  public let organizationName: String?

  /// The related park's full name.
  public let parkFullName: String?

  /// The related portal's name.
  public let portalName: String?

  /// The recurrence ending date text.
  public let recurrenceDateEnd: String?

  /// The recurrence starting date text.
  public let recurrenceDateStart: String?

  /// The raw recurrence rule, without client-side expansion.
  public let recurrenceRule: String?

  /// Published registration or reservation information.
  public let registrationInformation: String?

  /// The registration or reservation link as published.
  public let registrationURL: String?

  /// The optional provider point-of-interest identifier.
  public let risdPOIID: String?

  /// The raw related site code.
  public let siteCode: String?

  /// The open related site type.
  public let siteType: String?

  /// The related subject's name.
  public let subjectName: String?

  /// Open tags in provider order.
  public let tags: [String]?

  /// Published information about event times.
  public let timeInformation: String?

  /// Local time intervals in provider order.
  public let times: [EventTime]?

  /// The event title.
  public let title: String

  /// Open event types in provider order.
  public let types: [String]?

  private enum CodingKeys: String, CodingKey {
    case cancelledDates = "cancelleddatelist"
    case category
    case categoryID = "categoryid"
    case contactEmailAddress = "contactemailaddress"
    case contactName = "contactname"
    case contactTelephoneNumber = "contacttelephonenumber"
    case date
    case dateEnd = "dateend"
    case dates
    case dateStart = "datestart"
    case dateTimeCreated = "datetimecreated"
    case dateTimeUpdated = "datetimeupdated"
    case description
    case eventID = "eventid"
    case feeInformation = "feeinfo"
    case id
    case imageIDList = "imageidlist"
    case images
    case informationURL = "infourl"
    case isAllDay = "isallday"
    case isFree = "isfree"
    case isRecurring = "isrecurring"
    case isRegistrationRequired = "isregresrequired"
    case latitude
    case location
    case longitude
    case organizationName = "organizationname"
    case parkFullName = "parkfullname"
    case portalName = "portalname"
    case recurrenceDateEnd = "recurrencedateend"
    case recurrenceDateStart = "recurrencedatestart"
    case recurrenceRule = "recurrencerule"
    case registrationInformation = "regresinfo"
    case registrationURL = "regresurl"
    case risdPOIID = "risdpoiid"
    case siteCode = "sitecode"
    case siteType = "sitetype"
    case subjectName = "subjectname"
    case tags
    case timeInformation = "timeinfo"
    case times
    case title
    case types
  }
}
