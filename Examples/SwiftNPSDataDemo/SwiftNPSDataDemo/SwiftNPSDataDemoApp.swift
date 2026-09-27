import SwiftUI

@main
struct SwiftNPSDataDemoApp: App {
  var body: some Scene {
    WindowGroup {
      TabView {
        Tab("Data API", systemImage: "tree") { ContentView() }
        Tab("IRMA", systemImage: "leaf") { IRMAExplorerView() }
      }
    }
  }
}
