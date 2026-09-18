import SwiftNPSData
import SwiftNPSDataModels
import SwiftUI

struct ContentView: View {
  @State private var apiKey = ""
  @State private var group = DemoGroup.parks
  @State private var isLoading = false
  @State private var loadTask: Task<Void, Never>?
  @State private var message = "Enter your private NPS API key to search."
  @State private var pageSize = 1
  @State private var pager: (any ResultPaging)?
  @State private var parkCodes = "acad,yell"
  @State private var rows: [ResultRow] = []
  @State private var searchText = ""
  @State private var stateCodes = ""

  var body: some View {
    NavigationStack {
      Form {
        Section("Search") {
          Picker("Group", selection: $group) {
            ForEach(DemoGroup.allCases) { group in
              Text(group.rawValue).tag(group)
            }
          }
          .pickerStyle(.menu)
          .onChange(of: group) { reset() }
          SecureField("NPS API key", text: $apiKey)
            .textContentType(.password)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
          if group.filtersByCode {
            TextField("Park codes, separated by commas", text: $parkCodes)
              .textInputAutocapitalization(.never)
              .autocorrectionDisabled()
            TextField("State codes, separated by commas", text: $stateCodes)
              .textInputAutocapitalization(.characters)
              .autocorrectionDisabled()
          }
          TextField("Search text", text: $searchText)
          Stepper("Results per page: \(pageSize)", value: $pageSize, in: 1...50)
          Button("Search \(group.noun)", action: search)
            .disabled(apiKey.isEmpty)
        }
        .disabled(isLoading)

        Section {
          if isLoading {
            ProgressView("Loading \(group.noun)")
            Button("Cancel") { loadTask?.cancel() }
          } else if pager != nil {
            Button("Load more", action: loadNextPage)
          }
          Text(message)
            .accessibilityIdentifier("lookupStatus")
        }

        // Offsets preserve repeated provider records when results change between pages.
        ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
          VStack(alignment: .leading) {
            Text(row.title)
            if let parkCode = row.parkCode {
              Text(parkCode)
                .font(.caption)
                .foregroundStyle(.secondary)
                .accessibilityLabel("Park code \(parkCode)")
            }
          }
        }

        Section {
          Text(sortDescription)
          Text("Load more fetches one page at a time.")
          Text(
            "Your key stays in memory and is sent only to the NPS API. It is not saved by this demo."
          )
          Text("NPS information can change between pages and is not live reservation availability.")
        }
        .font(.footnote)
      }
      .navigationTitle("NPS \(group.noun)")
      .onDisappear { loadTask?.cancel() }
    }
  }

  private var sortDescription: String {
    switch group {
    // NPS rejects things to do sort fields other than relevance with HTTP 400.
    case .alerts, .amenities, .thingsToDo:
      "Results are in the order NPS returns them."
    case .campgrounds, .visitorCenters:
      "Results are sorted by name."
    case .parks:
      "Results are sorted by full name."
    }
  }

  private func loadNextPage() {
    guard !isLoading, var current = pager else { return }
    isLoading = true
    pager = nil
    message = "Loading the next page."
    loadTask = Task {
      defer {
        isLoading = false
        loadTask = nil
      }
      do throws(NPSDataError) {
        guard let page = try await current.nextPage() else {
          message = "All reported results have been loaded."
          return
        }
        rows.append(contentsOf: page.rows)
        pager = page.hasMore ? current : nil
        message =
          rows.isEmpty
          ? "No \(group.noun) matched this search."
          : "Showing \(rows.count) of \(page.total) matching \(group.noun)."
        if !page.hasMore, !rows.isEmpty {
          message += " All reported results are loaded."
        }
      } catch {
        show(error)
      }
    }
  }

  private func makePager(client: NPSDataClient) throws -> any ResultPaging {
    let text = searchText.isEmpty ? nil : searchText
    switch group {
    case .alerts:
      let query = try AlertQuery(
        limit: pageSize, parkCodes: parsedParkCodes(), searchText: text,
        stateCodes: parsedStateCodes())
      return DemoPager(pages: client.alertPages(query: query), query: query) {
        ResultRow(parkCode: $0.parkCode, title: $0.title)
      }
    case .amenities:
      let query = try AmenityQuery(limit: pageSize, searchText: text)
      return DemoPager(pages: client.amenityPages(query: query), query: query) {
        ResultRow(parkCode: nil, title: $0.name)
      }
    case .campgrounds:
      let query = try CampgroundQuery(
        limit: pageSize, parkCodes: parsedParkCodes(), searchText: text, sort: [.ascending("name")],
        stateCodes: parsedStateCodes())
      return DemoPager(pages: client.campgroundPages(query: query), query: query) {
        ResultRow(parkCode: $0.parkCode, title: $0.name)
      }
    case .parks:
      let query = try ParkQuery(
        limit: pageSize, parkCodes: parsedParkCodes(), searchText: text,
        sort: [.ascending("fullName")],
        stateCodes: parsedStateCodes())
      return DemoPager(pages: client.parkPages(query: query), query: query) {
        ResultRow(parkCode: $0.parkCode, title: $0.fullName)
      }
    case .thingsToDo:
      let query = try ThingToDoQuery(
        limit: pageSize, parkCodes: parsedParkCodes(), searchText: text,
        stateCodes: parsedStateCodes())
      return DemoPager(pages: client.thingToDoPages(query: query), query: query) { thing in
        // A thing to do can belong to several parks, so it lists every related park code.
        let codes = (thing.relatedParks ?? []).compactMap(\.parkCode)
        return ResultRow(
          parkCode: codes.isEmpty ? nil : codes.joined(separator: ", "), title: thing.title)
      }
    case .visitorCenters:
      let query = try VisitorCenterQuery(
        limit: pageSize, parkCodes: parsedParkCodes(), searchText: text, sort: [.ascending("name")],
        stateCodes: parsedStateCodes())
      return DemoPager(pages: client.visitorCenterPages(query: query), query: query) {
        ResultRow(parkCode: $0.parkCode, title: $0.name)
      }
    }
  }

  private func parsedParkCodes() throws -> [ParkCode] {
    parkCodes.isEmpty
      ? []
      : try parkCodes.split(separator: ",", omittingEmptySubsequences: false).map {
        try ParkCode(String($0))
      }
  }

  private func parsedStateCodes() throws -> [StateCode] {
    stateCodes.isEmpty
      ? []
      : try stateCodes.split(separator: ",", omittingEmptySubsequences: false).map {
        try StateCode(String($0))
      }
  }

  // The picker is disabled while loading, so switching groups never races an in-flight page.
  private func reset() {
    pager = nil
    rows = []
    message = "Enter your private NPS API key to search."
  }

  private func search() {
    guard !isLoading else { return }
    pager = nil
    rows = []
    do {
      let client = try NPSDataClient(apiKey: apiKey)
      pager = try makePager(client: client)
      loadNextPage()
    } catch let error as NPSDataError {
      show(error)
    } catch {
      message =
        "Use comma-separated park codes of 4 to 10 letters or digits and two-letter state codes, without spaces."
    }
  }

  private func show(_ error: NPSDataError) {
    switch error {
    case .invalidAPIKey:
      message = "Enter an API key without spaces or line breaks."
    case .pagination:
      message = "NPS returned inconsistent page information. Search again to restart."
    case .service(_, let response):
      message =
        response.statusCode == 429
        ? "NPS has limited requests for this key. Try again later."
        : "NPS refused the request (HTTP \(response.statusCode ?? 0)). Check your API key."
    case .transport(.cancelled):
      message = "Search cancelled."
    case .transport:
      message = "\(group.rawValue) could not be loaded. Check your connection and search again."
    }
    if !rows.isEmpty {
      message += " Earlier results remain visible and may be incomplete."
    }
  }
}

#Preview {
  ContentView()
}
