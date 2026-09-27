import SwiftNPSUnits
import SwiftNPSUnitsModels
import SwiftUI

struct UnitsExplorerView: View {
  private enum Operation: String, CaseIterable {
    case all = "All profiles"
    case collections = "Collections"
    case county = "County"
    case designation = "Designation"
    case designations = "Designations"
    case geography = "Geography"
    case linked = "Linked units"
    case points = "Points"
    case search = "Search profiles"
    case selector = "Selector"
    case state = "State"
    case states = "States"
    case subtype = "Subtype"
    case subtypes = "Subtypes"
  }

  @State private var county = "Hancock County"
  @State private var dataFormat = ""
  @State private var detail = ""
  @State private var input = "ACAD"
  @State private var kind = UnitLinkKind.all
  @State private var operation = Operation.search
  @State private var requestTask: Task<Void, Never>?
  @State private var rows: [String] = []
  @State private var stateCode = "ME"
  @State private var status = "Choose an operation, then load records."

  var body: some View {
    Form {
      Section("Request") {
        Picker("Operation", selection: $operation) {
          ForEach(Operation.allCases, id: \.self) { Text($0.rawValue).tag($0) }
        }
        if [.designation, .geography, .linked, .search, .subtype].contains(operation) {
          LabeledContent(operation == .search ? "Search term" : "Code") {
            TextField("Code or search", text: $input)
              .multilineTextAlignment(.trailing)
              .textInputAutocapitalization(.never)
              .autocorrectionDisabled()
          }
        }
        if [.county, .state].contains(operation) {
          LabeledContent("State code") {
            TextField("State code", text: $stateCode).multilineTextAlignment(.trailing)
          }
        }
        if operation == .county {
          LabeledContent("County") {
            TextField("County", text: $county).multilineTextAlignment(.trailing)
              .accessibilityLabel("County name, ID or FIPS")
          }
        }
        if operation == .geography {
          LabeledContent("Detail (optional)") {
            TextField("envelope, convexhull, feature", text: $detail)
              .multilineTextAlignment(.trailing).textInputAutocapitalization(.never)
          }
          LabeledContent("Format (optional)") {
            TextField("wkt or gml", text: $dataFormat)
              .multilineTextAlignment(.trailing).textInputAutocapitalization(.never)
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
    .onChange(of: [county, dataFormat, detail, input, stateCode]) { reset() }
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
    let capturedCounty = county
    let capturedDataFormat = dataFormat
    let capturedDetail = detail
    let capturedInput = input
    let capturedKind = kind
    let capturedOperation = operation
    let capturedState = stateCode
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
        case .county:
          let value = try await client.unitCounty(state: capturedState, county: capturedCounty)
          result = [
            "\(value.name) · FIPS \(value.fips)\n\((value.unitCodes ?? []).joined(separator: ", "))"
          ]
        case .designation:
          let value = try await client.unitDesignation(code: capturedInput)
          result = ["\(value.code) · \(value.name)"] + value.units.map { "\($0.code) · \($0.name)" }
        case .designations:
          result = try await client.unitDesignations().map {
            "\($0.code) · \($0.name)\n\($0.units.count) units"
          }
        case .geography:
          let query = try UnitGeographyQuery(
            dataFormat: capturedDataFormat.isEmpty ? nil : capturedDataFormat,
            detail: capturedDetail.isEmpty ? nil : capturedDetail, searchTerm: capturedInput)
          result = try await client.unitGeographies(query: query).map {
            "\($0.code)\n\($0.geography ?? "No geography reported")"
          }
        case .linked:
          result = try await client.linkedUnits(unitCode: capturedInput, kind: capturedKind).map(
            Self.profile)
        case .points:
          result = try await client.unitPoints().map {
            "\($0.code) · Latitude: \($0.latitude.map(String.init(describing:)) ?? "Not reported") · Longitude: \($0.longitude.map(String.init(describing:)) ?? "Not reported")"
          }
        case .search:
          result = try await client.units(matching: capturedInput).map(Self.profile)
        case .selector:
          result = try await client.unitSelector().map { node in
            let direct = (node.directLinks ?? []).map(\.code).joined(separator: ", ")
            let indirect = (node.indirectLinks ?? []).map(\.code).joined(separator: ", ")
            let inactive = (node.directInactives ?? []).map(\.code).joined(separator: ", ")
            let indirectInactive = (node.indirectInactives ?? []).map(\.code).joined(
              separator: ", ")
            return
              "\(node.unit.code) · \(node.unit.fullName ?? node.unit.typeName)\nLifecycle: \(node.unit.lifecycle)\nDirect: \(direct)\nIndirect: \(indirect)\nInactive direct: \(inactive)\nInactive indirect: \(indirectInactive)"
          }
        case .state:
          let value = try await client.unitState(code: capturedState)
          result =
            ["\(value.code) · \(value.name) · FIPS \(value.fipsCode)"]
            + (value.counties ?? []).map {
              "\($0.name) · FIPS \($0.fips)\n\(($0.unitCodes ?? []).joined(separator: ", "))"
            }
        case .states:
          result = try await client.unitStates().map {
            "\($0.code) · \($0.name) · FIPS \($0.fipsCode)\n\(($0.counties ?? []).count) counties"
          }
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
        if error is UnitGeographyQuery.ValidationError {
          status =
            "Use a valid search term, detail envelope/convexhull/feature, and format wkt/gml."
        } else if case NPSUnitsError.invalidInput = error {
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
