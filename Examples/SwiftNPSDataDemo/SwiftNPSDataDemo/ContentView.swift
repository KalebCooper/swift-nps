import SwiftNPSData
import SwiftNPSDataModels
import SwiftUI

struct ContentView: View {
  var body: some View {
    ContentUnavailableView(
      "NPS demo", systemImage: "tree",
      description: Text("Park data is not yet available in this demo.")
    )
  }
}

#Preview {
  ContentView()
}
