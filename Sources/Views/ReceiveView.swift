import SwiftUI

struct ReceiveView: View {
  @EnvironmentObject var wallet: WalletManager
  @State private var copied = false

  var body: some View {
    VStack(spacing: 0) {
      Text("Receive")
        .font(.system(size: 22, weight: .bold))
        .foregroundStyle(.black)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
        .padding(.top, 24)
        .padding(.bottom, 28)

      if let account = wallet.account {
        Spacer()

        VStack(spacing: 24) {
          // QR placeholder
          ZStack {
            RoundedRectangle(cornerRadius: 20)
              .fill(.black.opacity(0.03))
              .frame(width: 180, height: 180)
            Image(systemName: "qrcode")
              .font(.system(size: 80))
              .foregroundStyle(.black.opacity(0.15))
          }

          VStack(spacing: 12) {
            Text("Your Address")
              .font(.system(size: 11, weight: .semibold))
              .foregroundStyle(.black.opacity(0.3))
              .tracking(1)

            Text(account.addressHex)
              .font(.system(size: 12, weight: .medium, design: .monospaced))
              .foregroundStyle(.black.opacity(0.6))
              .multilineTextAlignment(.center)
              .lineSpacing(4)
              .padding(.horizontal, 40)
              .textSelection(.enabled)
          }

          Button(action: {
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(account.addressHex, forType: .string)
            copied = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
              copied = false
            }
          }) {
            HStack(spacing: 8) {
              Image(systemName: copied ? "checkmark" : "doc.on.doc")
                .font(.system(size: 12, weight: .semibold))
              Text(copied ? "Copied" : "Copy Address")
                .font(.system(size: 14, weight: .semibold))
            }
            .foregroundStyle(copied ? .white : .black)
            .frame(width: 180, height: 44)
            .background(copied ? .black : .black.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .animation(.easeInOut(duration: 0.2), value: copied)
          }
          .buttonStyle(.plain)
        }

        Spacer()
      }
    }
    .background(.white)
  }
}
