import Foundation
import IotaSDK

struct WalletAccount {
  let mnemonic: String
  let privateKey: Ed25519PrivateKey
  let address: Address
  let addressHex: String
}

struct TxRecord: Identifiable {
  let id: String
  let digest: String
}

@MainActor
class WalletManager: ObservableObject {
  @Published var account: WalletAccount?
  @Published var iotaBalance: UInt64 = 0
  @Published var transactions: [TxRecord] = []
  @Published var isLoading = false
  @Published var error: String?
  @Published var network: Network = .devnet

  enum Network: String, CaseIterable {
    case devnet = "Devnet"
    case testnet = "Testnet"
  }

  var client: GraphQlClient {
    switch network {
    case .devnet: return GraphQlClient.newDevnet()
    case .testnet: return GraphQlClient.newTestnet()
    }
  }

  var isLoggedIn: Bool { account != nil }

  // MARK: - Wallet Creation

  func createWallet() throws {
    let mnemonic = generateMnemonic(wordCount: nil)
    try importWallet(mnemonic: mnemonic)
  }

  func importWallet(mnemonic: String) throws {
    let privateKey = try Ed25519PrivateKey.fromMnemonic(phrase: mnemonic)
    let publicKey = privateKey.publicKey()
    let address = publicKey.deriveAddress()
    let addressHex = address.toHex()

    account = WalletAccount(
      mnemonic: mnemonic,
      privateKey: privateKey,
      address: address,
      addressHex: addressHex
    )
    error = nil
  }

  func logout() {
    account = nil
    iotaBalance = 0
    transactions = []
    error = nil
  }

  // MARK: - Balance

  func refreshBalance() async {
    guard let account = account else { return }
    isLoading = true
    error = nil

    do {
      let result = try await client.balance(address: account.address)
      iotaBalance = result ?? 0
    } catch {
      self.error = "Failed to fetch balance: \(error.localizedDescription)"
    }

    isLoading = false
  }

  // MARK: - Send IOTA

  func sendIota(to recipient: String, amount: UInt64) async -> Bool {
    guard let account = account else { return false }
    isLoading = true
    error = nil

    do {
      let toAddress = try Address.fromHex(hex: recipient)
      let builder = TransactionBuilder(sender: account.address)
        .withClient(client: client)

      builder.sendIota(
        recipient: toAddress,
        amount: PtbArgument.u64(value: amount)
      )

      let signer = TransactionSigner.fromEd25519(key: account.privateKey)
      let effects = try await builder.execute(
        signer: signer, waitFor: WaitForTx.finalized)

      let status = effects.asV1().status
      switch status {
      case .success:
        await refreshBalance()
        isLoading = false
        return true
      case .failure(let executionError, _):
        self.error = "Transaction failed: \(executionError)"
      }
    } catch {
      self.error = "Send failed: \(error.localizedDescription)"
    }

    isLoading = false
    return false
  }

  // MARK: - Transactions

  func refreshTransactions() async {
    guard let account = account else { return }
    isLoading = true
    error = nil

    do {
      let filter = TransactionsFilter(signAddress: account.address)
      let result = try await client.transactions(filter: filter)

      var records: [TxRecord] = []
      for tx in result.data {
        let digest = tx.transaction.digest().toBase58()
        records.append(TxRecord(id: digest, digest: digest))
      }
      transactions = records
    } catch {
      self.error = "Failed to fetch transactions: \(error.localizedDescription)"
    }

    isLoading = false
  }

  // MARK: - Faucet (devnet only)

  func requestFromFaucet() async -> Bool {
    guard let account = account else { return false }
    guard network == .devnet else {
      error = "Faucet only available on devnet"
      return false
    }

    isLoading = true
    error = nil

    do {
      let faucet = FaucetClient.newDevnet()
      let receipt = try await faucet.requestAndWaitForFinalized(
        address: account.address, client: client)
      if receipt != nil {
        await refreshBalance()
        isLoading = false
        return true
      } else {
        error = "Faucet request failed"
      }
    } catch {
      self.error = "Faucet error: \(error.localizedDescription)"
    }

    isLoading = false
    return false
  }

  // MARK: - Helpers

  func formatIota(_ nanos: UInt64) -> String {
    let iota = Double(nanos) / 1_000_000_000
    if iota == 0 { return "0" }
    return String(format: "%.4f", iota)
  }
}
