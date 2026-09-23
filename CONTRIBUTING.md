# Contributing to swift-nps

Thanks for your interest. Contributions are welcome; every change to the public surface lands in
`CHANGELOG.md`.

## Getting started

1. Fork and clone the repository.
2. Open the package directory in Xcode 26 or later.
3. Build and run tests on Xcode's generated `swift-nps-Package` scheme (⌘U), or run `swift test`
   from the command line.

## Guidelines

- **Layers:** `SwiftNPSDataModels` depends on nothing. It never imports swifty-networking,
  `URLSession`, or any transport type; if a type needs one to exist, it belongs in `SwiftNPSData`.
  `SwiftNPSData` adds behavior, never models.
- **Public API:** every public symbol needs a DocC comment. A new endpoint group gets a prose
  section and a topic group in both documentation catalogs.
- **Provider data:** keep identifiers, timestamps, units, nulls, and unknown codes as NPS sends
  them. Where the live API and its specification disagree, the live response wins; document the
  difference rather than papering over it.
- **Portability:** `SwiftNPSDataModels` imports Foundation only as the fallback to
  `FoundationEssentials`. Darwin-only code sits inside `#if canImport(Darwin)`, and code that uses
  the portable transport sits inside `#if HTTPPortable`. `Scripts/linux-test.sh` runs the suite on
  Linux in Docker, with the trait on and off.
- **Concurrency:** no actors on the client; shared state is `Mutex` or `Atomic`. Errors are typed
  and mapped at each layer. Inject a `Clock`; never sleep or read the wall clock.
- **Tests:** Swift Testing only, and never against the live API. Record each response once into
  `Sources/SwiftNPSDataTestSupport/Fixtures/`, document the exact request in the `Fixture` case,
  and never commit an API key. Every `@Suite` carries `.timeLimit(.minutes(suiteTimeLimitMinutes))`,
  so a test that stops making progress fails its suite instead of holding the run open.
- **Style:** `swift format lint --strict --recursive Sources Tests` must report zero findings.
  Declarations are ordered alphabetically within their groupings unless an inline comment says why
  not.
- **Gate:** `Scripts/verify.sh` runs the format lint and every repository invariant the compiler
  cannot see. Run it before every commit; it must exit 0. `Scripts/verify.sh --self-test` proves
  each check still trips on a planted violation.
- **Scope:** no macros, no interceptor or middleware pipelines. Open an issue to discuss additions
  before investing in a large PR.

## Pull requests

- Target `main`. One concern per PR.
- Update `CHANGELOG.md` under **Unreleased**.

## Verification and releases

Before a release, run the package tests on Xcode's generated `swift-nps-Package` scheme, both Linux
configurations with `Scripts/linux-test.sh`, strict lint, and `Scripts/verify.sh`. Build both DocC
catalogs with warnings treated as errors, models first, then the SDK against the models archive.
Build and run the demo with the package window closed in Xcode.

CI repeats Linux, Android, iOS simulator, and lint checks on pull requests and on `main`, and builds
the demo in Release configuration. The documentation workflow builds both catalogs and publishes
them to GitHub Pages only from `main`. Tag a release after all lanes pass on the release commit; a
local pass does not establish hosted or Android success.

## Reporting issues

Include a minimal reproduction where possible. For a decoding failure, include the request path and
query that produced it, never your API key.
