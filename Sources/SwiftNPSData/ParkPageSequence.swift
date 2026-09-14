import HTTPCore
import SwiftNPSDataModels

/// Lazy parks pages fetched through swifty-networking's pagination API.
///
/// Each iterator starts independently. Nothing is sent until its next page is requested, and
/// there is no prefetch. Breaking iteration prevents subsequent requests. Metadata remains in
/// each ``/SwiftNPSDataModels/ParksResponse``; malformed pagination throws instead of ending quietly.
///
/// ```swift
/// for try await page in client.parkPages(query: query) {
///   print(page.total)
/// }
/// ```
public struct ParkPageSequence: AsyncSequence, Sendable {
  /// One provider page with its collection metadata.
  public typealias Element = ParksResponse
  /// The only failure produced by iteration.
  public typealias Failure = NPSDataError

  /// An independent iterator over parks pages.
  public struct Iterator: AsyncIteratorProtocol {
    /// One provider page.
    public typealias Element = ParksResponse
    /// The typed service, transport, or pagination failure.
    public typealias Failure = NPSDataError

    private var base: PageSequence<ParksResponse>.Iterator
    private var finished = false
    private var query: ParkQuery?

    init(base: PageSequence<ParksResponse>.Iterator, query: ParkQuery?) {
      self.base = base
      self.query = query
    }

    /// Fetches and validates the next page, or returns nil after completion or failure.
    /// - Returns: The next complete provider envelope.
    /// - Throws: ``NPSDataError/pagination(_:)`` for unusable metadata, or service and transport
    ///   failures including cancellation. A page with invalid pagination is not yielded.
    public mutating func next(
      isolation actor: isolated (any Actor)? = #isolation
    ) async throws(NPSDataError) -> ParksResponse? {
      guard !finished else { return nil }
      finished = true
      let page: ParksResponse
      do throws(TransportError) {
        guard let response = try await base.next(isolation: actor) else { return nil }
        page = response.value
      } catch {
        throw NPSDataError(error)
      }
      if let query {
        do {
          self.query = try query.next(after: page)
        } catch {
          throw .pagination(error)
        }
        finished = self.query == nil
      }
      return page
    }
  }

  private let base: PageSequence<ParksResponse>
  private let query: ParkQuery?

  init(base: PageSequence<ParksResponse>, query: ParkQuery?) {
    self.base = base
    self.query = query
  }

  /// Creates an iterator that has not yet sent a request.
  /// - Returns: An independent traversal beginning at the original query offset.
  public func makeAsyncIterator() -> Iterator {
    Iterator(base: base.makeAsyncIterator(), query: query)
  }
}
