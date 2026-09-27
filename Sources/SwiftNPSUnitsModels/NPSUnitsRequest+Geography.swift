#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

extension NPSUnitsRequest where Response == UnitCounty {
  /// Creates an inspectable unitCounty request without execution.
  public static func unitCounty(state: String, county: String) throws(UnitEndpoint<UnitCounty>
    .ValidationError) -> Self
  {
    try Self(endpoint: .unitCounty(state: state, county: county))
  }
}

extension NPSUnitsRequest where Response == [UnitGeography] {
  /// Creates an inspectable unitGeographies request without execution.
  public static func unitGeographies(query: UnitGeographyQuery) -> Self {
    Self(endpoint: .unitGeographies(query: query))
  }
}

extension NPSUnitsRequest where Response == [UnitPoint] {
  /// Creates an inspectable unitPoints request without execution.
  public static func unitPoints() -> Self {
    Self(endpoint: .unitPoints())
  }
}

extension NPSUnitsRequest where Response == [UnitNode] {
  /// Creates an inspectable unitSelector request without execution.
  public static func unitSelector() -> Self {
    Self(endpoint: .unitSelector())
  }
}

extension NPSUnitsRequest where Response == UnitState {
  /// Creates an inspectable unitState request without execution.
  public static func unitState(code: String) throws(UnitEndpoint<UnitState>.ValidationError) -> Self
  {
    try Self(endpoint: .unitState(code: code))
  }
}

extension NPSUnitsRequest where Response == [UnitState] {
  /// Creates an inspectable unitStates request without execution.
  public static func unitStates() -> Self {
    Self(endpoint: .unitStates())
  }
}
