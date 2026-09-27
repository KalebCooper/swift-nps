#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

/// The provider relationship route to request.
public enum UnitLinkKind: String, CaseIterable, Codable, Hashable, Sendable {
  /// Every linked unit.
  case all
  /// Functionally linked units.
  case functional
  /// Logically linked units.
  case logical

  var suffix: String { self == .all ? "" : "/" + rawValue }
}
