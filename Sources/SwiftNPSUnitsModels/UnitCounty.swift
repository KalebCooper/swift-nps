#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

/// A provider county record preserving raw codes, values and ordering.
public struct UnitCounty: Codable, Hashable, Sendable {
  /// The provider's Fips value, without conversion or inferred defaults.
  public let fips: String
  /// The provider's Id value, without conversion or inferred defaults.
  public let id: Int64
  /// The provider's Name value, without conversion or inferred defaults.
  public let name: String
  /// The provider's UnitCodes value, without conversion or inferred defaults.
  public let unitCodes: [String]?

  private enum CodingKeys: String, CodingKey {
    case fips = "Fips"
    case id = "Id"
    case name = "Name"
    case unitCodes = "UnitCodes"
  }
}
