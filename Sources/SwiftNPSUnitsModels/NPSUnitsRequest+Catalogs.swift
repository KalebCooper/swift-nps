#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

extension NPSUnitsRequest where Response == [UnitCollection] {
  /// Creates an inspectable unitCollections request without performing I/O.
  public static func unitCollections() -> Self {
    Self(endpoint: .unitCollections())
  }
}

extension NPSUnitsRequest where Response == UnitDesignation {
  /// Creates an inspectable unitDesignation request without performing I/O.
  public static func unitDesignation(code: String) throws(UnitEndpoint<UnitDesignation>
    .ValidationError) -> Self
  {
    try Self(endpoint: .unitDesignation(code: code))
  }
}

extension NPSUnitsRequest where Response == [UnitDesignation] {
  /// Creates an inspectable unitDesignations request without performing I/O.
  public static func unitDesignations() -> Self {
    Self(endpoint: .unitDesignations())
  }
}

extension NPSUnitsRequest where Response == UnitSubtype {
  /// Creates an inspectable unitSubtype request without performing I/O.
  public static func unitSubtype(code: String) throws(UnitEndpoint<UnitSubtype>.ValidationError)
    -> Self
  {
    try Self(endpoint: .unitSubtype(code: code))
  }
}

extension NPSUnitsRequest where Response == [UnitSubtype] {
  /// Creates an inspectable unitSubtypes request without performing I/O.
  public static func unitSubtypes() -> Self {
    Self(endpoint: .unitSubtypes())
  }
}
