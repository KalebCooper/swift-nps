#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

/// A provider unit profile with original identifiers and ordering.
public struct NPSUnit: Codable, Hashable, Sendable {
  /// The provider's FullName value, preserved without normalization.
  public let fullName: String
  /// The provider's Network value, preserved without normalization.
  public let network: String?
  /// The provider's NetworkName value, preserved without normalization.
  public let networkName: String?
  /// The provider's Region value, preserved without normalization.
  public let region: String?
  /// The provider's RegionName value, preserved without normalization.
  public let regionName: String?
  /// The provider's StateCodes value, preserved without normalization.
  public let stateCodes: [String]?
  /// The provider's UnitCode value, preserved without normalization.
  public let unitCode: String
  /// The provider's UnitDesignationCode value, preserved without normalization.
  public let unitDesignationCode: String?
  /// The provider's UnitDesignationName value, preserved without normalization.
  public let unitDesignationName: String?
  /// The provider's UnitLifecycle value, preserved without normalization.
  public let unitLifecycle: String
  /// The provider's UnitName value, preserved without normalization.
  public let unitName: String
  /// The provider's UnitSubTypeCode value, preserved without normalization.
  public let unitSubTypeCode: String
  /// The provider's UnitSubTypeName value, preserved without normalization.
  public let unitSubTypeName: String

  private enum CodingKeys: String, CodingKey {
    case fullName = "FullName"
    case network = "Network"
    case networkName = "NetworkName"
    case region = "Region"
    case regionName = "RegionName"
    case stateCodes = "StateCodes"
    case unitCode = "UnitCode"
    case unitDesignationCode = "UnitDesignationCode"
    case unitDesignationName = "UnitDesignationName"
    case unitLifecycle = "UnitLifecycle"
    case unitName = "UnitName"
    case unitSubTypeCode = "UnitSubTypeCode"
    case unitSubTypeName = "UnitSubTypeName"
  }
}
