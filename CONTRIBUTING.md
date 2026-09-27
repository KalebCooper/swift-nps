# Contributing to swift-nps

Bug reports, documentation improvements, and focused pull requests are welcome. For a large
addition, open an issue first so we can agree on the scope.

## Getting started

1. Fork and clone the repository.
2. Open the package directory in Xcode 26 or later with Swift 6.2 or later.
3. Select the generated `swift-nps-Package` scheme and an iOS simulator, then press **⌘U** to
   build and run the tests.

The [README](README.md) introduces the package. The
[API documentation](https://kalebcooper.github.io/swift-nps/documentation/) covers both products,
and the [demo app](Examples/SwiftNPSDataDemo) shows them in a SwiftUI app. Close the standalone
package window before opening the demo project.

## Making a change

- Keep models, queries, and endpoint descriptions in `SwiftNPSDataModels`, which has no
  dependencies. Put authentication and request execution in `SwiftNPSData`.
- Preserve NPS identifiers, timestamps, units, nulls, and unknown codes. Document differences
  between recorded responses and the specification.
- Add DocC comments for public symbols. A new endpoint group needs a guide section and a topic
  group in both catalogs. Record public API changes under **Unreleased** in [CHANGELOG.md](CHANGELOG.md).
- Keep declarations alphabetical within logical groups. Match the existing formatting and
  concurrency patterns; retain typed errors and the shared Swift settings.
- Keep platform-specific code guarded by `#if canImport(Darwin)` or `#if HTTPPortable` as
  appropriate. Models use `FoundationEssentials`, with `Foundation` as a fallback.
- Use Swift Testing and recorded responses, with no live API calls in tests. Shared fixtures and
  recording instructions are in [Fixtures/README.md](Sources/SwiftNPSDataTestSupport/Fixtures/README.md).
  Never commit an API key. Give each suite the existing time limit.

## Checking your work

Run the tests in Xcode and the repository checks from the package directory:

```sh
bash Scripts/verify.sh
```

The script checks strict Swift formatting and repository conventions. If you edit the script,
also run `bash Scripts/verify.sh --self-test`.

For portability changes, run both Linux configurations with Docker:

```sh
bash Scripts/linux-test.sh
```

For documentation changes, build both DocC catalogs with warnings treated as errors, models first
and then the client against the models archive. For demo changes, build and run the demo.

## Pull requests

Target `main` and keep each PR focused on one concern. Explain what changed and which checks you
ran. Include a small usage example when changing the public API.

CI checks Linux, Android, the iOS simulator, formatting, and a Release build of the demo.
The documentation workflow publishes to GitHub Pages from `main`. Releases are tagged after
all required checks pass on the release commit.

## Reporting issues

Include the expected behavior, what happened, and a minimal reproduction. For decoding failures,
include the request path and query, along with a redacted response if possible. Leave out API keys
and authentication headers.

IRMA Visitation has independent SDK and Models targets and DocC catalogs. Its public statistics
requests require no Data API key. Record original bodies and provenance before changing a model;
missing months remain absent. Build each Models catalog before its SDK catalog.
