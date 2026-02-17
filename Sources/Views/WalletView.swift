import SwiftUI

struct WalletView: View {
  @EnvironmentObject var wallet: WalletManager
  @State private var faucetLoading = false

  var body: some View {
    VStack(spacing: 0) {
      // Top bar
      HStack {
        VStack(alignment: .leading, spacing: 2) {
          Text("Wallet")
            .font(.system(size: 22, weight: .bold))
            .foregroundStyle(.black)
          HStack(spacing: 6) {
            Circle()
              .fill(wallet.network == .devnet ? .black : .black.opacity(0.4))
              .frame(width: 6, height: 6)
            Text(wallet.network.rawValue)
              .font(.system(size: 11, weight: .medium))
              .foregroundStyle(.black.opacity(0.4))
              .tracking(0.5)
          }
        }
        Spacer()
        Button(action: {
          Task { await wallet.refreshBalance() }
        }) {
          Image(systemName: "arrow.clockwise")
            .font(.system(size: 14, weight: .medium))
            .foregroundStyle(.black.opacity(0.5))
            .frame(width: 36, height: 36)
            .background(.black.opacity(0.04))
            .clipShape(Circle())
        }
        .buttonStyle(.plain)
        .disabled(wallet.isLoading)
      }
      .padding(.horizontal, 24)
      .padding(.top, 24)
      .padding(.bottom, 20)

      // Balance card
      VStack(spacing: 4) {
        Text(wallet.formatIota(wallet.iotaBalance))
          .font(.system(size: 48, weight: .bold, design: .default))
          .foregroundStyle(.black)
          .contentTransition(.numericText())

        Text("IOTA")
          .font(.system(size: 13, weight: .semibold))
          .foregroundStyle(.black.opacity(0.3))
          .tracking(2)
      }
      .frame(maxWidth: .infinity)
      .padding(.vertical, 32)
      .background(.black.opacity(0.03))
      .clipShape(RoundedRectangle(cornerRadius: 20))
      .padding(.horizontal, 24)

      // Address pill
      if let account = wallet.account {
        Button(action: {
          NSPasteboard.general.clearContents()
          NSPasteboard.general.setString(account.addressHex, forType: .string)
        }) {
          HStack(spacing: 6) {
            Text(truncateAddress(account.addressHex))
              .font(.system(size: 12, weight: .medium, design: .monospaced))
              .foregroundStyle(.black.opacity(0.5))
            Image(systemName: "doc.on.doc")
              .font(.system(size: 10))
              .foregroundStyle(.black.opacity(0.3))
          }
          .padding(.horizontal, 14)
          .padding(.vertical, 8)
          .background(.black.opacity(0.04))
          .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .padding(.top, 12)
      }

      // Faucet
      if wallet.network == .devnet {
        Button(action: {
          faucetLoading = true
          Task {
            await wallet.requestFromFaucet()
            faucetLoading = false
          }
        }) {
          HStack(spacing: 8) {
            if faucetLoading {
              ProgressView()
                .scaleEffect(0.7)
                .tint(.black)
            }
            Text("Request Devnet Tokens")
              .font(.system(size: 13, weight: .semibold))
              .foregroundStyle(.black)
          }
          .frame(maxWidth: 220)
          .frame(height: 40)
          .background(.black.opacity(0.06))
          .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
        .disabled(faucetLoading)
        .padding(.top, 16)
      }

      Spacer()

      // Empty state or token row
      if wallet.iotaBalance == 0 && !wallet.isLoading {
        VStack(spacing: 8) {
          Text("No tokens yet")
            .font(.system(size: 14, weight: .medium))
            .foregroundStyle(.black.opacity(0.25))
        }
        Spacer()
      } else if wallet.iotaBalance > 0 {
        VStack(spacing: 0) {
          Divider().foregroundStyle(.black.opacity(0.06))
            .padding(.horizontal, 24)

          HStack {
            ZStack {
              RoundedRectangle(cornerRadius: 10)
                .fill(.black)
                .frame(width: 36, height: 36)
              Text("I")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 2) {
              Text("IOTA")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.black)
              Text("Native Token")
                .font(.system(size: 11))
                .foregroundStyle(.black.opacity(0.3))
            }

            Spacer()

            Text("\(wallet.formatIota(wallet.iotaBalance))")
              .font(.system(size: 16, weight: .bold, design: .monospaced))
              .foregroundStyle(.black)
          }
          .padding(.horizontal, 24)
          .padding(.vertical, 16)
        }
        .padding(.top, 12)
        Spacer()
      }

      if wallet.isLoading && !faucetLoading {
        ProgressView()
          .tint(.black)
          .padding()
      }

      if let error = wallet.error {
        Text(error)
          .font(.system(size: 11))
          .foregroundStyle(.red.opacity(0.8))
          .padding(.horizontal, 24)
          .padding(.bottom, 8)
      }
    }
    .background(.white)
    .task {
      await wallet.refreshBalance()
    }
  }

  private func truncateAddress(_ hex: String) -> String {
    guard hex.count > 16 else { return hex }
    return "\(hex.prefix(10))...\(hex.suffix(6))"
  }
}
