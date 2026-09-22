extension NPSDataRequest where Response == NPSCollection<Park> {
  /// Describes a lookup for one park code while retaining the provider envelope.
  /// - Parameter parkCode: A validated single park code.
  /// - Returns: A reusable request for ``NPSCollection`` of ``Park``.
  public static func parks(parkCode: ParkCode) -> Self {
    Self(endpoint: .parks(parkCode: parkCode))
  }

  /// Describes a parks query usable for one page or lazy iteration.
  ///
  /// A custom executor sends ``NPSCollectionResolution/endpoint`` and uses
  /// ``NPSCollectionResolution/next(after:)`` when more pages are desired. No request is sent
  /// during construction.
  /// - Parameter query: Validated query options.
  /// - Returns: An inspectable request whose individual response is ``NPSCollection`` of ``Park``.
  public static func parks(query: ParkQuery) -> Self {
    Self(resolution: .collection(NPSCollectionResolution(query)))
  }
}
