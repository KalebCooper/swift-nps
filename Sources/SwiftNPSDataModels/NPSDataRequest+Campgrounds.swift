extension NPSDataRequest where Response == NPSCollection<Campground> {
  /// Describes a campgrounds query usable for one page or lazy iteration.
  ///
  /// A custom executor sends ``NPSCollectionResolution/endpoint`` and uses
  /// ``NPSCollectionResolution/next(after:)`` when more pages are desired. No request is sent
  /// during construction.
  /// - Parameter query: Validated query options.
  /// - Returns: An inspectable request whose individual response is ``NPSCollection`` of
  ///   ``Campground``.
  public static func campgrounds(query: CampgroundQuery) -> Self {
    Self(resolution: .collection(NPSCollectionResolution(query)))
  }
}
