#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

/// A provider point record preserving raw codes, values and ordering.
public struct UnitPoint: Codable, Hashable, Sendable {
  /// The provider's Code value, without conversion or inferred defaults.
  public let code: String
  /// The provider's Latitude value, without conversion or inferred defaults.
  public let latitude: Double?
  /// The provider's Longitude value, without conversion or inferred defaults.
  public let longitude: Double?

  private enum CodingKeys: String, CodingKey {
    case code = "Code"
    case latitude = "Latitude"
    case longitude = "Longitude"
  }
}
