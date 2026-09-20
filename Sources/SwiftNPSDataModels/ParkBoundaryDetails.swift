/// The naming details a park boundary feature carries.
///
/// These are not the park summary shape used by other endpoints: there is no park code, state list,
/// or URL, and the park code appears only as an uppercase alias name such as `"YELL"`.
///
/// ```swift
/// print(details.fullName ?? "", details.designation?.abbreviation ?? "")
/// ```
public struct ParkBoundaryDetails: Codable, Hashable, Sendable {
  /// Another name the park is known by, such as its uppercase park code.
  public struct Alias: Codable, Hashable, Sendable {
    /// Whether the alias is in current use, as a JSON Boolean.
    public let current: Bool?

    /// The alias identifier as sent.
    public let id: String?

    /// The alias itself, such as `"YELL"`.
    public let name: String?

    /// The identifier of the park the alias names.
    public let parkId: String?
  }

  /// The kind of park unit, such as a national park.
  public struct Designation: Codable, Hashable, Sendable {
    /// The short form, such as `"NP"`.
    public let abbreviation: String?

    /// The provider's description, such as `"National Park"`.
    public let description: String?

    /// The designation identifier as sent, matching ``ParkBoundaryDetails/designationId``.
    public let id: String?

    /// The designation's name, such as `"National Park"`.
    public let name: String?

    /// The identifier of the designation's category as sent.
    public let parkDesignationCategoryId: String?
  }

  /// Other names for the park in provider order.
  public let aliases: [Alias]?

  /// The park's alternate name, such as `"Yellowstone"`.
  public let alternateName: String?

  /// The park's designation as a nested object.
  public let designation: Designation?

  /// The designation identifier as sent.
  public let designationId: String?

  /// The park's full name, such as `"Yellowstone National Park"`.
  public let fullName: String?

  /// The park's short name, such as `"Yellowstone"`.
  public let name: String?
}
