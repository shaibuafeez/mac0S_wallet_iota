import SwiftUI

struct TransactionHistoryView: View {
  @EnvironmentObject var wallet: WalletManager

  var body: some View {
    VStack(spacing: 0) {
      // Header
      HStack {
        Text("Activity")
          .font(.system(size: 22, weight: .bold))
          .foregroundStyle(.black)
        Spacer()
        Button(action: {
          Task { await wallet.refreshTransactions() }
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

      Divider().foregroundStyle(.black.opacity(0.06))

      if wallet.transactions.isEmpty && !wallet.isLoading {
        Spacer()
        VStack(spacing: 12) {
          ZStack {
            Circle()
              .fill(.black.opacity(0.03))
              .frame(width: 64, height: 64)
            Image(systemName: "clock")
              .font(.system(size: 24))
              .foregroundStyle(.black.opacity(0.15))
          }
          Text("No activity yet")
            .font(.system(size: 14, weight: .medium))
            .foregroundStyle(.black.opacity(0.25))
        }
        Spacer()
      } else {
        ScrollView {
          LazyVStack(spacing: 0) {
            ForEach(wallet.transactions) { tx in
              HStack(spacing: 12) {
                ZStack {
                  Circle()
                    .fill(.black.opacity(0.04))
                    .frame(width: 36, height: 36)
                  Image(systemName: "arrow.left.arrow.right")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.black.opacity(0.4))
                }

                Text(tx.digest)
                  .font(.system(size: 12, weight: .medium, design: .monospaced))
                  .foregroundStyle(.black.opacity(0.5))
                  .lineLimit(1)
                  .truncationMode(.middle)

                Spacer()
              }
              .padding(.horizontal, 24)
              .padding(.vertical, 14)

              Divider()
                .foregroundStyle(.black.opacity(0.04))
                .padding(.leading, 72)
            }
          }
        }
      }

      if wallet.isLoading {
        ProgressView()
          .tint(.black)
          .padding()
      }

      if let error = wallet.error {
        Text(error)
          .font(.system(size: 11))
          .foregroundStyle(.red.opacity(0.8))
          .padding()
      }
    }
    .background(.white)
    .task {
      await wallet.refreshTransactions()
    }
  }
}
