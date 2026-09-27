import SwiftNPSVisitation
import SwiftNPSVisitationModels
import SwiftUI

struct VisitationExplorerView: View {
  @State private var endMonth = "2"
  @State private var endYear = "2025"
  @State private var national = false
  @State private var requestTask: Task<Void, Never>?
  @State private var rows: [NPSVisitationRecord] = []
  @State private var startMonth = "1"
  @State private var startYear = "2025"
  @State private var status = "Choose units and months, then load records."
  @State private var unitCodes = "ACAD"

  var body: some View {
    Form {
      Section("Request") {
        Toggle("National monthly totals", isOn: $national)
        if national {
          LabeledContent("Year") {
            TextField("Year", text: $endYear)
              .multilineTextAlignment(.trailing)
          }
        } else {
          TextField("Unit codes, separated by commas", text: $unitCodes)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
          LabeledContent("Start year") {
            TextField("Start year", text: $startYear)
              .multilineTextAlignment(.trailing)
          }
          LabeledContent("Start month") {
            TextField("Start month", text: $startMonth)
              .multilineTextAlignment(.trailing)
          }
          LabeledContent("End year") {
            TextField("End year", text: $endYear)
              .multilineTextAlignment(.trailing)
          }
          LabeledContent("End month") {
            TextField("End month", text: $endMonth)
              .multilineTextAlignment(.trailing)
          }
        }
        Button("Load records", action: load).disabled(requestTask != nil)
        if requestTask != nil { Button("Cancel", action: cancel) }
      }
      Section {
        Text(status)
        ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
          VStack(alignment: .leading) {
            Text("\(row.unitName ?? "National") · \(String(row.year))/\(row.month)")
            Text("Recreation: \(row.recreationVisitors)")
            Text("Nonrecreation: \(row.nonRecreationVisitors)")
          }
        }
      } footer: {
        Text(
          "Historical monthly records. Missing months are not zero visits; no annual total is calculated."
        )
      }
    }
    .navigationTitle("Visitation")
    .onChange(of: [endMonth, endYear, startMonth, startYear, unitCodes]) { cancel() }
    .onChange(of: national) { cancel() }
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
    let capturedEndMonth = endMonth
    let capturedEndYear = endYear
    let capturedNational = national
    let capturedStartMonth = startMonth
    let capturedStartYear = startYear
    let capturedUnits = unitCodes
    requestTask = Task {
      guard !Task.isCancelled else { return }
      do {
        let client = NPSVisitationClient()
        guard let lastYear = Int(capturedEndYear) else {
          status = "Enter a whole-number year."
          requestTask = nil
          return
        }
        let result: [NPSVisitationRecord]
        if capturedNational {
          result = try await client.nationalVisitation(year: lastYear)
        } else {
          guard let firstYear = Int(capturedStartYear), let firstMonth = Int(capturedStartMonth),
            let lastMonth = Int(capturedEndMonth)
          else {
            status = "Enter whole-number years and months."
            requestTask = nil
            return
          }
          let query = try VisitationQuery(
            end: .init(year: lastYear, month: lastMonth),
            start: .init(year: firstYear, month: firstMonth),
            unitCodes: capturedUnits.split(separator: ",", omittingEmptySubsequences: false).map(
              String.init))
          result = try await client.visitation(query: query)
        }
        guard !Task.isCancelled else { return }
        rows = result
        status = result.isEmpty ? "No reported months." : "\(result.count) monthly records."
      } catch {
        guard !Task.isCancelled else { return }
        if error is VisitationMonth.ValidationError {
          status = "Use a positive year and a month from 1 through 12."
        } else if error is VisitationQuery.ValidationError {
          status = "Enter unit codes without spaces and an end month on or after the start month."
        } else if case NPSVisitationError.invalidYear = error {
          status = "Use a positive year."
        } else {
          status = "Unable to load records. Please try again."
        }
      }
      requestTask = nil
    }
  }
}
