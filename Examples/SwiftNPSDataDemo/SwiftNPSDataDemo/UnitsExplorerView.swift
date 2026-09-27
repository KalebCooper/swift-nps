import SwiftNPSUnits
import SwiftNPSUnitsModels
import SwiftUI

struct UnitsExplorerView: View {
  private enum Operation: String, CaseIterable {
    case all = "All profiles"
    case collections = "Collections"
    case designation = "Designation"
    case designations = "Designations"
    case linked = "Linked units"
    case search = "Search profiles"
    case subtype = "Subtype"
    case subtypes = "Subtypes"
  }

  @State private var input = "ACAD"
  @State private var kind = UnitLinkKind.all
  @State private var operation = Operation.search
  @State private var requestTask: Task<Void, Never>?
  @State private var rows: [String] = []
  @State private var status = "Choose an operation, then load records."

  var body: some View {
    Form {
      Section("Request") {
        Picker("Operation", selection: $operation) {
          ForEach(Operation.allCases, id: \.self) { Text($0.rawValue).tag($0) }
        }
        if [.designation, .linked, .search, .subtype].contains(operation) {
          LabeledContent(operation == .search ? "Search term" : "Code") {
            TextField("Code or search", text: $input)
              .multilineTextAlignment(.trailing)
              .textInputAutocapitalization(.never)
              .autocorrectionDisabled()
          }
        }
        if operation == .linked {
          Picker("Link kind", selection: $kind) {
            ForEach(UnitLinkKind.allCases, id: \.self) { Text($0.rawValue).tag($0) }
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
          "Administrative records. Search by code or name; use semicolons for multiple terms. No Data API key is required."
        )
      }
    }
    .navigationTitle("Units")
    .onChange(of: input) { reset() }
    .onChange(of: kind) { reset() }
    .onChange(of: operation) { reset() }
    .onDisappear(perform: cancel)
  }

  private func cancel() {
    guard requestTask != nil else { return }
    requestTask?.cancel()
    requestTask = nil
    status = "Cancelled."
  }

  private func load() {
    rows = []
    status = "Loading…"
    let capturedInput = input
    let capturedKind = kind
    let capturedOperation = operation
    requestTask = Task {
      guard !Task.isCancelled else { return }
      do {
        let client = NPSUnitsClient()
        let result: [String]
        switch capturedOperation {
        case .all:
          result = try await client.units().map(Self.profile)
        case .collections:
          result = try await client.unitCollections().map {
            "\($0.code) · \($0.name)\n\($0.units.count) units"
          }
        case .designation:
          let value = try await client.unitDesignation(code: capturedInput)
          result = ["\(value.code) · \(value.name)"] + value.units.map { "\($0.code) · \($0.name)" }
        case .designations:
          result = try await client.unitDesignations().map {
            "\($0.code) · \($0.name)\n\($0.units.count) units"
          }
        case .linked:
          result = try await client.linkedUnits(unitCode: capturedInput, kind: capturedKind).map(
            Self.profile)
        case .search:
          result = try await client.units(matching: capturedInput).map(Self.profile)
        case .subtype:
          let value = try await client.unitSubtype(code: capturedInput)
          result = ["\(value.code) · \(value.name)"] + value.units.map { "\($0.code) · \($0.name)" }
        case .subtypes:
          result = try await client.unitSubtypes().map {
            "\($0.code) · \($0.name)\n\($0.units.count) units"
          }
        }
        guard !Task.isCancelled else { return }
        rows = result
        status = result.isEmpty ? "No matching records." : "\(result.count) records."
      } catch {
        guard !Task.isCancelled else { return }
        if case NPSUnitsError.invalidInput = error {
          status = "Enter a code or search term without path separators."
        } else {
          status = "Unable to load records. Check the code and try again."
        }
      }
      requestTask = nil
    }
  }

  private static func profile(_ unit: NPSUnit) -> String {
    "\(unit.unitCode) · \(unit.fullName)\n\(unit.unitLifecycle) · \(unit.stateCodes?.joined(separator: ", ") ?? "No states reported")\nNetwork: \(unit.network ?? "Not reported") · Region: \(unit.region ?? "Not reported")"
  }

  private func reset() {
    cancel()
    rows = []
    status = "Choose an operation, then load records."
  }
}
