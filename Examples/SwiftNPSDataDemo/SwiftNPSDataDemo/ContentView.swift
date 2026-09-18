import SwiftNPSData
import SwiftNPSDataModels
import SwiftUI

struct ContentView: View {
  @State private var apiKey = ""
  @State private var isLoading = false
  @State private var loadTask: Task<Void, Never>?
  @State private var message = "Enter your private NPS API key to search parks."
  @State private var nextQuery: ParkQuery?
  @State private var pageIterator: NPSPageSequence<Park>.Iterator?
  @State private var pageSize = 1
  @State private var parkCodes = "acad,yell"
  @State private var parks: [Park] = []
  @State private var searchText = ""
  @State private var stateCodes = ""

  var body: some View {
    NavigationStack {
      Form {
        Section("Search") {
          SecureField("NPS API key", text: $apiKey)
            .textContentType(.password)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
          TextField("Park codes, separated by commas", text: $parkCodes)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
          TextField("State codes, separated by commas", text: $stateCodes)
            .textInputAutocapitalization(.characters)
            .autocorrectionDisabled()
          TextField("Search text", text: $searchText)
          Stepper("Parks per page: \(pageSize)", value: $pageSize, in: 1...50)
          Button("Search parks", action: search)
            .disabled(apiKey.isEmpty)
        }
        .disabled(isLoading)

        Section {
          if isLoading {
            ProgressView("Loading parks")
            Button("Cancel") { loadTask?.cancel() }
          } else if pageIterator != nil {
            Button("Load more", action: loadNextPage)
          }
          Text(message)
            .accessibilityIdentifier("lookupStatus")
        }

        // Offsets preserve repeated provider records when results change between pages.
        ForEach(Array(parks.enumerated()), id: \.offset) { _, park in
          Section(park.fullName) {
            LabeledContent("Park code", value: park.parkCode)
            if let states = park.states {
              LabeledContent("States", value: states)
            }
            if let description = park.description {
              Text(description)
            }
          }
        }

        Section {
          Text("Results are sorted by full name. Load more fetches one page at a time.")
          Text(
            "Your key stays in memory and is sent only to the NPS API. It is not saved by this demo."
          )
          Text("NPS information can change between pages and is not live reservation availability.")
        }
        .font(.footnote)
      }
      .navigationTitle("NPS parks")
      .onDisappear { loadTask?.cancel() }
    }
  }

  private func loadNextPage() {
    guard !isLoading, var iterator = pageIterator, let query = nextQuery else { return }
    isLoading = true
    nextQuery = nil
    pageIterator = nil
    message = "Loading the next page."
    loadTask = Task {
      defer {
        isLoading = false
        loadTask = nil
      }
      do throws(NPSDataError) {
        guard let page = try await iterator.next() else {
          message = "All reported results have been loaded."
          return
        }
        guard !Task.isCancelled else { throw .transport(.cancelled) }
        let following: ParkQuery?
        do throws(NPSPaginationError) {
          following = try query.next(after: page)
        } catch {
          throw .pagination(error)
        }
        parks.append(contentsOf: page.data)
        nextQuery = following
        pageIterator = following == nil ? nil : iterator
        message =
          parks.isEmpty
          ? "No parks matched this search."
          : "Showing \(parks.count) of \(page.total) matching parks."
        if following == nil, !parks.isEmpty {
          message += " All reported results are loaded."
        }
      } catch {
        show(error)
      }
    }
  }

  private func search() {
    guard !isLoading else { return }
    nextQuery = nil
    pageIterator = nil
    parks = []
    do {
      let codes =
        parkCodes.isEmpty
        ? []
        : try parkCodes.split(separator: ",", omittingEmptySubsequences: false).map {
          try ParkCode(String($0))
        }
      let states =
        stateCodes.isEmpty
        ? []
        : try stateCodes.split(separator: ",", omittingEmptySubsequences: false).map {
          try StateCode(String($0))
        }
      let query = try ParkQuery(
        limit: pageSize, parkCodes: codes, searchText: searchText.isEmpty ? nil : searchText,
        sort: [.ascending("fullName")], stateCodes: states)
      let client = try NPSDataClient(apiKey: apiKey)
      nextQuery = query
      pageIterator = client.parkPages(query: query).makeAsyncIterator()
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
      message = "Parks could not be loaded. Check your connection and search again."
    }
    if !parks.isEmpty {
      message += " Earlier results remain visible and may be incomplete."
    }
  }
}

#Preview {
  ContentView()
}
