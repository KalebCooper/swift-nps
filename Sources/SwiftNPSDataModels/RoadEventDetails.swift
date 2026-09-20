/// The details of one road event: its description, timing, accuracy, impact, and identifiers.
///
/// This is the GeoJSON `properties` object of a ``RoadEventFeature``. Timestamps such as
/// ``startDate`` are kept as the provider's text without date parsing, and ``endDate`` is nil when
/// the provider omits it. Vocabulary fields such as ``vehicleImpact`` stay open strings, since the
/// provider can extend them. Work zones usually carry ``typesOfWork`` and incidents
/// ``typesOfIncident``, but neither is guaranteed.
///
/// The provider sends two identifiers under keys that differ only in case and underscore: `Id`,
/// preserved as ``id``, and `_id`, preserved as ``numericId``.
///
/// ```swift
/// if let details = feature.properties {
///   print(details.id ?? "", details.coreDetails?.name ?? "", details.vehicleImpact ?? "")
/// }
/// ```
public struct RoadEventDetails: Codable, Hashable, Sendable {
  /// The core description of a road event: name, type, roads, and direction.
  public struct CoreDetails: Codable, Hashable, Sendable {
    /// The identifier of the ``RoadEventDataSource`` that published the event.
    public let dataSourceId: String?

    /// The provider's plain-text description, with line breaks as sent.
    public let description: String?

    /// The direction of travel affected, such as `"westbound"`, kept as an open string.
    public let direction: String?

    /// The WZDx event type, such as `"work-zone"` or `"incident"`, kept as an open string.
    ///
    /// This is response data the provider can extend, so it is not a ``RoadEventType``. The
    /// response spells work zones `"work-zone"` while the request parameter spells them `WorkZone`.
    public let eventType: String?

    /// The event's display name.
    public let name: String?

    /// The affected road names in the order sent, including an empty array.
    public let roadNames: [String]?

    // The provider sends snake_case keys for multiword fields.
    private enum CodingKeys: String, CodingKey {
      case dataSourceId = "data_source_id"
      case description
      case direction
      case eventType = "event_type"
      case name
      case roadNames = "road_names"
    }
  }

  /// One incident classification, such as a crash or a forest fire.
  public struct IncidentType: Codable, Hashable, Sendable {
    /// The provider's plain-text description of the incident, with line breaks as sent.
    public let description: String?

    /// The incident category, such as `"crash"` or `"disaster"`, kept as an open string.
    public let incidentCategory: String?

    /// The incident type, such as `"crash"` or `"fire-forest"`, kept as an open string.
    public let incidentType: String?

    // The provider sends snake_case keys for multiword fields.
    private enum CodingKeys: String, CodingKey {
      case description
      case incidentCategory = "incident_category"
      case incidentType = "incident_type"
    }
  }

  /// One kind of work in a work zone.
  public struct WorkType: Codable, Hashable, Sendable {
    /// The WZDx work type, such as `"barrier-work"` or `"surface-work"`, kept as an open string.
    public let typeName: String?

    // The provider sends `type_name` in snake_case.
    private enum CodingKeys: String, CodingKey {
      case typeName = "type_name"
    }
  }

  /// The accuracy of the starting position, such as `"estimated"`, kept as an open string.
  public let beginningAccuracy: String?

  /// The event's core description.
  public let coreDetails: CoreDetails?

  /// The end time as the provider's text, or nil when the provider omits it.
  public let endDate: String?

  /// The accuracy of ``endDate``, such as `"estimated"`, kept as an open string.
  public let endDateAccuracy: String?

  /// The accuracy of the ending position, such as `"estimated"`, kept as an open string.
  public let endingAccuracy: String?

  /// The feature identifier the provider sends as `Id`, preserved without UUID parsing.
  public let id: String?

  /// Whether the provider reports the end date as verified.
  public let isEndDateVerified: Bool?

  /// Whether the provider reports the ending position as verified.
  public let isEndPositionVerified: Bool?

  /// Whether the provider reports the start date as verified.
  public let isStartDateVerified: Bool?

  /// Whether the provider reports the starting position as verified.
  public let isStartPositionVerified: Bool?

  /// How the provider located the event, such as `"unknown"`, kept as an open string.
  public let locationMethod: String?

  /// The feature's numeric identifier the provider sends as `_id`.
  ///
  /// Observed as consecutive integers starting at 0 within one response, where the same feature
  /// carried 0 in a single-park feed and 51 in the unfiltered feed. The provider does not
  /// document its meaning, uniqueness, or stability; use ``id`` to recognize a feature.
  public let numericId: Int?

  /// The start time as the provider's text, such as `"2026-04-06T04:00:00Z"`, without date parsing.
  public let startDate: String?

  /// The accuracy of ``startDate``, such as `"estimated"`, kept as an open string.
  public let startDateAccuracy: String?

  /// Incident classifications in the order sent, or nil when the provider omits them.
  public let typesOfIncident: [IncidentType]?

  /// Kinds of work in the order sent, or nil when the provider omits them.
  public let typesOfWork: [WorkType]?

  /// The impact on vehicles, such as `"all-lanes-closed"`, kept as an open string.
  public let vehicleImpact: String?

  // The provider sends snake_case keys, plus `Id` and `_id` as two distinct identifiers.
  private enum CodingKeys: String, CodingKey {
    case beginningAccuracy = "beginning_accuracy"
    case coreDetails = "core_details"
    case endDate = "end_date"
    case endDateAccuracy = "end_date_accuracy"
    case endingAccuracy = "ending_accuracy"
    case id = "Id"
    case isEndDateVerified = "is_end_date_verified"
    case isEndPositionVerified = "is_end_position_verified"
    case isStartDateVerified = "is_start_date_verified"
    case isStartPositionVerified = "is_start_position_verified"
    case locationMethod = "location_method"
    case numericId = "_id"
    case startDate = "start_date"
    case startDateAccuracy = "start_date_accuracy"
    case typesOfIncident = "types_of_incident"
    case typesOfWork = "types_of_work"
    case vehicleImpact = "vehicle_impact"
  }
}
