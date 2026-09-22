extension Endpoint where Response == NPSCollection<LessonPlan> {
  /// Describes one lesson plans page with filters, text search, sorting, and explicit pagination.
  ///
  /// ```swift
  /// let query = try LessonPlanQuery(
  ///   limit: 1, parkCodes: [ParkCode("tusk")], searchText: "climate",
  ///   sort: [.descending("title")])
  /// print(Endpoint.lessonPlans(query: query).path)
  /// // "/lessonplans?limit=1&parkCode=tusk&q=climate&sort=-title&start=0"
  /// ```
  /// - Parameter query: Validated options, encoded without changing their values or order.
  /// - Returns: One endpoint returning the complete ``NPSCollection`` envelope, the same as
  ///   ``collection(_:)``.
  public static func lessonPlans(query: LessonPlanQuery) -> Self {
    collection(query)
  }
}
