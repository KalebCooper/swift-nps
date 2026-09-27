#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

extension UnitEndpoint where Response == [NPSUnit] {
  /// Describes the linkedUnits GET operation, preserving provider input text.
  public static func linkedUnits(unitCode: String, kind: UnitLinkKind) throws(ValidationError)
    -> Self
  {
    route("/" + (try Self.component(unitCode)) + "/linked" + kind.suffix)
  }
}

extension UnitEndpoint where Response == [NPSUnit] {
  /// Describes the units GET operation, preserving provider input text.
  public static func units() -> Self {
    route("/")
  }
}

extension UnitEndpoint where Response == [NPSUnit] {
  /// Describes the units GET operation, preserving provider input text.
  public static func units(matching searchTerm: String) throws(ValidationError) -> Self {
    route("/" + (try Self.component(searchTerm)))
  }
}
