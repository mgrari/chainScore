# chainScore

A tamper-proof sports scorekeeping application built with Flutter, secured by RSA cryptography and a shared blockchain ledger.

## What is it?

In amateur sports leagues, match results are self-reported and can be disputed or faked. chainScore solves this by ensuring that a match result is only officially recorded if **all three parties — Player 1, Player 2, and a Referee — cryptographically sign and agree on the outcome**.

The result is stored as a block on a shared blockchain. Every connected player holds an identical copy of the full match history, meaning the network collectively acts as a witness — any player can audit any match result at any time by verifying the three signatures.

## How it works

1. When a match ends, an entry (block) is created containing the scores and the public keys of both players and the referee
2. Each of the three parties signs the match data with their private RSA key — the private key never leaves their device
3. The signed entry is broadcast via a central server to all connected players
4. Every player appends the entry to their local chain
5. ELO scores are updated based on the match result and the relative strength of the opponent

## How the cryptography works

Signing a match result is a two-step process.

**Step 1 — Hashing with SHA256**

The match data is first compressed into a fixed-size 256-bit fingerprint using SHA256. This fingerprint is unique to that exact data — changing even one character produces a completely different hash. This step ensures RSA always operates on data of a predictable size, and closes certain cryptographic attack vectors that arise from signing raw data directly.

**Step 2 — Signing with RSA**

RSA then signs the hash using the signer's private key (2048-bit), producing a signature. This signature is mathematically tied to both the hash and the private key. Since the private key never leaves the owner's device, no one else can produce a valid signature on their behalf.

```
match data  →  SHA256  →  hash  →  RSA sign (private key)  →  signature
```

**Verification**

To verify an entry, any player can run the same process on the original data and check it against the signature using the signer's public key. If the data was tampered with in any way, the hash will not match and the signature will be rejected.

```
match data  →  SHA256  →  hash  ─┐
                                  ├─ compare  →  valid or invalid
signature   →  RSA verify ────────┘
```

An entry is only accepted into the blockchain if all three signatures — from Player 1, Player 2, and the Referee — pass this verification.

---

## Architecture

```
Flutter App (client)  ←── TCP Socket ──→  Dart Server
       │
       ├── RSA key generation & signing (pointycastle)
       ├── Local SQLite database (user credentials + keypairs)
       ├── Blockchain (append-only list of signed match entries)
       └── ELO ranking system
```

## Tech stack

| Layer | Technology |
|---|---|
| UI | Flutter (mobile + desktop) |
| Server | Dart TCP socket server |
| Cryptography | pointycastle — RSA 2048-bit |
| Local storage | SQLite via sqflite |
| Language | Dart |

## Running the project

### Start the server

```bash
cd lib/server
dart run bin/server.dart
```

The server listens on port `3000`. Update the IP address in `lib/main.dart` to match your machine's local IP.

### Run the app

```bash
flutter run
```

## Project structure

```
lib/
├── Model/
│   ├── blockchain.dart       # Blockchain and entry validation
│   ├── entry.dart            # A single signed match result
│   ├── user.dart             # User model with RSA keypair and ELO score
│   └── rsa_generation_and_verification.dart
├── Screens/
│   ├── home_page.dart        # Main UI: blockchain view, invitations, notifications
│   ├── login.dart
│   └── sign_up.dart
├── DatabaseHandler/
│   └── db_helper.dart        # SQLite persistence for users and keypairs
├── Common/
│   ├── socket_service.dart   # TCP socket communication protocol
│   └── terminal_service.dart
└── server/
    └── bin/
        └── server.dart       # Dart TCP server — broadcasts entries between clients
```
