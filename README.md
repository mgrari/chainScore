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
