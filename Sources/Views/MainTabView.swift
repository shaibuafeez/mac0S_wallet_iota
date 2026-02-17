import SwiftUI

struct MainTabView: View {
  @EnvironmentObject var wallet: WalletManager
  @State private var selectedTab = 0

  var body: some View {
    VStack(spacing: 0) {
      // Content
      Group {
        switch selectedTab {
        case 0: WalletView()
        case 1: SendView()
        case 2: ReceiveView()
        case 3: TransactionHistoryView()
        case 4: SettingsView()
        default: WalletView()
        }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)

      // Tab bar
      Divider()
        .foregroundStyle(.black.opacity(0.06))

      HStack(spacing: 0) {
        TabButton(icon: "square.stack", label: "Wallet", index: 0, selected: $selectedTab)
        TabButton(icon: "arrow.up", label: "Send", index: 1, selected: $selectedTab)
        TabButton(icon: "arrow.down", label: "Receive", index: 2, selected: $selectedTab)
        TabButton(icon: "list.bullet", label: "Activity", index: 3, selected: $selectedTab)
        TabButton(icon: "gearshape", label: "Settings", index: 4, selected: $selectedTab)
      }
      .padding(.top, 8)
      .padding(.bottom, 12)
      .background(.white)
    }
    .background(.white)
  }
}

struct TabButton: View {
  let icon: String
  let label: String
  let index: Int
  @Binding var selected: Int

  var isSelected: Bool { selected == index }

  var body: some View {
    Button(action: { selected = index }) {
      VStack(spacing: 4) {
        Image(systemName: icon)
          .font(.system(size: 18, weight: isSelected ? .semibold : .regular))
          .foregroundStyle(isSelected ? .black : .black.opacity(0.3))
        Text(label)
          .font(.system(size: 10, weight: isSelected ? .semibold : .regular))
          .foregroundStyle(isSelected ? .black : .black.opacity(0.3))
      }
      .frame(maxWidth: .infinity)
    }
    .buttonStyle(.plain)
  }
}
