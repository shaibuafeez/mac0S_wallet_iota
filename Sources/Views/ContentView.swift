import SwiftUI

struct ContentView: View {
  @EnvironmentObject var wallet: WalletManager

  var body: some View {
    ZStack {
      Color.white.ignoresSafeArea()

      Group {
        if wallet.isLoggedIn {
          MainTabView()
        } else {
          WelcomeView()
        }
      }
    }
    .preferredColorScheme(.light)
  }
}
