/// An open ownership classification; it does not establish public access.
public struct LandmarkOwner: Codable, Hashable, Sendable {
  /// The provider's ID value, preserved without inferred defaults.
  public let id: Int64
  /// The provider's OwnerTypeId value, preserved without inferred defaults.
  public let ownerTypeID: Int
  /// The provider's OwnerTypeLabel value, preserved without inferred defaults.
  public let ownerTypeLabel: String

  private enum CodingKeys: String, CodingKey {
    case id = "ID"
    case ownerTypeID = "OwnerTypeId"
    case ownerTypeLabel = "OwnerTypeLabel"
  }
}
