#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

extension NPSUnitsRequest where Response == [NPSUnit] {
  /// Creates an inspectable linkedUnits request without performing I/O.
  public static func linkedUnits(unitCode: String, kind: UnitLinkKind) throws(UnitEndpoint<
    [NPSUnit]
  >.ValidationError) -> Self {
    try Self(endpoint: .linkedUnits(unitCode: unitCode, kind: kind))
  }
}

extension NPSUnitsRequest where Response == [NPSUnit] {
  /// Creates an inspectable units request without performing I/O.
  public static func units() -> Self {
    Self(endpoint: .units())
  }
}

extension NPSUnitsRequest where Response == [NPSUnit] {
  /// Creates an inspectable units request without performing I/O.
  public static func units(matching searchTerm: String) throws(UnitEndpoint<[NPSUnit]>
    .ValidationError) -> Self
  {
    try Self(endpoint: .units(matching: searchTerm))
  }
}
