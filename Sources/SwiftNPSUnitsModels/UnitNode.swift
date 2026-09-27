#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

/// A provider node record preserving raw codes, values and ordering.
public struct UnitNode: Codable, Hashable, Sendable {
  /// The provider's DirectInactives value, without conversion or inferred defaults.
  public let directInactives: [UnitLeaf]?
  /// The provider's DirectLinks value, without conversion or inferred defaults.
  public let directLinks: [UnitLeaf]?
  /// The provider's IndirectInactives value, without conversion or inferred defaults.
  public let indirectInactives: [UnitLeaf]?
  /// The provider's IndirectLinks value, without conversion or inferred defaults.
  public let indirectLinks: [UnitLeaf]?
  /// The provider's RegionCode value, without conversion or inferred defaults.
  public let regionCode: String?
  /// The provider's Unit value, without conversion or inferred defaults.
  public let unit: UnitLeaf

  private enum CodingKeys: String, CodingKey {
    case directInactives = "DirectInactives"
    case directLinks = "DirectLinks"
    case indirectInactives = "IndirectInactives"
    case indirectLinks = "IndirectLinks"
    case regionCode = "RegionCode"
    case unit = "Unit"
  }
}
