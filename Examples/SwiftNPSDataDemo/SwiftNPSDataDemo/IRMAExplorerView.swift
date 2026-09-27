import SwiftUI

struct IRMAExplorerView: View {
  var body: some View {
    NavigationStack {
      List {
        Section {
          NavigationLink("Species") { SpeciesExplorerView() }
          NavigationLink("Units") { UnitsExplorerView() }
          NavigationLink("Visitation") { VisitationExplorerView() }
        } footer: {
          Text("Explore public NPS records. No Data API key is required.")
        }
      }
      .navigationTitle("IRMA services")
    }
  }
}
