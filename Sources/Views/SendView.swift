import SwiftUI

struct SendView: View {
  @EnvironmentObject var wallet: WalletManager
  @State private var recipient = ""
  @State private var amount = ""
  @State private var showConfirm = false
  @State private var showSuccess = false

  var body: some View {
    VStack(spacing: 0) {
      // Header
      Text("Send")
        .font(.system(size: 22, weight: .bold))
        .foregroundStyle(.black)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
        .padding(.top, 24)
        .padding(.bottom, 28)

      VStack(spacing: 20) {
        // Recipient
        VStack(alignment: .leading, spacing: 8) {
          Text("TO")
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(.black.opacity(0.3))
            .tracking(1)

          TextField("Recipient address", text: $recipient)
            .font(.system(size: 14, design: .monospaced))
            .foregroundStyle(.black)
            .textFieldStyle(.plain)
            .padding(16)
            .background(.black.opacity(0.03))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
              RoundedRectangle(cornerRadius: 12)
                .stroke(.black.opacity(0.06), lineWidth: 1)
            )
        }

        // Amount
        VStack(alignment: .leading, spacing: 8) {
          Text("AMOUNT")
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(.black.opacity(0.3))
            .tracking(1)

          HStack {
            TextField("0.00", text: $amount)
              .font(.system(size: 28, weight: .bold))
              .foregroundStyle(.black)
              .textFieldStyle(.plain)

            Text("IOTA")
              .font(.system(size: 13, weight: .semibold))
              .foregroundStyle(.black.opacity(0.3))
              .tracking(1)
          }
          .padding(16)
          .background(.black.opacity(0.03))
          .clipShape(RoundedRectangle(cornerRadius: 12))
          .overlay(
            RoundedRectangle(cornerRadius: 12)
              .stroke(.black.opacity(0.06), lineWidth: 1)
          )

          Text("Available: \(wallet.formatIota(wallet.iotaBalance)) IOTA")
            .font(.system(size: 12))
            .foregroundStyle(.black.opacity(0.3))
        }
      }
      .padding(.horizontal, 24)

      Spacer()

      if wallet.isLoading {
        ProgressView()
          .tint(.black)
          .padding(.bottom, 16)
      }

      if let error = wallet.error {
        Text(error)
          .font(.system(size: 12))
          .foregroundStyle(.red.opacity(0.8))
          .multilineTextAlignment(.center)
          .padding(.horizontal, 24)
          .padding(.bottom, 8)
      }

      // Send button
      Button(action: { showConfirm = true }) {
        Text("Send IOTA")
          .font(.system(size: 15, weight: .semibold))
          .foregroundStyle(.white)
          .frame(maxWidth: .infinity)
          .frame(height: 52)
          .background(isValid ? .black : .black.opacity(0.15))
          .clipShape(RoundedRectangle(cornerRadius: 14))
      }
      .buttonStyle(.plain)
      .disabled(!isValid || wallet.isLoading)
      .padding(.horizontal, 24)
      .padding(.bottom, 24)
    }
    .background(.white)
    .alert("Confirm", isPresented: $showConfirm) {
      Button("Cancel", role: .cancel) {}
      Button("Send") {
        Task { await send() }
      }
    } message: {
      Text("Send \(amount) IOTA to \(truncate(recipient))?")
    }
    .alert("Sent", isPresented: $showSuccess) {
      Button("OK") {}
    } message: {
      Text("Transaction completed successfully.")
    }
  }

  private var isValid: Bool {
    !recipient.isEmpty && recipient.hasPrefix("0x") && !amount.isEmpty
      && (Double(amount) ?? 0) > 0
  }

  private func send() async {
    guard let iotaAmount = Double(amount) else { return }
    let nanos = UInt64(iotaAmount * 1_000_000_000)
    let success = await wallet.sendIota(to: recipient, amount: nanos)
    if success {
      showSuccess = true
      recipient = ""
      amount = ""
    }
  }

  private func truncate(_ s: String) -> String {
    guard s.count > 16 else { return s }
    return "\(s.prefix(10))...\(s.suffix(6))"
  }
}
