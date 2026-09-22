extension NPSDataRequest where Response == NPSCollection<NewsRelease> {
  /// Describes a news releases query usable for one page or lazy iteration.
  ///
  /// A custom executor sends ``NPSCollectionResolution/endpoint`` and uses
  /// ``NPSCollectionResolution/next(after:)`` when more pages are desired. No request is sent
  /// during construction.
  /// - Parameter query: Validated query options.
  /// - Returns: An inspectable request whose individual response is ``NPSCollection`` of
  ///   ``NewsRelease``.
  public static func newsReleases(query: NewsReleaseQuery) -> Self {
    Self(resolution: .collection(NPSCollectionResolution(query)))
  }
}
