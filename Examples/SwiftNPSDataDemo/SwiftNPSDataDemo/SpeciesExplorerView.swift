import SwiftNPSSpecies
import SwiftNPSSpeciesModels
import SwiftUI

struct SpeciesExplorerView: View {
  private enum ListKind: String, CaseIterable {
    case checklist = "Checklist"
    case details = "Details"
    case full = "Full list"
  }

  private struct Row {
    let code: String
    let commonNames: String?
    let name: String
    let status: String
  }

  @State private var categories = "birds"
  @State private var categoryOptions: [SpeciesCategoryOption] = []
  @State private var categorySelection = ""
  @State private var kind = ListKind.checklist
  @State private var requestTask: Task<Void, Never>?
  @State private var rows: [Row] = []
  @State private var status = "Choose a unit and list."
  @State private var unitCode = "ACAD"

  var body: some View {
    Form {
      Section("Request") {
        LabeledContent("Unit") {
          TextField("Unit code", text: $unitCode)
            .textInputAutocapitalization(.never).autocorrectionDisabled()
        }
        LabeledContent("Categories") {
          TextField("All if blank", text: $categories)
            .textInputAutocapitalization(.never).autocorrectionDisabled()
        }
        Picker("List", selection: $kind) {
          ForEach(ListKind.allCases, id: \.self) { Text($0.rawValue).tag($0) }
        }
        Button("Load list", action: load).disabled(requestTask != nil)
        if requestTask != nil { Button("Cancel", action: cancel) }
      }
      Section {
        Button("Load category options", action: loadCategoryOptions).disabled(requestTask != nil)
        if !categoryOptions.isEmpty {
          Picker("Provider aliases", selection: $categorySelection) {
            ForEach(Array(categoryOptions.enumerated()), id: \.offset) { _, option in
              Text(option.value).tag(option.value)
            }
          }
          if let option = categoryOptions.first(where: { $0.value == categorySelection }) {
            Text(option.description)
          }
        }
      } header: {
        Text("Category reference")
      } footer: {
        Text("Each value lists several aliases. Enter one name or number in Categories above.")
      }
      Section {
        Text(status)
        ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
          VStack(alignment: .leading) {
            Text(row.name).font(.headline)
            if let commonNames = row.commonNames { Text(commonNames) }
            Text("NPS taxon code: \(row.code)")
            if !row.status.isEmpty { Text(row.status).font(.caption) }
          }
        }
      } footer: {
        Text(
          "Published inventories, not current sightings. Checklist and full-list membership differ. Categories are comma-separated; leave blank for all."
        )
      }
    }
    .navigationTitle("Species")
    .onChange(of: [categories, unitCode, kind.rawValue]) { reset() }
    .onDisappear(perform: cancel)
  }

  private func cancel() {
    guard requestTask != nil else { return }
    requestTask?.cancel()
    requestTask = nil
    status = "Cancelled."
  }

  private func load() {
    let capturedCategories = categories
    let capturedKind = kind
    let capturedUnit = unitCode
    rows = []
    status = "Loading…"
    requestTask = Task {
      guard !Task.isCancelled else { return }
      do {
        let query = try SpeciesQuery(
          categories: capturedCategories.isEmpty
            ? nil
            : capturedCategories.split(separator: ",", omittingEmptySubsequences: false).map(
              String.init),
          unitCode: capturedUnit)
        let client = NPSSpeciesClient()
        let result: [Row]
        switch capturedKind {
        case .checklist:
          result = try await client.speciesChecklist(query: query).map {
            Row(
              code: $0.taxaCode, commonNames: $0.commonNames, name: $0.scientificName,
              status: $0.occurrence ?? "")
          }
        case .details:
          result = try await client.speciesDetails(query: query).map {
            Row(
              code: $0.taxaCode, commonNames: $0.commonNames, name: $0.scientificName,
              status: [$0.occurrence, $0.abundance, $0.nativeness, $0.npsTags].compactMap { $0 }
                .joined(separator: "; "))
          }
        case .full:
          result = try await client.species(query: query).map {
            Row(
              code: $0.taxaCode, commonNames: $0.commonNames, name: $0.scientificName,
              status: [$0.occurrence, $0.abundance, $0.nativeness].compactMap { $0 }.joined(
                separator: "; "))
          }
        }
        guard !Task.isCancelled else { return }
        rows = result
        status = result.isEmpty ? "No species returned." : "\(result.count) species."
      } catch {
        guard !Task.isCancelled else { return }
        status =
          error is SpeciesQuery.ValidationError
          ? "Enter a unit and comma-separated categories without leading or trailing spaces or path punctuation."
          : "Unable to load this list. Check the unit and category values, then try again."
      }
      requestTask = nil
    }
  }

  private func loadCategoryOptions() {
    rows = []
    status = "Loading categories…"
    requestTask = Task {
      guard !Task.isCancelled else { return }
      do {
        let options = try await NPSSpeciesClient().categoryOptions()
        guard !Task.isCancelled else { return }
        categoryOptions = options
        categorySelection = options.first?.value ?? ""
        status =
          options.isEmpty
          ? "No category options returned." : "\(options.count) category options loaded."
      } catch {
        guard !Task.isCancelled else { return }
        status = "Unable to load category options. Please try again."
      }
      requestTask = nil
    }
  }

  private func reset() {
    cancel()
    rows = []
    status = "Choose a unit and list."
  }
}
