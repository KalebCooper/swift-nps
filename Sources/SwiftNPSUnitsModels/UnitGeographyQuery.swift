#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

/// A single-response geography request preserving raw WKT or GML text.
public struct UnitGeographyQuery: Hashable, Sendable {
  /// A geography option or search term is not supported.
  public enum ValidationError: Error, Hashable, Sendable {
    /// The search term cannot be serialized safely.
    case invalidSearchTerm
    /// The format or detail is outside the documented options.
    case unsupportedOption
  }

  /// The requested text format, wkt or gml; nil leaves the provider default.
  public let dataFormat: String?
  /// The requested detail, envelope, convexhull or feature; nil leaves the provider default.
  public let detail: String?
  /// The exact code, name or semicolon-separated search terms.
  public let searchTerm: String

  var path: String {
    let encoded: String
    do { encoded = try UnitEndpoint<[UnitGeography]>.component(searchTerm) } catch {
      preconditionFailure("An immutable validated search term remains serializable.")
    }
    var items: [String] = []
    if let dataFormat { items.append("dataformat=" + dataFormat) }
    if let detail { items.append("detail=" + detail) }
    items.append("format=json")
    return "/" + encoded + "/geography?" + items.joined(separator: "&")
  }

  /// Validates explicit options rather than accepting the provider's silent fallback.
  /// - Parameters:
  ///   - dataFormat: Either wkt or gml, or nil to omit it.
  ///   - detail: Either envelope, convexhull or feature, or nil to omit it.
  ///   - searchTerm: Unmodified provider search text.
  public init(dataFormat: String? = nil, detail: String? = nil, searchTerm: String)
    throws(ValidationError)
  {
    do { _ = try UnitEndpoint<[UnitGeography]>.component(searchTerm) } catch {
      throw .invalidSearchTerm
    }
    guard dataFormat == nil || ["wkt", "gml"].contains(dataFormat ?? ""),
      detail == nil || ["envelope", "convexhull", "feature"].contains(detail ?? "")
    else { throw .unsupportedOption }
    self.dataFormat = dataFormat
    self.detail = detail
    self.searchTerm = searchTerm
  }
}
