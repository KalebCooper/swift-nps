extension Endpoint where Response == NPSCollection<NewsRelease> {
  /// Describes one news releases page with filters, text search, sorting, and explicit pagination.
  ///
  /// ```swift
  /// let query = try NewsReleaseQuery(
  ///   limit: 1, parkCodes: [ParkCode("yell")], sort: [.descending("releaseDate")])
  /// print(Endpoint.newsReleases(query: query).path)
  /// // "/newsreleases?limit=1&parkCode=yell&sort=-releaseDate&start=0"
  /// ```
  /// - Parameter query: Validated options, encoded without changing their values or order.
  /// - Returns: One endpoint returning the complete ``NPSCollection`` envelope, the same as
  ///   ``collection(_:)``.
  public static func newsReleases(query: NewsReleaseQuery) -> Self {
    collection(query)
  }
}
