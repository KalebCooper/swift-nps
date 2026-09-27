#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

extension UnitEndpoint where Response == UnitCounty {
  /// Describes the unitCounty GET operation without modifying provider identifiers.
  public static func unitCounty(state: String, county: String) throws(ValidationError) -> Self {
    route("/states/" + (try Self.component(state)) + "/" + (try Self.component(county)))
  }
}

extension UnitEndpoint where Response == [UnitGeography] {
  /// Describes the unitGeographies GET operation without modifying provider identifiers.
  public static func unitGeographies(query: UnitGeographyQuery) -> Self {
    guard let endpoint = Self(path: query.path) else {
      preconditionFailure("A validated geography query produces a safe service path.")
    }
    return endpoint
  }
}

extension UnitEndpoint where Response == [UnitPoint] {
  /// Describes the unitPoints GET operation without modifying provider identifiers.
  public static func unitPoints() -> Self {
    route("/unitpoints")
  }
}

extension UnitEndpoint where Response == [UnitNode] {
  /// Describes the unitSelector GET operation without modifying provider identifiers.
  public static func unitSelector() -> Self {
    route("/unitselector")
  }
}

extension UnitEndpoint where Response == UnitState {
  /// Describes the unitState GET operation without modifying provider identifiers.
  public static func unitState(code: String) throws(ValidationError) -> Self {
    route("/states/" + (try Self.component(code)))
  }
}

extension UnitEndpoint where Response == [UnitState] {
  /// Describes the unitStates GET operation without modifying provider identifiers.
  public static func unitStates() -> Self {
    route("/states")
  }
}
