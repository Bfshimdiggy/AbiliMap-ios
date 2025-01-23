import SwiftUI
import Firebase

struct HomeView: View {
    @State private var showingSettings = false
    @State private var showPopup = false // State for showing the issue submission popup
    @EnvironmentObject var userSession: UserSession // Observing user session

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Check if the user is signed in using UserSession
                if let userName = userSession.userName {
                    Text("Welcome, \(userName)!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding()
                        .foregroundColor(.white)

                    // Submit an Issue button with a blue circle and gradient
                    NavigationLink(destination: IssuePopupView(showPopup: $showPopup)) {
                        ZStack {
                            // Gradient Circle
                            Circle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.blue, Color.purple]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: 120, height: 120)

                            // White Plus Sign
                            Image(systemName: "plus")
                                .foregroundColor(.white)
                                .font(.largeTitle)
                        }
                    }

                    // Submit an Issue Text
                    Text("Submit an Issue")
                        .foregroundColor(.white)
                        .padding(.top, 10)

                    // View My Submitted Issues button with gradient
                    NavigationLink(destination: UserIssuesView()) {
                        Text("View My Submitted Issues")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.blue, Color.purple]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(8)
                            .padding(.top, 20)
                    }
                } else {
                    SignUpOrSignInView() // Show sign-in/up screen if not logged in
                }
            }
            .padding()
            .navigationTitle("AbiliMap")
            .navigationBarItems(trailing:
                // Show settings icon only if user is logged in
                Group {
                    if userSession.isLoggedIn {
                        Button(action: {
                            showingSettings.toggle()
                        }) {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 25))
                                .foregroundColor(.blue)
                        }
                    }
                }
            )
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
        }
        .onAppear {
            // Ensure user login status is correctly updated
        }
    }
}
