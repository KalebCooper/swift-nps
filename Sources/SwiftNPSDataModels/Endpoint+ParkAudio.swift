extension Endpoint where Response == NPSCollection<ParkAudio> {
  /// Describes one park audio page with filters, text search, sorting, and explicit pagination.
  ///
  /// ```swift
  /// let query = try ParkAudioQuery(
  ///   limit: 1, parkCodes: [ParkCode("choh")], sort: [.ascending("title")])
  /// print(Endpoint.parkAudio(query: query).path)
  /// // "/multimedia/audio?limit=1&parkCode=choh&sort=title&start=0"
  /// ```
  /// - Parameter query: Validated options, encoded without changing their values or order.
  /// - Returns: One endpoint returning the complete ``NPSCollection`` envelope, the same as
  ///   ``collection(_:)``.
  public static func parkAudio(query: ParkAudioQuery) -> Self {
    collection(query)
  }
}
