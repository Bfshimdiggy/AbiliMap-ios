import SwiftUI
import CoreLocation
import Firebase

struct ContentView: View {
    @State private var showPopup = false
    @State private var isAdmin = false

    var body: some View {
        VStack {
            Text("Click the + to report an issue")
                .font(.title)
                .padding()

            Button(action: {
                self.showPopup.toggle()
            }) {
                Image(systemName: "plus.circle")
                    .resizable()
                    .frame(width: 100, height: 100)
            }
            .padding()

            Spacer()

            Button(action: {
                self.isAdmin.toggle()
            }) {
                Text("Admin View")
                    .font(.title2)
                    .padding()
            }
            .sheet(isPresented: $isAdmin) {
                AdminView()
            }
        }
        .sheet(isPresented: $showPopup) {
            IssuePopupView(showPopup: self.$showPopup)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
