import SwiftNPSDataModels

extension NPSDataClient {
  /// Lazily flattens event pages, preserving provider order and repeated identifiers.
  /// - Parameter request: An inspectable event operation.
  /// - Returns: An independent traversal buffering at most one page.
  public func items(for request: NPSDataRequest<ParkEventCollection>) -> ParkEventItemSequence {
    ParkEventItemSequence(pages: pages(for: request))
  }

  /// Lazily executes an event request using validated page-number continuation.
  ///
  /// Expanded query requests fail before sending. Execute those with `value(for:)` for one
  /// response. Endpoint-only requests yield one response because they declare no continuation.
  /// - Parameter request: The initial operation and its continuation settings.
  /// - Returns: Independent iterators with no prefetch, retries, or deduplication.
  public func pages(for request: NPSDataRequest<ParkEventCollection>) -> ParkEventPageSequence {
    let endpoint: Endpoint<ParkEventCollection>
    let resolution: ParkEventResolution<ParkEventCollection>?
    switch request.resolution {
    case .collection:
      preconditionFailure("An offset collection resolution cannot describe an event response.")
    case .endpoint(let value):
      endpoint = value
      resolution = nil
    case .parkEvents(let value):
      endpoint = value.endpoint
      resolution = value
    }
    let pages = client.pages(self.request(for: endpoint), as: ParkEventCollection.self) {
      response, sent in
      // This callback cannot throw. The wrapper reports errors before yielding the page.
      // Match the actual sent path so a mismatched echo cannot schedule another request.
      guard let resolution, !resolution.query.expandRecurring,
        let page = response.value.page, page.errors.isEmpty,
        let number = Int(page.pageNumber)
      else { return nil }
      let current = ParkEventResolution<ParkEventCollection>(
        resolution.query.starting(at: number))
      guard current.endpoint.path == sent.path,
        let next = try? current.next(after: response.value)
      else { return nil }
      var following = sent
      following.path = next.endpoint.path
      return .request(following)
    }
    return ParkEventPageSequence(base: pages, resolution: resolution)
  }

  /// Iterates ordinary event pages starting at the query's page number.
  /// - Parameter query: Validated event filters and page settings.
  /// - Returns: Lazy pages. Expansion is rejected on the first read, before sending.
  public func parkEventPages(query: ParkEventQuery) -> ParkEventPageSequence {
    pages(for: .parkEvents(query: query))
  }

  /// Iterates individual events without reordering or removing repeated identifiers.
  /// - Parameter query: Validated event filters and page settings.
  /// - Returns: Lazy events. Expansion is rejected on the first read, before sending.
  public func parkEvents(query: ParkEventQuery) -> ParkEventItemSequence {
    items(for: .parkEvents(query: query))
  }
}
