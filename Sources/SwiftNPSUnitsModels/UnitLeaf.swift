#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

/// A provider leaf record preserving raw codes, values and ordering.
public struct UnitLeaf: Codable, Hashable, Sendable {
  /// The provider's Code value, without conversion or inferred defaults.
  public let code: String
  /// The provider's FullName value, without conversion or inferred defaults.
  public let fullName: String?
  /// The provider's Lifecycle value, without conversion or inferred defaults.
  public let lifecycle: Int
  /// The provider's StateCodes value, without conversion or inferred defaults.
  public let stateCodes: String?
  /// The provider's SubTypeDisplay value, without conversion or inferred defaults.
  public let subTypeDisplay: String
  /// The provider's TypeDisplay value, without conversion or inferred defaults.
  public let typeDisplay: String
  /// The provider's TypeName value, without conversion or inferred defaults.
  public let typeName: String

  private enum CodingKeys: String, CodingKey {
    case code = "Code"
    case fullName = "FullName"
    case lifecycle = "Lifecycle"
    case stateCodes = "StateCodes"
    case subTypeDisplay = "SubTypeDisplay"
    case typeDisplay = "TypeDisplay"
    case typeName = "TypeName"
  }
}
