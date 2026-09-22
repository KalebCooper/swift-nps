import SwiftNPSData
import SwiftNPSDataModels
import SwiftUI

struct ContentView: View {
  @State private var apiKey = ""
  @State private var galleryIdentifiers = ""
  @State private var group = DemoGroup.parks
  @State private var isLoading = false
  @State private var loadTask: Task<Void, Never>?
  @State private var message = "Enter your private NPS API key to search."
  @State private var pageSize = 1
  @State private var pager: (any ResultPaging)?
  @State private var parkCode = "yell"
  @State private var parkCodes = "acad,yell"
  @State private var roadEventType: RoadEventType?
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
          switch group.filters {
          case .codeListsAndText:
            TextField("Park codes, separated by commas", text: $parkCodes)
              .textInputAutocapitalization(.never)
              .autocorrectionDisabled()
            TextField("State codes, separated by commas", text: $stateCodes)
              .textInputAutocapitalization(.characters)
              .autocorrectionDisabled()
          case .codeListsTextAndGalleries:
            TextField("Gallery IDs, separated by commas", text: $galleryIdentifiers)
              .textInputAutocapitalization(.characters)
              .autocorrectionDisabled()
            TextField("Park codes, separated by commas", text: $parkCodes)
              .textInputAutocapitalization(.never)
              .autocorrectionDisabled()
            TextField("State codes, separated by commas", text: $stateCodes)
              .textInputAutocapitalization(.characters)
              .autocorrectionDisabled()
          case .optionalParkCodeAndType:
            TextField("Park code, or empty for every park", text: $parkCode)
              .textInputAutocapitalization(.never)
              .autocorrectionDisabled()
            Picker("Event type", selection: $roadEventType) {
              Text("Any").tag(RoadEventType?.none)
              ForEach(RoadEventType.allCases, id: \.self) { type in
                Text(type.rawValue).tag(RoadEventType?.some(type))
              }
            }
            .pickerStyle(.menu)
          case .requiredParkCode:
            TextField("Park code", text: $parkCode)
              .textInputAutocapitalization(.never)
              .autocorrectionDisabled()
          case .textOnly:
            EmptyView()
          }
          if group.filters.isPaged {
            TextField("Search text", text: $searchText)
            Stepper("Results per page: \(pageSize)", value: $pageSize, in: 1...50)
          }
          Button("Search \(group.noun)", action: search)
            .disabled(isSearchDisabled)
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
            if let detail = row.detail, let label = group.detailLabel {
              Text(detail)
                .font(.caption)
                .foregroundStyle(.secondary)
                .accessibilityLabel("\(label) \(detail)")
            }
          }
        }

        Section {
          Text(orderDescription)
          if group.filters.isPaged {
            Text("Load more fetches one page at a time.")
          }
          Text(
            "Your key stays in memory and is sent only to the NPS API. It is not saved by this demo."
          )
          Text(
            "NPS information can change between requests and is not live reservation availability.")
        }
        .font(.footnote)
      }
      .navigationTitle("NPS \(group.noun)")
      .onDisappear { loadTask?.cancel() }
    }
  }

  private var isSearchDisabled: Bool {
    apiKey.isEmpty || (group.filters == .requiredParkCode && parkCode.isEmpty)
  }

  private var orderDescription: String {
    switch group {
    // NPS answers every sort value with HTTP 400 on articles, people, places, and webcams, and every
    // field except relevance on things to do and tours, so the demo sends no sort criteria for them.
    case .alerts, .amenities, .articles, .people, .places, .thingsToDo, .tours, .webcams:
      "Results are in the order NPS returns them."
    case .campgrounds, .visitorCenters:
      "Results are sorted by name."
    case .newsReleases:
      "Results are sorted by release date, newest first."
    case .parkBoundaries:
      "A park's boundary arrives as one feature collection with no pagination."
    case .parkAudio, .parkVideos, .photoGalleries, .photoGalleryAssets:
      "Results are sorted by title."
    case .parks:
      "Results are sorted by full name."
    case .roadEvents:
      "The road events feed arrives as one response with no pagination."
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

  private func loadSingleResponse(_ load: @escaping () async throws(NPSDataError) -> [ResultRow]) {
    isLoading = true
    message = "Loading \(group.noun)."
    loadTask = Task {
      defer {
        isLoading = false
        loadTask = nil
      }
      do throws(NPSDataError) {
        rows = try await load()
        if rows.isEmpty {
          message = "NPS returned no \(group.noun)."
        } else {
          message =
            rows.count == 1
            ? "NPS returned one result." : "NPS returned \(rows.count) results."
        }
      } catch {
        show(error)
      }
    }
  }

  private func makeLoad(client: NPSDataClient) throws -> DemoLoad {
    let text = searchText.isEmpty ? nil : searchText
    switch group {
    case .alerts:
      let query = try AlertQuery(
        limit: pageSize, parkCodes: parsedParkCodes(), searchText: text,
        stateCodes: parsedStateCodes())
      return .pages(
        DemoPager(pages: client.alertPages(query: query), query: query) {
          ResultRow(detail: $0.parkCode, title: $0.title)
        })
    case .amenities:
      let query = try AmenityQuery(limit: pageSize, searchText: text)
      return .pages(
        DemoPager(pages: client.amenityPages(query: query), query: query) {
          ResultRow(detail: nil, title: $0.name)
        })
    case .articles:
      let query = try ArticleQuery(
        limit: pageSize, parkCodes: parsedParkCodes(), searchText: text,
        stateCodes: parsedStateCodes())
      return .pages(
        DemoPager(pages: client.articlePages(query: query), query: query) { article in
          ResultRow(detail: relatedParkCodes(article.relatedParks), title: article.title)
        })
    case .campgrounds:
      let query = try CampgroundQuery(
        limit: pageSize, parkCodes: parsedParkCodes(), searchText: text, sort: [.ascending("name")],
        stateCodes: parsedStateCodes())
      return .pages(
        DemoPager(pages: client.campgroundPages(query: query), query: query) {
          ResultRow(detail: $0.parkCode, title: $0.name)
        })
    case .newsReleases:
      let query = try NewsReleaseQuery(
        limit: pageSize, parkCodes: parsedParkCodes(), searchText: text,
        sort: [.descending("releaseDate")], stateCodes: parsedStateCodes())
      return .pages(
        DemoPager(pages: client.newsReleasePages(query: query), query: query) {
          ResultRow(detail: $0.releaseDate, title: $0.title)
        })
    case .parkAudio:
      let query = try ParkAudioQuery(
        limit: pageSize, parkCodes: parsedParkCodes(), searchText: text,
        sort: [.ascending("title")], stateCodes: parsedStateCodes())
      return .pages(
        DemoPager(pages: client.parkAudioPages(query: query), query: query) { audio in
          ResultRow(detail: relatedParkCodes(audio.relatedParks), title: audio.title)
        })
    case .parkBoundaries:
      let code = try ParkCode(parkCode)
      // A multi statement closure does not infer a typed thrown error, so it is spelled out.
      return .single { () async throws(NPSDataError) -> [ResultRow] in
        let boundary = try await client.parkBoundary(parkCode: code)
        return (boundary.features ?? []).map { feature in
          let details = feature.properties
          return ResultRow(
            detail: feature.geometry?.type,
            title: details?.fullName ?? details?.name ?? "Park boundary")
        }
      }
    case .parks:
      let query = try ParkQuery(
        limit: pageSize, parkCodes: parsedParkCodes(), searchText: text,
        sort: [.ascending("fullName")],
        stateCodes: parsedStateCodes())
      return .pages(
        DemoPager(pages: client.parkPages(query: query), query: query) {
          ResultRow(detail: $0.parkCode, title: $0.fullName)
        })
    case .parkVideos:
      let query = try ParkVideoQuery(
        limit: pageSize, parkCodes: parsedParkCodes(), searchText: text,
        sort: [.ascending("title")], stateCodes: parsedStateCodes())
      return .pages(
        DemoPager(pages: client.parkVideoPages(query: query), query: query) { video in
          ResultRow(detail: relatedParkCodes(video.relatedParks), title: video.title)
        })
    case .people:
      let query = try PersonQuery(
        limit: pageSize, parkCodes: parsedParkCodes(), searchText: text,
        stateCodes: parsedStateCodes())
      return .pages(
        DemoPager(pages: client.personPages(query: query), query: query) { person in
          ResultRow(detail: relatedParkCodes(person.relatedParks), title: person.title)
        })
    case .photoGalleries:
      let query = try PhotoGalleryQuery(
        limit: pageSize, parkCodes: parsedParkCodes(), searchText: text,
        sort: [.ascending("title")], stateCodes: parsedStateCodes())
      return .pages(
        DemoPager(pages: client.photoGalleryPages(query: query), query: query) { gallery in
          ResultRow(detail: relatedParkCodes(gallery.relatedParks), title: gallery.title)
        })
    case .photoGalleryAssets:
      let query = try PhotoGalleryAssetQuery(
        galleryIdentifiers: parsedGalleryIdentifiers(), limit: pageSize,
        parkCodes: parsedParkCodes(), searchText: text, sort: [.ascending("title")],
        stateCodes: parsedStateCodes())
      return .pages(
        DemoPager(pages: client.photoGalleryAssetPages(query: query), query: query) { asset in
          ResultRow(detail: relatedParkCodes(asset.relatedParks), title: asset.title)
        })
    case .places:
      let query = try PlaceQuery(
        limit: pageSize, parkCodes: parsedParkCodes(), searchText: text,
        stateCodes: parsedStateCodes())
      return .pages(
        DemoPager(pages: client.placePages(query: query), query: query) { place in
          ResultRow(detail: relatedParkCodes(place.relatedParks), title: place.title)
        })
    case .roadEvents:
      // An empty park code asks for every park's events, which the feed returns in one response.
      let code = parkCode.isEmpty ? nil : try ParkCode(parkCode)
      let type = roadEventType
      // A multi statement closure does not infer a typed thrown error, so it is spelled out.
      return .single { () async throws(NPSDataError) -> [ResultRow] in
        let feed = try await client.roadEvents(parkCode: code, type: type)
        return (feed.features ?? []).map { feature in
          let details = feature.properties?.coreDetails
          return ResultRow(detail: details?.eventType, title: details?.name ?? "Road event")
        }
      }
    case .thingsToDo:
      let query = try ThingToDoQuery(
        limit: pageSize, parkCodes: parsedParkCodes(), searchText: text,
        stateCodes: parsedStateCodes())
      return .pages(
        DemoPager(pages: client.thingToDoPages(query: query), query: query) { thing in
          ResultRow(detail: relatedParkCodes(thing.relatedParks), title: thing.title)
        })
    case .tours:
      let query = try TourQuery(
        limit: pageSize, parkCodes: parsedParkCodes(), searchText: text,
        stateCodes: parsedStateCodes())
      return .pages(
        DemoPager(pages: client.tourPages(query: query), query: query) { tour in
          // A tour links one park, not the array other groups send.
          ResultRow(detail: tour.park?.parkCode, title: tour.title)
        })
    case .visitorCenters:
      let query = try VisitorCenterQuery(
        limit: pageSize, parkCodes: parsedParkCodes(), searchText: text, sort: [.ascending("name")],
        stateCodes: parsedStateCodes())
      return .pages(
        DemoPager(pages: client.visitorCenterPages(query: query), query: query) {
          ResultRow(detail: $0.parkCode, title: $0.name)
        })
    case .webcams:
      let query = try WebcamQuery(
        limit: pageSize, parkCodes: parsedParkCodes(), searchText: text,
        stateCodes: parsedStateCodes())
      return .pages(
        DemoPager(pages: client.webcamPages(query: query), query: query) { webcam in
          ResultRow(detail: relatedParkCodes(webcam.relatedParks), title: webcam.title)
        })
    }
  }

  private func parsedGalleryIdentifiers() throws -> [NPSIdentifier] {
    galleryIdentifiers.isEmpty
      ? []
      : try galleryIdentifiers.split(separator: ",", omittingEmptySubsequences: false).map {
        try NPSIdentifier(String($0))
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

  /// The park codes an item lists, joined for one line, or nil when it names no park.
  private func relatedParkCodes(_ parks: [NPSRelatedPark]?) -> String? {
    let codes = (parks ?? []).compactMap(\.parkCode)
    return codes.isEmpty ? nil : codes.joined(separator: ", ")
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
      switch try makeLoad(client: client) {
      case .pages(let loaded):
        pager = loaded
        loadNextPage()
      case .single(let load):
        loadSingleResponse(load)
      }
    } catch let error as NPSDataError {
      show(error)
    } catch {
      message =
        group.filters == .codeListsTextAndGalleries
        ? "Use comma-separated gallery IDs, park codes of 4 to 10 letters or digits, and two-letter state codes, without spaces."
        : group.filters.isPaged
          ? "Use comma-separated park codes of 4 to 10 letters or digits and two-letter state codes, without spaces."
          : "Use one park code of 4 to 10 letters or digits, without spaces."
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
