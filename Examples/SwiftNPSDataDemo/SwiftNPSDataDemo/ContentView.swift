import SwiftNPSData
import SwiftNPSDataModels
import SwiftUI

struct ContentView: View {
  @State private var apiKey = ""
  @State private var isLoading = false
  @State private var lookupTask: Task<Void, Never>?
  @State private var message = "Enter your private NPS API key and a park code."
  @State private var parkCode = "acad"
  @State private var parks: [Park] = []

  var body: some View {
    NavigationStack {
      Form {
        Section("Lookup") {
          SecureField("NPS API key", text: $apiKey)
            .textContentType(.password)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
          TextField("Park code", text: $parkCode)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
          Button("Look up park") {
            lookupTask = Task { await lookUpPark() }
          }
          .disabled(apiKey.isEmpty || parkCode.isEmpty || isLoading)
        }
        .disabled(isLoading)

        Section {
          if isLoading {
            ProgressView("Loading park")
          }
          Text(message)
            .accessibilityIdentifier("lookupStatus")
        }

        ForEach(parks, id: \.id) { park in
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
          Text(
            "Your key stays in memory and is sent only to the NPS API. It is not saved by this demo."
          )
          .font(.footnote)
          Text("NPS information is not live reservation availability.")
            .font(.footnote)
        }
      }
      .navigationTitle("NPS parks")
      .onDisappear { lookupTask?.cancel() }
    }
  }

  private func lookUpPark() async {
    guard !Task.isCancelled else { return }
    let code: ParkCode
    do {
      code = try ParkCode(parkCode)
    } catch {
      message = "Enter one park code with 4 to 10 letters or digits, such as acad."
      parks = []
      return
    }

    isLoading = true
    message = "Looking up \(code.rawValue)."
    parks = []
    defer { isLoading = false }

    do throws(NPSDataError) {
      let client = try NPSDataClient(apiKey: apiKey)
      let page = try await client.parks(parkCode: code)
      guard !Task.isCancelled else { return }
      parks = page.data
      message =
        page.data.isEmpty
        ? "No park matched \(code.rawValue)."
        : "Showing \(page.data.count) of \(page.total) matching parks."
    } catch {
      switch error {
      case .invalidAPIKey:
        message = "Enter an API key without spaces or line breaks."
      case .pagination:
        message = "NPS returned inconsistent page information. Try again."
      case .service(_, let response):
        message =
          response.statusCode == 429
          ? "NPS has limited requests for this key. Try again later."
          : "NPS refused the request (HTTP \(response.statusCode ?? 0)). Check your API key."
      case .transport(.cancelled):
        message = "Lookup cancelled."
      case .transport:
        message = "The park could not be loaded. Check your connection and try again."
      }
    }
  }
}

#Preview {
  ContentView()
}
