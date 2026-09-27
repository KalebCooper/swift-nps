#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

import HTTPCore
import SwiftNPSTaxonomyModels

extension NPSTaxonomyClient {
  /// Lazily yields individual records from the request's pages.
  public func items(for request: NPSTaxonomyRequest<[NPSTaxonProfile]>) -> TaxonProfileItemSequence
  {
    TaxonProfileItemSequence(pages: pages(for: request))
  }

  /// Lazily yields individual records from the request's pages.
  public func items(for request: NPSTaxonomyRequest<[NPSTaxonSummary]>) -> TaxonSummaryItemSequence
  {
    TaxonSummaryItemSequence(pages: pages(for: request))
  }

  /// Executes a request lazily. Endpoint-only requests yield one response; all-mode queries fail before I/O.
  public func pages(for request: NPSTaxonomyRequest<[NPSTaxonProfile]>) -> TaxonProfilePageSequence
  {
    let query: TaxonProfileQuery?
    if case .profile(let value) = request.query { query = value } else { query = nil }
    let pages = client.pages(Self.request(for: request.endpoint), as: [NPSTaxonProfile].self) {
      response, sent in
      // The callback cannot throw; the iterator reports validation failures before yielding.
      guard let query,
        let items = URLComponents(string: sent.path)?.queryItems,
        let raw = items.first(where: { $0.name == "startIndex" })?.value,
        let index = Int(raw),
        let current = try? query.starting(at: index),
        TaxonomyEndpoint.taxonProfilesResponse(query: current).path == sent.path,
        let next = try? current.next(after: response.value)
      else { return nil }
      return .request(Self.request(for: .taxonProfilesResponse(query: next)))
    }
    return TaxonProfilePageSequence(base: pages, query: query)
  }

  /// Executes a request lazily. Endpoint-only requests yield one response; all-mode queries fail before I/O.
  public func pages(for request: NPSTaxonomyRequest<[NPSTaxonSummary]>) -> TaxonSummaryPageSequence
  {
    let query: TaxonSummaryQuery?
    if case .summary(let value) = request.query { query = value } else { query = nil }
    let pages = client.pages(Self.request(for: request.endpoint), as: [NPSTaxonSummary].self) {
      response, sent in
      // The callback cannot throw; the iterator reports validation failures before yielding.
      guard let query,
        let items = URLComponents(string: sent.path)?.queryItems,
        let raw = items.first(where: { $0.name == "startIndex" })?.value,
        let index = Int(raw),
        let current = try? query.starting(at: index),
        TaxonomyEndpoint.taxonSummariesResponse(query: current).path == sent.path,
        let next = try? current.next(after: response.value)
      else { return nil }
      return .request(Self.request(for: .taxonSummariesResponse(query: next)))
    }
    return TaxonSummaryPageSequence(base: pages, query: query)
  }

  /// Lazily reads bare-array pages, including the terminal empty response.
  public func taxonProfilePages(query: TaxonProfileQuery) -> TaxonProfilePageSequence {
    pages(for: .taxonProfilesResponse(query: query))
  }

  /// Lazily reads records without prefetching, changing detail, or removing duplicates.
  public func taxonProfiles(query: TaxonProfileQuery) -> TaxonProfileItemSequence {
    items(for: .taxonProfilesResponse(query: query))
  }

  /// Lazily reads records without prefetching, changing detail, or removing duplicates.
  public func taxonSummaries(query: TaxonSummaryQuery) -> TaxonSummaryItemSequence {
    items(for: .taxonSummariesResponse(query: query))
  }

  /// Lazily reads bare-array pages, including the terminal empty response.
  public func taxonSummaryPages(query: TaxonSummaryQuery) -> TaxonSummaryPageSequence {
    pages(for: .taxonSummariesResponse(query: query))
  }

}
