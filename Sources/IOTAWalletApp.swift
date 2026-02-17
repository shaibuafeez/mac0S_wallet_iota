import SwiftUI

@main
struct IOTAWalletApp: App {
  @StateObject private var walletManager = WalletManager()

  var body: some Scene {
    WindowGroup {
      ContentView()
        .environmentObject(walletManager)
        .frame(minWidth: 440, minHeight: 660)
    }
    .windowStyle(.hiddenTitleBar)
    .defaultSize(width: 440, height: 720)
  }
}
