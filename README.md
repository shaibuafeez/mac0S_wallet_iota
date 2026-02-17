# IOTA Wallet — macOS

A minimal macOS wallet for the IOTA blockchain, built with SwiftUI and the [IOTA Swift SDK](https://github.com/shaibuafeez/swift-bindings).

## Demo

https://github.com/user-attachments/assets/Demo.mov

## Features

- **Create / Import** wallet via mnemonic phrase
- **View balance** with one-tap refresh
- **Send IOTA** with confirmation dialog
- **Receive** with address copy
- **Transaction history**
- **Network switching** between Devnet and Testnet
- **Devnet faucet** for testing
- **Recovery phrase** backup in settings

## Requirements

- macOS 13.0+
- Xcode 15+
- [IOTA Swift SDK](https://github.com/shaibuafeez/swift-bindings) (referenced as local SPM dependency)

## Setup

```bash
# Clone
git clone https://github.com/shaibuafeez/mac0S_wallet_iota.git
cd mac0S_wallet_iota

# Build the IOTA SDK first (requires Rust)
cd ../iota-rust-sdk
make swift

# Open in Xcode
open IOTAWallet.xcodeproj
```

In Xcode, set the environment variable before running:

**Product > Scheme > Edit Scheme > Run > Arguments > Environment Variables**

| Name | Value |
|------|-------|
| `DYLD_LIBRARY_PATH` | `path/to/iota-rust-sdk/bindings/swift/Sources/IotaSDKFFI` |

Then press **Cmd+R** to build and run.

## Architecture

```
Sources/
  IOTAWalletApp.swift          — App entry point
  Models/
    WalletManager.swift        — SDK integration, state management
  Views/
    ContentView.swift          — Root view (login gate)
    WelcomeView.swift          — Create / import wallet
    MainTabView.swift          — Custom tab bar
    WalletView.swift           — Balance display
    SendView.swift             — Send IOTA
    ReceiveView.swift          — Address & copy
    TransactionHistoryView.swift — Activity list
    SettingsView.swift         — Network, backup, logout
```

## Tech Stack

- **SwiftUI** — declarative UI
- **IOTA Swift SDK** — blockchain interaction via GraphQL
- **Ed25519** — key generation and transaction signing
- **XcodeGen** — project generation from `project.yml`
