import HTTPCore
import SwiftNPSDataModels

/// Lazy collection pages fetched through swifty-networking's pagination API.
///
/// Each iterator starts independently. Nothing is sent until its next page is requested, and
/// there is no prefetch. Breaking iteration prevents subsequent requests. Metadata remains in
/// each ``/SwiftNPSDataModels/NPSCollection``; malformed pagination throws instead of ending quietly.
///
/// ```swift
/// for try await page in client.parkPages(query: query) {
///   print(page.total)
/// }
/// ```
public struct NPSPageSequence<Item: Codable & Hashable & Sendable>: AsyncSequence, Sendable {
  /// One provider page with its collection metadata.
  public typealias Element = NPSCollection<Item>
  /// The only failure produced by iteration.
  public typealias Failure = NPSDataError

  /// An independent iterator over collection pages.
  public struct Iterator: AsyncIteratorProtocol {
    /// One provider page.
    public typealias Element = NPSCollection<Item>
    /// The typed service, transport, or pagination failure.
    public typealias Failure = NPSDataError

    private var base: PageSequence<NPSCollection<Item>>.Iterator
    private var finished = false
    private var resolution: NPSCollectionResolution<NPSCollection<Item>>?

    init(
      base: PageSequence<NPSCollection<Item>>.Iterator,
      resolution: NPSCollectionResolution<NPSCollection<Item>>?
    ) {
      self.base = base
      self.resolution = resolution
    }

    /// Fetches and validates the next page, or returns nil after completion or failure.
    /// - Returns: The next complete provider envelope.
    /// - Throws: ``NPSDataError/pagination(_:)`` for unusable metadata, or service and transport
    ///   failures including cancellation. A page with invalid pagination is not yielded.
    public mutating func next(
      isolation actor: isolated (any Actor)? = #isolation
    ) async throws(NPSDataError) -> NPSCollection<Item>? {
      guard !finished else { return nil }
      finished = true
      let page: NPSCollection<Item>
      do throws(TransportError) {
        guard let response = try await base.next(isolation: actor) else { return nil }
        page = response.value
      } catch {
        throw NPSDataError(error)
      }
      if let resolution {
        do {
          self.resolution = try resolution.next(after: page)
        } catch {
          throw .pagination(error)
        }
        finished = self.resolution == nil
      }
      return page
    }
  }

  private let base: PageSequence<NPSCollection<Item>>
  private let resolution: NPSCollectionResolution<NPSCollection<Item>>?

  init(
    base: PageSequence<NPSCollection<Item>>,
    resolution: NPSCollectionResolution<NPSCollection<Item>>?
  ) {
    self.base = base
    self.resolution = resolution
  }

  /// Creates an iterator that has not yet sent a request.
  /// - Returns: An independent traversal beginning at the original query offset.
  public func makeAsyncIterator() -> Iterator {
    Iterator(base: base.makeAsyncIterator(), resolution: resolution)
  }
}
