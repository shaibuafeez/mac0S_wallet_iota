import SwiftUI

struct SettingsView: View {
  @EnvironmentObject var wallet: WalletManager
  @State private var showMnemonic = false
  @State private var showLogoutConfirm = false

  var body: some View {
    VStack(spacing: 0) {
      Text("Settings")
        .font(.system(size: 22, weight: .bold))
        .foregroundStyle(.black)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
        .padding(.top, 24)
        .padding(.bottom, 20)

      Divider().foregroundStyle(.black.opacity(0.06))

      ScrollView {
        VStack(spacing: 0) {
          // Network
          VStack(alignment: .leading, spacing: 12) {
            Text("NETWORK")
              .font(.system(size: 11, weight: .semibold))
              .foregroundStyle(.black.opacity(0.3))
              .tracking(1)

            HStack(spacing: 8) {
              ForEach(WalletManager.Network.allCases, id: \.self) { net in
                Button(action: {
                  wallet.network = net
                  Task { await wallet.refreshBalance() }
                }) {
                  Text(net.rawValue)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(wallet.network == net ? .white : .black.opacity(0.5))
                    .frame(maxWidth: .infinity)
                    .frame(height: 38)
                    .background(wallet.network == net ? .black : .black.opacity(0.04))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
              }
            }
          }
          .padding(.horizontal, 24)
          .padding(.top, 24)
          .padding(.bottom, 20)

          Divider().foregroundStyle(.black.opacity(0.06))
            .padding(.horizontal, 24)

          // Account
          if let account = wallet.account {
            VStack(alignment: .leading, spacing: 16) {
              Text("ACCOUNT")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.black.opacity(0.3))
                .tracking(1)

              // Address
              VStack(alignment: .leading, spacing: 6) {
                Text("Address")
                  .font(.system(size: 12))
                  .foregroundStyle(.black.opacity(0.3))
                Text(account.addressHex)
                  .font(.system(size: 12, design: .monospaced))
                  .foregroundStyle(.black.opacity(0.6))
                  .textSelection(.enabled)
                  .lineLimit(2)
              }

              // Mnemonic
              Button(action: { withAnimation(.easeInOut(duration: 0.2)) { showMnemonic.toggle() } }) {
                HStack {
                  Text(showMnemonic ? "Hide Recovery Phrase" : "Show Recovery Phrase")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.black.opacity(0.6))
                  Spacer()
                  Image(systemName: showMnemonic ? "eye.slash" : "eye")
                    .font(.system(size: 13))
                    .foregroundStyle(.black.opacity(0.3))
                }
                .padding(14)
                .background(.black.opacity(0.03))
                .clipShape(RoundedRectangle(cornerRadius: 10))
              }
              .buttonStyle(.plain)

              if showMnemonic {
                Text(account.mnemonic)
                  .font(.system(size: 13, design: .monospaced))
                  .foregroundStyle(.black.opacity(0.7))
                  .padding(14)
                  .frame(maxWidth: .infinity, alignment: .leading)
                  .background(.black.opacity(0.03))
                  .clipShape(RoundedRectangle(cornerRadius: 10))
                  .overlay(
                    RoundedRectangle(cornerRadius: 10)
                      .stroke(.black.opacity(0.06), lineWidth: 1)
                  )
                  .textSelection(.enabled)
              }
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .padding(.bottom, 20)
          }

          Divider().foregroundStyle(.black.opacity(0.06))
            .padding(.horizontal, 24)

          // Logout
          Button(action: { showLogoutConfirm = true }) {
            HStack {
              Text("Logout")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.red.opacity(0.8))
              Spacer()
              Image(systemName: "arrow.right.square")
                .font(.system(size: 14))
                .foregroundStyle(.red.opacity(0.4))
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 18)
          }
          .buttonStyle(.plain)
        }
      }
    }
    .background(.white)
    .alert("Logout?", isPresented: $showLogoutConfirm) {
      Button("Cancel", role: .cancel) {}
      Button("Logout", role: .destructive) {
        wallet.logout()
      }
    } message: {
      Text("Make sure you've saved your recovery phrase.")
    }
  }
}
