import SwiftNPSDataModels

extension NPSDataClient {
  /// Iterates individual lesson plans, fetching the next page only when needed.
  /// - Parameter query: Validated query options, including page size and starting offset.
  /// - Returns: Lesson plans in provider order, without deduplication, throwing ``NPSDataError``.
  public func lessonPlans(query: LessonPlanQuery) -> NPSItemSequence<LessonPlan> {
    items(for: .lessonPlans(query: query))
  }

  /// Iterates complete lesson plans pages with filters, text search, sorting, and explicit
  /// pagination.
  /// - Parameter query: Validated options shared by each request except its advancing offset.
  /// - Returns: A lazy sequence retaining each provider envelope and throwing ``NPSDataError``.
  public func lessonPlanPages(query: LessonPlanQuery) -> NPSPageSequence<LessonPlan> {
    pages(for: .lessonPlans(query: query))
  }
}
