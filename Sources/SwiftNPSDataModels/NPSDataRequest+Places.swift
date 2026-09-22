extension NPSDataRequest where Response == NPSCollection<Place> {
  /// Describes a places query usable for one page or lazy iteration.
  ///
  /// A custom executor sends ``NPSCollectionResolution/endpoint`` and uses
  /// ``NPSCollectionResolution/next(after:)`` when more pages are desired. No request is sent
  /// during construction.
  /// - Parameter query: Validated query options.
  /// - Returns: An inspectable request whose individual response is ``NPSCollection`` of
  ///   ``Place``.
  public static func places(query: PlaceQuery) -> Self {
    Self(resolution: .collection(NPSCollectionResolution(query)))
  }
}
