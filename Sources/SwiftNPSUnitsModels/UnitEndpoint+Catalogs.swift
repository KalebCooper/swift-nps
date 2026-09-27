#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

extension UnitEndpoint where Response == [UnitCollection] {
  /// Describes the unitCollections GET operation, preserving provider input text.
  public static func unitCollections() -> Self {
    route("/collections")
  }
}

extension UnitEndpoint where Response == UnitDesignation {
  /// Describes the unitDesignation GET operation, preserving provider input text.
  public static func unitDesignation(code: String) throws(ValidationError) -> Self {
    route("/designations/" + (try Self.component(code)))
  }
}

extension UnitEndpoint where Response == [UnitDesignation] {
  /// Describes the unitDesignations GET operation, preserving provider input text.
  public static func unitDesignations() -> Self {
    route("/designations")
  }
}

extension UnitEndpoint where Response == UnitSubtype {
  /// Describes the unitSubtype GET operation, preserving provider input text.
  public static func unitSubtype(code: String) throws(ValidationError) -> Self {
    route("/subtypes/" + (try Self.component(code)))
  }
}

extension UnitEndpoint where Response == [UnitSubtype] {
  /// Describes the unitSubtypes GET operation, preserving provider input text.
  public static func unitSubtypes() -> Self {
    route("/subtypes")
  }
}
