extension NPSDataRequest where Response == ParkEventCollection {
  /// Describes events for single-page execution or ordinary lazy traversal.
  /// - Parameter query: Validated filters; expansion supports single-page execution only.
  /// - Returns: An inspectable request retaining its concrete response type.
  public static func parkEvents(query: ParkEventQuery) -> Self {
    Self(resolution: .parkEvents(ParkEventResolution(query)))
  }
}
