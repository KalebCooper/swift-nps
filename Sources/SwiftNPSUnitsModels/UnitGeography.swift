#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

/// A provider geography record preserving raw codes, values and ordering.
public struct UnitGeography: Codable, Hashable, Sendable {
  /// The provider's Code value, without conversion or inferred defaults.
  public let code: String
  /// The provider's Geography value, without conversion or inferred defaults.
  public let geography: String?

  private enum CodingKeys: String, CodingKey {
    case code = "Code"
    case geography = "Geography"
  }
}
