# Changelog

All notable changes are documented here. This project follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

## [0.1.0] - 2026-09-13

### Added

- Parks lookup by one validated park code through NPSDataClient, ParkRequest, and Endpoint.
- Explicit API-key configuration using the X-Api-Key header, with typed service and transport errors.
- Codable park details and collection envelopes that preserve provider strings and optional values.
- Inspectable, Hashable requests and validated endpoints supporting consumer-defined responses.
- Recorded Acadia, Yellowstone, empty-result, and missing-key responses with offline behavior tests.
- Documentation catalogs, verification scripts, platform workflows, and an interactive iOS parks demo.

[Unreleased]: https://github.com/KalebCooper/swift-nps/compare/0.1.0...HEAD
[0.1.0]: https://github.com/KalebCooper/swift-nps/releases/tag/0.1.0
