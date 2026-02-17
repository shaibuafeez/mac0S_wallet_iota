import SwiftUI

struct WelcomeView: View {
  @EnvironmentObject var wallet: WalletManager
  @State private var showImport = false
  @State private var mnemonicInput = ""
  @State private var appear = false

  var body: some View {
    VStack(spacing: 0) {
      Spacer()

      VStack(spacing: 24) {
        // Logo
        ZStack {
          Circle()
            .fill(.black)
            .frame(width: 80, height: 80)
          Text("I")
            .font(.system(size: 36, weight: .bold, design: .default))
            .foregroundStyle(.white)
        }
        .opacity(appear ? 1 : 0)
        .offset(y: appear ? 0 : 20)

        VStack(spacing: 8) {
          Text("IOTA Wallet")
            .font(.system(size: 28, weight: .bold))
            .foregroundStyle(.black)

          Text("Simple. Secure. Swift.")
            .font(.system(size: 14, weight: .regular))
            .foregroundStyle(.black.opacity(0.4))
            .tracking(1.5)
        }
        .opacity(appear ? 1 : 0)
        .offset(y: appear ? 0 : 15)
      }

      Spacer()

      VStack(spacing: 12) {
        Button(action: {
          do {
            try wallet.createWallet()
          } catch {
            wallet.error = error.localizedDescription
          }
        }) {
          Text("Create Wallet")
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(.black)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)

        Button(action: { showImport = true }) {
          Text("Import Mnemonic")
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(.black)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(.black.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
      }
      .padding(.horizontal, 32)
      .opacity(appear ? 1 : 0)
      .offset(y: appear ? 0 : 10)

      if let error = wallet.error {
        Text(error)
          .font(.system(size: 12))
          .foregroundStyle(.red)
          .padding(.top, 12)
      }

      Spacer()
        .frame(height: 48)
    }
    .background(.white)
    .onAppear {
      withAnimation(.easeOut(duration: 0.6)) {
        appear = true
      }
    }
    .sheet(isPresented: $showImport) {
      ImportView(mnemonicInput: $mnemonicInput, showImport: $showImport)
    }
  }
}

struct ImportView: View {
  @EnvironmentObject var wallet: WalletManager
  @Binding var mnemonicInput: String
  @Binding var showImport: Bool

  var body: some View {
    VStack(spacing: 0) {
      // Header
      HStack {
        Button(action: {
          showImport = false
          mnemonicInput = ""
        }) {
          Image(systemName: "xmark")
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(.black.opacity(0.5))
        }
        .buttonStyle(.plain)
        Spacer()
        Text("Import Wallet")
          .font(.system(size: 15, weight: .semibold))
          .foregroundStyle(.black)
        Spacer()
        // Balance spacer
        Image(systemName: "xmark")
          .font(.system(size: 14))
          .opacity(0)
      }
      .padding(.horizontal, 20)
      .padding(.top, 20)
      .padding(.bottom, 24)

      Text("Enter your recovery phrase")
        .font(.system(size: 13))
        .foregroundStyle(.black.opacity(0.4))
        .padding(.bottom, 16)

      TextEditor(text: $mnemonicInput)
        .font(.system(size: 14, weight: .regular, design: .monospaced))
        .foregroundStyle(.black)
        .scrollContentBackground(.hidden)
        .padding(16)
        .frame(height: 100)
        .background(.black.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
          RoundedRectangle(cornerRadius: 12)
            .stroke(.black.opacity(0.08), lineWidth: 1)
        )
        .padding(.horizontal, 20)

      Spacer()

      Button(action: {
        let trimmed = mnemonicInput.trimmingCharacters(in: .whitespacesAndNewlines)
        do {
          try wallet.importWallet(mnemonic: trimmed)
          showImport = false
          mnemonicInput = ""
        } catch {
          wallet.error = error.localizedDescription
        }
      }) {
        Text("Import")
          .font(.system(size: 15, weight: .semibold))
          .foregroundStyle(.white)
          .frame(maxWidth: .infinity)
          .frame(height: 52)
          .background(
            mnemonicInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
              ? .black.opacity(0.2) : .black
          )
          .clipShape(RoundedRectangle(cornerRadius: 14))
      }
      .buttonStyle(.plain)
      .disabled(mnemonicInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
      .padding(.horizontal, 20)

      if let error = wallet.error {
        Text(error)
          .font(.system(size: 12))
          .foregroundStyle(.red)
          .padding(.top, 8)
      }

      Spacer()
        .frame(height: 24)
    }
    .frame(width: 400, height: 340)
    .background(.white)
  }
}
