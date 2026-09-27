#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

/// A provider state record preserving raw codes, values and ordering.
public struct UnitState: Codable, Hashable, Sendable {
  /// The provider's Code value, without conversion or inferred defaults.
  public let code: String
  /// The provider's Counties value, without conversion or inferred defaults.
  public let counties: [UnitCounty]?
  /// The provider's FipsCode value, without conversion or inferred defaults.
  public let fipsCode: String
  /// The provider's Name value, without conversion or inferred defaults.
  public let name: String
  /// The provider's PhysicalRegions value, without conversion or inferred defaults.
  public let physicalRegions: [String]?

  private enum CodingKeys: String, CodingKey {
    case code = "Code"
    case counties = "Counties"
    case fipsCode = "FipsCode"
    case name = "Name"
    case physicalRegions = "PhysicalRegions"
  }
}
