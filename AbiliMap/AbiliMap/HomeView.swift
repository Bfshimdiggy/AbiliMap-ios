import SwiftUI
import Firebase

struct HomeView: View {
    @State private var showingSettings = false
    @State private var showPopup = false // State for showing the issue submission popup
    @EnvironmentObject var userSession: UserSession // Observing user session
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background that works in both light and dark mode
                Color(UIColor.systemBackground)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    // App Title at the top
                    Text("AbiliMap")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.primary)
                        .padding(.top, 20)
                    
                    Spacer()
                    
                    // Submit an Issue button - redirects to sign in or issue form based on login status
                    if userSession.isLoggedIn {
                        // For logged in users, show issue form
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
                                    .frame(width: 220, height: 220)

                                // White Plus Sign
                                Image(systemName: "plus")
                                    .foregroundColor(.white)
                                    .font(.system(size: 80))
                            }
                        }
                    } else {
                        // For non-logged in users, direct to sign in
                        NavigationLink(destination: SignUpOrSignInView()) {
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
                                    .frame(width: 220, height: 220)

                                // White Plus Sign
                                Image(systemName: "plus")
                                    .foregroundColor(.white)
                                    .font(.system(size: 80))
                            }
                        }
                    }

                    // Submit an Issue Text
                    Text("Submit an Issue")
                        .foregroundColor(.primary)
                        .font(.system(size: 28, weight: .semibold))
                        .padding(.top, 20)
                        
                    Spacer()

                    // View My Submitted Issues button with gradient - only for logged in users
                    if userSession.isLoggedIn {
                        NavigationLink(destination: UserIssuesView()) {
                            HStack {
                                Image(systemName: "list.bullet")
                                    .foregroundColor(.white)
                                    .font(.system(size: 22))
                                Text("View My Submitted Issues")
                                    .foregroundColor(.white)
                                    .font(.system(size: 22, weight: .medium))
                            }
                            .padding(.vertical, 18)
                            .padding(.horizontal)
                            .frame(maxWidth: .infinity)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.blue, Color.purple]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                            .shadow(radius: 3)
                        }
                    } else {
                        // Sign In button for non-logged in users
                        NavigationLink(destination: SignUpOrSignInView()) {
                            HStack {
                                Image(systemName: "person.fill")
                                    .foregroundColor(.white)
                                    .font(.system(size: 22))
                                Text("Sign In")
                                    .foregroundColor(.white)
                                    .font(.system(size: 22, weight: .medium))
                            }
                            .padding(.vertical, 18)
                            .padding(.horizontal)
                            .frame(maxWidth: .infinity)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.blue, Color.green]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                            .shadow(radius: 3)
                        }
                    }
                }
                .padding(24)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing:
                // Show settings icon only if user is logged in
                Group {
                    if userSession.isLoggedIn {
                        Button(action: {
                            showingSettings.toggle()
                        }) {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.primary)
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
