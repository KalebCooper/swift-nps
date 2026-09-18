# Changelog

All notable changes are documented here. This project follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

### Added

- NPSCollectionQuery, NPSQueryItem, and the generic Endpoint.collection factory shared by every
  offset-paginated collection; ParkQuery conforms and Endpoint.parks(query:) delegates to it.
- NPSCollectionResolution, the closure-free erasure of any collection query inside a request, and
  the generic NPSDataClient.pages(for:) and items(for:) that every collection convenience uses.

### Changed

- Replace ParksResponse with the generic NPSCollection; parks pages are NPSCollection<Park>.
- Rename ParkPaginationError to NPSPaginationError.
- Replace the closed ParkSort enum with the open NPSSort value, and ParkSort.Order with
  NPSSort.Direction. Parks criteria are written as .ascending("fullName") or .descending("parkCode").
- Make ParkQuery.starting(at:) public as an NPSCollectionQuery requirement.
- Rename ParkRequest to NPSDataRequest; its Resolution.parks case becomes Resolution.collection
  carrying an NPSCollectionResolution.
- Replace ParkPageSequence with the generic NPSPageSequence; parks pages are NPSPageSequence<Park>.
- Replace ParkSequence with the generic NPSItemSequence; parks are NPSItemSequence<Park>.
- NPSDataError.pagination carries NPSPaginationError.

## [0.2.0] - 2026-09-17

### Added

- Parks queries with multiple park and state codes, text search, sorting, and explicit pagination.
- Lazy parkPages and parks sequences backed by swifty-networking pagination, with reusable requests.
- Typed pagination failures for unusable metadata, contradictory counts, and nonprogressing offsets.
- Recorded multi-page and state-filtered search responses, query documentation, and a paginated demo.

### Changed

- Raise the swifty-networking dependency minimum to 1.1.0.

## [0.1.0] - 2026-09-13

### Added

- Parks lookup by one validated park code through NPSDataClient, ParkRequest, and Endpoint.
- Explicit API-key configuration using the X-Api-Key header, with typed service and transport errors.
- Codable park details and collection envelopes that preserve provider strings and optional values.
- Inspectable, Hashable requests and validated endpoints supporting consumer-defined responses.
- Recorded Acadia, Yellowstone, empty-result, and missing-key responses with offline behavior tests.
- Documentation catalogs, verification scripts, platform workflows, and an interactive iOS parks demo.

[Unreleased]: https://github.com/KalebCooper/swift-nps/compare/0.2.0...HEAD
[0.2.0]: https://github.com/KalebCooper/swift-nps/compare/0.1.0...0.2.0
[0.1.0]: https://github.com/KalebCooper/swift-nps/releases/tag/0.1.0
