import SwiftNPSTaxonomy
import SwiftNPSTaxonomyModels
import SwiftUI

struct TaxonomyExplorerView: View {
  private enum Operation: String, CaseIterable {
    case categories = "Categories"
    case codes = "Batch codes"
    case commonName = "Common name"
    case lookup = "Single code"
    case options = "Query options"
    case ranks = "Ranks"
    case scientificName = "Scientific name"
    case sourceTree = "Source tree"
    case sources = "Sources"
  }

  @State private var category = ""
  @State private var code = "81838"
  @State private var codes = "81838,719252,719251"
  @State private var kind = TaxonCodeKind.nps
  @State private var name = "hawk"
  @State private var nextProfile: TaxonProfileQuery?
  @State private var nextSummary: TaxonSummaryQuery?
  @State private var operation = Operation.lookup
  @State private var optionKind = TaxonomyOptionKind.codeType
  @State private var pageSize = "10"
  @State private var profile = false
  @State private var requestTask: Task<Void, Never>?
  @State private var rows: [String] = []
  @State private var source = ""
  @State private var sourceCode = "ITIS"
  @State private var status = "Choose an operation, then load records."
  @State private var submission = TaxonomySubmission.get

  var body: some View {
    Form {
      Section("Request") {
        Picker("Operation", selection: $operation) {
          ForEach(Operation.allCases, id: \.self) { Text($0.rawValue).tag($0) }
        }
        if operation == .codes { field("Codes (comma separated)", text: $codes) }
        if operation == .lookup || operation == .codes {
          if operation == .lookup { field("Taxon code", text: $code) }
          Picker("Code namespace", selection: $kind) {
            Text("NPS taxon code").tag(TaxonCodeKind.nps)
            Text("ITIS TSN").tag(TaxonCodeKind.itis)
          }
        }
        if operation == .codes {
          Picker("Submission", selection: $submission) {
            Text("GET query").tag(TaxonomySubmission.get)
            Text("POST JSON").tag(TaxonomySubmission.post)
          }
        }
        if [.commonName, .scientificName].contains(operation) {
          field("Name", text: $name)
          field("Category (optional)", text: $category)
          field("Source (optional)", text: $source)
        }
        if [.codes, .commonName, .scientificName].contains(operation) {
          field("Page size", text: $pageSize)
        }
        if [.codes, .commonName, .lookup, .scientificName, .sources].contains(operation) {
          Toggle("Full profile", isOn: $profile)
        }
        if operation == .sourceTree { field("Source code", text: $sourceCode) }
        if operation == .options {
          Picker("Options for", selection: $optionKind) {
            ForEach(
              [TaxonomyOptionKind.category, .codeType, .detail, .paging, .source], id: \.self
            ) {
              Text($0.rawValue).tag($0)
            }
          }
        }
        Button("Load records") { load() }.disabled(requestTask != nil)
        if nextProfile != nil || nextSummary != nil {
          Button("Load more") { load(continuing: true) }.disabled(requestTask != nil)
        }
        if requestTask != nil { Button("Cancel", action: cancel) }
      }
      Section {
        Text(status)
        ForEach(Array(rows.enumerated()), id: \.offset) { _, row in Text(row) }
      } footer: {
        Text(
          "NPS taxon codes and ITIS TSNs are different namespaces. External source links are data only. No Data API key is required."
        )
      }
    }
    .navigationTitle("Taxonomy")
    .onChange(of: [category, code, codes, name, pageSize, source, sourceCode]) { reset() }
    .onChange(of: kind) { reset() }
    .onChange(of: operation) { reset() }
    .onChange(of: optionKind) { reset() }
    .onChange(of: profile) { reset() }
    .onChange(of: submission) { reset() }
    .onDisappear(perform: cancel)
  }

  private func cancel() {
    guard requestTask != nil else { return }
    requestTask?.cancel()
    requestTask = nil
    status = "Cancelled."
  }

  private func field(_ title: String, text: Binding<String>) -> some View {
    LabeledContent(title) {
      TextField(title, text: text).multilineTextAlignment(.trailing)
        .textInputAutocapitalization(.never).autocorrectionDisabled()
    }
  }

