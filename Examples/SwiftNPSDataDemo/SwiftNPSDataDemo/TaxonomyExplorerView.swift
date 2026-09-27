import SwiftNPSTaxonomy
import SwiftNPSTaxonomyModels
import SwiftUI

struct TaxonomyExplorerView: View {
  private enum Operation: String, CaseIterable {
    case categories = "Categories"
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
  @State private var kind = TaxonCodeKind.nps
  @State private var name = "hawk"
  @State private var operation = Operation.lookup
  @State private var optionKind = TaxonomyOptionKind.codeType
  @State private var pageSize = "10"
  @State private var profile = false
  @State private var requestTask: Task<Void, Never>?
  @State private var rows: [String] = []
  @State private var source = ""
  @State private var sourceCode = "ITIS"
  @State private var status = "Choose an operation, then load records."

  var body: some View {
    Form {
      Section("Request") {
        Picker("Operation", selection: $operation) {
          ForEach(Operation.allCases, id: \.self) { Text($0.rawValue).tag($0) }
        }
        if operation == .lookup {
          field("Taxon code", text: $code)
          Picker("Code namespace", selection: $kind) {
            Text("NPS taxon code").tag(TaxonCodeKind.nps)
            Text("ITIS TSN").tag(TaxonCodeKind.itis)
          }
        }
        if [.commonName, .scientificName].contains(operation) {
          field("Name", text: $name)
          field("Category (optional)", text: $category)
          field("Source (optional)", text: $source)
          field("Page size", text: $pageSize)
        }
        if [.commonName, .lookup, .scientificName, .sources].contains(operation) {
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
        Button("Load records", action: load).disabled(requestTask != nil)
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
    .onChange(of: [category, code, name, pageSize, source, sourceCode]) { reset() }
    .onChange(of: kind) { reset() }
    .onChange(of: operation) { reset() }
    .onChange(of: optionKind) { reset() }
    .onChange(of: profile) { reset() }
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

  private func load() {
    rows = []
    status = "Loading…"
    let capturedCategory = category
    let capturedCode = code
    let capturedKind = kind
    let capturedName = name
    let capturedOperation = operation
    let capturedOptionKind = optionKind
    let capturedPageSize = pageSize
    let capturedProfile = profile
    let capturedSource = source
    let capturedSourceCode = sourceCode
    requestTask = Task {
      guard !Task.isCancelled else { return }
      do {
        let client = NPSTaxonomyClient()
        let result: [String]
        switch capturedOperation {
        case .categories:
          result = try await client.taxonomicCategories().map { "\($0.name) · \($0.code)" }
        case .commonName, .scientificName:
          guard let size = Int(capturedPageSize) else {
            throw TaxonomyValidationError.invalidPageSize
          }
          let category = capturedCategory.isEmpty ? nil : capturedCategory
          let source = capturedSource.isEmpty ? nil : capturedSource
          let search: TaxonSearch =
            capturedOperation == .commonName
            ? .commonName(capturedName, category: category, source: source)
            : .scientificName(capturedName, category: category, source: source)
          if capturedProfile {
            result = try await client.taxonProfilesResponse(
              query: TaxonProfileQuery(paging: .page(size: size, startIndex: 0), search: search)
            ).map(Self.profileRecord)
          } else {
            result = try await client.taxonSummariesResponse(
              query: TaxonSummaryQuery(paging: .page(size: size, startIndex: 0), search: search)
            ).map(Self.summaryRecord)
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
        rows = result
        status = result.isEmpty ? "No matching records." : "\(result.count) records."
      } catch {
        guard !Task.isCancelled else { return }
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
    status = "Choose an operation, then load records."
  }

  private static func summaryRecord(_ row: NPSTaxonSummary) -> String {
    "\(row.scientificName) · \(row.taxonCode)\n\(row.rank) · \(row.sourceName)\nCommon names: \(row.commonNames ?? "Not reported")\n\(row.kingdom) · \(row.family)"
  }
}
