/// Explicit selection of an unpaged response or a bounded page.
public enum TaxonomyPaging: Hashable, Sendable {
  /// Omit both paging parameters; the provider returns all matching records.
  case all
  /// Select a page. Query construction validates both values.
  case page(size: Int, startIndex: Int)

  var parameters: [(String, String)] {
    switch self {
    case .all: []
    case .page(let size, let index): [("pageSize", String(size)), ("startIndex", String(index))]
    }
  }

  func validate() throws(TaxonomyValidationError) {
    if case .page(let size, let index) = self {
      guard size > 0 && size <= Int32.max else { throw .invalidPageSize }
      guard index >= 0 && index <= Int32.max else { throw .invalidStartIndex }
    }
  }
}
