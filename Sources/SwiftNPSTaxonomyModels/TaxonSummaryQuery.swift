#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

/// A reusable basic search with explicit paging; no I/O occurs during construction.
public struct TaxonSummaryQuery: Hashable, Sendable {
  /// All results or validated page parameters.
  public let paging: TaxonomyPaging
  /// The exact search and optional filters.
  public let search: TaxonSearch

  let body: Data?
  let method: TaxonomyMethod
  let path: String

  /// Validates the search and provider Int32 paging bounds without normalization.
  public init(paging: TaxonomyPaging = .all, search: TaxonSearch) throws(TaxonomyValidationError) {
    try paging.validate()
    let components = try search.components()
    let parameters =
      components.parameters + [("detail", "basic"), ("format", "json")] + paging.parameters
    body = components.body
    method = components.method
    self.paging = paging
    self.search = search
    path = components.path + "?" + TaxonomyEncoding.query(parameters)
  }

  /// Validates the returned array before advancing by its count. Only an empty page stops.
  /// - Throws: All-mode traversal, oversized pages, or Int32 index overflow.
  public func next(after page: [NPSTaxonSummary]) throws(TaxonomyPaginationError) -> Self? {
    guard case .page(let size, let index) = paging else { throw .allModeUnavailable }
    guard page.count <= size else { throw .oversizedPage }
    guard !page.isEmpty else { return nil }
    let (next, overflow) = index.addingReportingOverflow(page.count)
    guard !overflow, next <= Int32.max else { throw .indexOverflow }
    do {
      return try Self(paging: .page(size: size, startIndex: next), search: search)
    } catch { throw .indexOverflow }
  }

  /// Retains every filter, namespace and body while selecting another starting index.
  /// - Throws: Invalid Int32 bounds, or all mode which has no page size.
  public func starting(at index: Int) throws(TaxonomyValidationError) -> Self {
    guard case .page(let size, _) = paging else { throw .invalidPageSize }
    return try Self(paging: .page(size: size, startIndex: index), search: search)
  }
}