  private func load(continuing: Bool = false) {
    if !continuing {
      rows = []
      nextProfile = nil
      nextSummary = nil
    }
    status = "Loading…"
    let capturedCategory = category
    let capturedCode = code
    let capturedCodes = codes
    let capturedKind = kind
    let capturedName = name
    let capturedNextProfile = nextProfile
    let capturedNextSummary = nextSummary
    let capturedOperation = operation
    let capturedOptionKind = optionKind
    let capturedPageSize = pageSize
    let capturedProfile = profile
    let capturedSource = source
    let capturedSourceCode = sourceCode
    let capturedSubmission = submission
    requestTask = Task {
      guard !Task.isCancelled else { return }
      do {
        let client = NPSTaxonomyClient()
        let result: [String]
        var followingProfile: TaxonProfileQuery?
        var followingSummary: TaxonSummaryQuery?
        switch capturedOperation {
        case .categories:
          result = try await client.taxonomicCategories().map { "\($0.name) · \($0.code)" }
        case .codes, .commonName, .scientificName:
          guard let size = Int(capturedPageSize) else {
            throw TaxonomyValidationError.invalidPageSize
          }
          let category = capturedCategory.isEmpty ? nil : capturedCategory
          let source = capturedSource.isEmpty ? nil : capturedSource
          let search: TaxonSearch
          if capturedOperation == .codes {
            search = .codes(
              capturedCodes.split(separator: ",", omittingEmptySubsequences: false).map(
                String.init),
              kind: capturedKind, submission: capturedSubmission)
          } else if capturedOperation == .commonName {
            search = .commonName(capturedName, category: category, source: source)
          } else {
            search = .scientificName(capturedName, category: category, source: source)
          }
          if capturedProfile {
            let query =
              try capturedNextProfile
              ?? TaxonProfileQuery(paging: .page(size: size, startIndex: 0), search: search)
            let page = try await client.taxonProfilesResponse(query: query)
            followingProfile = try query.next(after: page)
            result = page.map(Self.profileRecord)
          } else {
            let query =
              try capturedNextSummary
              ?? TaxonSummaryQuery(paging: .page(size: size, startIndex: 0), search: search)
            let page = try await client.taxonSummariesResponse(query: query)
            followingSummary = try query.next(after: page)
            result = page.map(Self.summaryRecord)
          }
        case .lookup:
          if capturedProfile {
            result = [
              Self.profileRecord(
                try await client.taxonProfile(code: capturedCode, kind: capturedKind))
            ]
          } else {
            result = [
              Self.summaryRecord(
                try await client.taxonSummary(code: capturedCode, kind: capturedKind))
            ]
          }
        case .options:
          result = try await client.taxonomyOptions(kind: capturedOptionKind).map {
            "\($0.value)\n\($0.description)"
          }
        case .ranks:
          result = try await client.taxonomicRanks().map { "\($0.name) · \($0.code)" }
        case .sourceTree:
          let tree = try await client.taxonomicSourceTree(code: capturedSourceCode)
          result = [
            "\(tree.name) · \(tree.code)\n\(tree.categories.count) categories · \(tree.ranks.count) ranks"
          ]
        case .sources:
          if capturedProfile {
            result = try await client.taxonomicSourceProfiles().map {
              "\($0.fullName) · \($0.code)\n\($0.lifecycleState)"
            }
          } else {
            result = try await client.taxonomicSources().map { "\($0.name) · \($0.code)" }
          }
        }
        guard !Task.isCancelled else { return }
        rows += result
        nextProfile = followingProfile
        nextSummary = followingSummary
        status =
          result.isEmpty
          ? (continuing ? "No more records." : "No matching records.")
          : rows.count == 1 ? "1 record." : "\(rows.count) records."
      } catch {
        guard !Task.isCancelled else { return }
        nextProfile = nil
        nextSummary = nil
        if error is TaxonomyValidationError {
          status = "Enter a valid name, positive code, and page size."
        } else if case NPSTaxonomyError.invalidInput = error {
          status = "Enter a valid name, positive code, and page size."
        } else {
          status = "Unable to load records. Check the input and try again."
        }
      }
      requestTask = nil
    }
  }

  private static func profileRecord(_ row: NPSTaxonProfile) -> String {
    "\(row.scientificName) · \(row.taxonCode)\n\(row.rank) · \(row.lifecycleState)\nCommon names: \(row.commonNames?.joined(separator: ", ") ?? "Not reported")\nHierarchy: \(row.orderedHierarchy.map(\.scientificName).joined(separator: " → "))\nSource: \(row.classificationSource.name)"
  }

  private func reset() {
    cancel()
    rows = []
    nextProfile = nil
    nextSummary = nil
    status = "Choose an operation, then load records."
  }

  private static func summaryRecord(_ row: NPSTaxonSummary) -> String {
    "\(row.scientificName) · \(row.taxonCode)\n\(row.rank) · \(row.sourceName)\nCommon names: \(row.commonNames ?? "Not reported")\n\(row.kingdom) · \(row.family)"
  }
}
