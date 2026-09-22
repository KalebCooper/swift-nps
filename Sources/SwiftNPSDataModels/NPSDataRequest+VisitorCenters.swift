extension NPSDataRequest where Response == NPSCollection<VisitorCenter> {
  /// Describes a visitor centers query usable for one page or lazy iteration.
  ///
  /// A custom executor sends ``NPSCollectionResolution/endpoint`` and uses
  /// ``NPSCollectionResolution/next(after:)`` when more pages are desired. No request is sent
  /// during construction.
  /// - Parameter query: Validated query options.
  /// - Returns: An inspectable request whose individual response is ``NPSCollection`` of
  ///   ``VisitorCenter``.
  public static func visitorCenters(query: VisitorCenterQuery) -> Self {
    Self(resolution: .collection(NPSCollectionResolution(query)))
  }
}
