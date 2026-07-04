import 'dart:io';
import 'dart:math';
import 'package:pointycastle/export.dart';
import 'package:projet_blockchain/Model/blockchain.dart';
import 'package:projet_blockchain/Model/entry.dart';

import 'rsa_generation_and_verification.dart';

class User {
  static const k = 21;

  Blockchain myBlockChain = Blockchain([]);

  late final AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> keyPair;
  RSAPublicKey get getPublicKey => keyPair.publicKey;
  RSAPrivateKey get getPrivateKey => keyPair.privateKey;

  late final String pseudo;
  String get getPseudo => pseudo;

  late final String password;
  String get getMdp => password;

  int scorePlayer = 0;
  int get getScorePlayer => scorePlayer;

  int scoreRef = 0;
  int get getScoreArbitre => scoreRef;

  int scoreElo = 23456786543345;
  int get getScoreElo => scoreElo;

  User({
    required this.pseudo,
    required this.password,
  }) {
    keyPair = generateKeyPair();
  }

  Map<String, dynamic> toMap() {
    print(keyPair);

    var map = <String, dynamic>{
      'userName': pseudo,
      'password': password,
      // convert BigInt to string cause the cannot handle BigInt
      'publicKeyModulus': keyPair.publicKey.modulus.toString(),
      'publicKeyExponent': keyPair.publicKey.exponent.toString(),
      'privateKeyModulus': keyPair.privateKey.modulus.toString(),
      'privateKeyExponent': keyPair.privateKey.exponent.toString(),
      'privateKeyComponentP': keyPair.privateKey.p.toString(),
      'privateKeyComponentQ': keyPair.privateKey.q.toString()
    };
    return map;
  }

  //pour sotir les donnée
  User.fromMap(Map<String, dynamic> map) {
    // retrieve the data
    print("dans le fromMap()");

    pseudo = map['userName'];
    password = map['password'];
    var publicKeyModulus = map['publicKeyModulus'];
    var publicKeyExponent = map['publicKeyExponent'];
    var privateKeyModulus = map['privateKeyModulus'];
    var privateKeyExponent = map['privateKeyExponent'];
    var privateKeyComponentP = map['privateKeyComponentP'];
    var privateKeyComponentQ = map['privateKeyComponentQ'];

    // convert string to BigInt
    var bigIntpublicKeyModulus = BigInt.parse(publicKeyModulus);
    var bigIntpublicKeyExponent = BigInt.parse(publicKeyExponent);
    var bigIntprivateKeyModulus = BigInt.parse(privateKeyModulus);
    var bigIntprivateKeyExponent = BigInt.parse(privateKeyExponent);
    var bigIntprivateKeyComponentP = BigInt.parse(privateKeyComponentP);
    var bigIntprivateKeyComponentQ = BigInt.parse(privateKeyComponentQ);

    // construct the RSAPrivateKey and RSAPublicKey

    RSAPrivateKey rsaPrivateKey = RSAPrivateKey(
      bigIntprivateKeyModulus,
      bigIntprivateKeyExponent,
      bigIntprivateKeyComponentP,
      bigIntprivateKeyComponentQ,
    );
    RSAPublicKey rsaPublicKey =
        RSAPublicKey(bigIntpublicKeyModulus, bigIntpublicKeyExponent);

    //create the keyPair
    keyPair = getKeyPairFromMap(rsaPublicKey, rsaPrivateKey);
  }

  getKeyPairFromMap(RSAPublicKey rsaPublicKey, RSAPrivateKey rsaPrivateKey) {
    return AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>(
        rsaPublicKey, rsaPrivateKey);
  }

  generateKeyPair() {
    print("@@@@@@@@@@@@@@@@@@@@@@@@");
    return generateRSAkeyPair(exampleSecureRandom());
  }

  void setScorePlayer(int newScoreElo, int newScoreRef) {
    scorePlayer = newScoreElo * newScoreRef;
  }

  void setScoreRef(int newScoreRef) {
    scoreRef = newScoreRef;
  }

  void computeEloScore(User opponent, bool result) {
    double scoreAttendu =
        1 / (1 + pow(10, (opponent.scoreElo - scoreElo) / 400));
    scoreElo = (scoreElo + k * ((result ? 1 : 0) - scoreAttendu)).round();
  }

  void addEntry(Entry newEntry) {
    print("ici");
    myBlockChain.addEntry(newEntry);
  }

  void setBlockChain(Blockchain newBlockChain) {
    myBlockChain = newBlockChain;
  }
}
