import SwiftNPSLandmarks
import SwiftNPSLandmarksModels
import SwiftUI

struct LandmarksExplorerView: View {
  private enum Operation: String, CaseIterable {
    case county = "County relationship"
    case countyLandmarks = "Landmarks by county"
    case search = "Landmark search"
    case state = "State"
    case stateLandmarks = "Landmarks by state"
    case states = "States"
  }

  @State private var code = "APBO-ME"
  @State private var countyID = "4347"
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
        if operation == .search {
          LabeledContent("Landmark code") {
            TextField("Landmark code", text: $code).multilineTextAlignment(.trailing)
              .textInputAutocapitalization(.never).autocorrectionDisabled()
          }
        }
        if [.county, .state, .stateLandmarks].contains(operation) {
          LabeledContent("State code") {
            TextField("State code", text: $stateCode).multilineTextAlignment(.trailing)
          }
        }
        if operation == .countyLandmarks {
          LabeledContent("County ID") {
            TextField("County ID", text: $countyID).multilineTextAlignment(.trailing)
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
          "Landmark designation does not imply NPS ownership or public access. Confirm access with the owner before visiting. No Data API key is required."
        )
      }
    }
    .navigationTitle("Landmarks")
    .onChange(of: [code, countyID, stateCode]) { reset() }
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
    let capturedCode = code
    let capturedCounty = countyID
    let capturedOperation = operation
    let capturedState = stateCode
    requestTask = Task {
      guard !Task.isCancelled else { return }
      do {
        let client = NPSLandmarksClient()
        let result: [String]
        switch capturedOperation {
        case .county:
          let row = try await client.landmarkCounty(query: LandmarkQuery(stateCode: capturedState))
          result = [
            "\(row.label) · \(row.stateCode)\nCounty ID: \(row.countyID) · Landmark ID: \(row.id) · \(row.code)"
          ]
        case .countyLandmarks:
          guard let id = Int64(capturedCounty), id > 0 else {
            throw NPSLandmarksError.invalidInput
          }
          result = try await client.landmarks(countyID: id).map {
            "\($0.title) · \($0.code)\nCounty ID: \($0.countyID) · \($0.countyLabel ?? "Not reported")\n\($0.areaAcres) acres"
          }
        case .search:
          result = try await client.landmarks(query: LandmarkQuery(code: capturedCode)).map(
            Self.record)
        case .state:
          let row = try await client.landmarkState(stateCode: capturedState)
          result = ["\(row.stateCode) · \(row.label)"]
        case .stateLandmarks:
          result = try await client.landmarks(stateCode: capturedState).map(Self.record)
        case .states:
          result = try await client.landmarkStates().map { "\($0.stateCode) · \($0.label)" }
        }
        guard !Task.isCancelled else { return }
        rows = result
        status =
          result.isEmpty
          ? "No matching records." : result.count == 1 ? "1 record." : "\(result.count) records."
      } catch {
        guard !Task.isCancelled else { return }
        if error is LandmarkQuery.ValidationError {
          status = "Enter a nonempty code and positive numeric IDs."
        } else if case NPSLandmarksError.invalidInput = error {
          status = "Enter a nonempty code and positive numeric IDs."
        } else {
          status = "Unable to load records. Check the code and try again."
        }
      }
      requestTask = nil
    }
  }

  private static func record(_ row: NPSLandmark) -> String {
    "\(row.title) · \(row.code)\nID: \(row.id) · \(row.areaAcres) acres · Designated \(row.designationYear)\n\(row.primaryState) · Secondary state: \(row.secondaryState ?? "Not reported")\n\(row.significanceStatement)\nURL: \(row.authoritativeURL ?? "Not reported")"
  }

  private func reset() {
    cancel()
    rows = []
    status = "Choose an operation, then load records."
  }
}
