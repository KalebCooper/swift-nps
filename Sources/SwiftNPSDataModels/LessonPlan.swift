/// A classroom lesson plan returned by the NPS lesson plans API.
///
/// Identity and title are required. Other documented fields are optional, preserving missing or
/// null values without substituting empty strings or arrays. Every text field keeps the provider's
/// own text: ``gradeLevel`` and ``duration`` are descriptions such as
/// `"Middle School: Sixth Grade through Eighth Grade"` and `"90 Minutes"`, not parsed values.
/// ``parks`` lists park codes as plain strings rather than park objects, and a query's park codes
/// select lesson plans without narrowing this array. Unknown JSON fields are ignored by Codable.
///
/// ```swift
/// let page = try JSONDecoder().decode(NPSCollection<LessonPlan>.self, from: data)
/// for plan in page.data {
///   print(plan.title, plan.parks ?? [])
/// }
/// ```
public struct LessonPlan: Codable, Hashable, Sendable {
  /// Education standards a lesson plan names, each kept as the provider's text.
  ///
  /// Every field is optional. The standard codes in ``elaStandards`` and ``mathStandards`` are
  /// strings such as `"6-8.RH.7"` and `"6.RP.3.d"`, kept as sent, and either array is often
  /// empty. ``stateStandards`` and ``additionalStandards`` are free text, often empty.
  public struct CommonCore: Codable, Hashable, Sendable {
    /// Standards beyond the state and Common Core lists, such as Next Generation Science
    /// Standards, as free text.
    public let additionalStandards: String?

    /// Common Core English language arts standard codes in provider order.
    public let elaStandards: [String]?

    /// Common Core mathematics standard codes in provider order.
    public let mathStandards: [String]?

    /// State education standards as free text.
    public let stateStandards: String?
  }

  private enum CodingKeys: String, CodingKey {
    case commonCore
    case duration
    case gradeLevel
    case id
    case parks
    case questionObjective
    case subjects = "subject"
    case title
    case url
  }

  /// The education standards this lesson plan names.
  public let commonCore: CommonCore?

  /// The expected class time as the provider's text, such as `"60 Minutes"`.
  public let duration: String?

  /// The intended grade range as the provider's text, such as
  /// `"High School: Ninth Grade through Twelfth Grade"`.
  public let gradeLevel: String?

  /// The provider's lesson plan identifier, preserved as sent.
  public let id: String

  /// Codes of the parks this lesson plan relates to, in provider order; often empty.
  public let parks: [String]?

  /// The lesson's guiding question or learning objectives as plain text.
  public let questionObjective: String?

  /// Subject areas such as `"Science"`, decoded from the wire `subject` array.
  public let subjects: [String]?

  /// The lesson plan title, preserved as sent, including quotation marks and invisible characters.
  public let title: String

  /// The lesson plan's page on nps.gov.
  public let url: String?
}
