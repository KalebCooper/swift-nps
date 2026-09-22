extension Endpoint where Response == NPSCollection<Article> {
  /// Describes one articles page with filters, text search, and explicit pagination.
  ///
  /// ```swift
  /// let query = try ArticleQuery(limit: 1, parkCodes: [ParkCode("arch")])
  /// print(Endpoint.articles(query: query).path)
  /// // "/articles?limit=1&parkCode=arch&start=0"
  /// ```
  /// - Parameter query: Validated options, encoded without changing their values or order.
  /// - Returns: One endpoint returning the complete ``NPSCollection`` envelope, the same as
  ///   ``collection(_:)``.
  public static func articles(query: ArticleQuery) -> Self {
    collection(query)
  }
}
