import 'dart:convert';
import 'dart:ffi';

import 'package:pointycastle/export.dart';
import 'dart:typed_data';

class Entry {
  late final timestamp; //DateTime.now().millisecondsSinceEpoch
  get getTimestamp => timestamp;

  late final kpJ1;
  get getKpj1 => kpJ1;

  late final signatureJ1;
  get getSignatureJ1 => signatureJ1;

  late final kpJ2;
  get getKpj2 => kpJ2;

  late final signatureJ2;
  get getSignatureJ2 => signatureJ2;

  late final kpRef;
  get getKpRef => kpRef;

  late final signatureRef;
  get getSignatureRef => signatureRef;

  late final scoreJ1;
  get getScoreJ1 => scoreJ1;

  late final scoreJ2;
  get getScoreJ2 => scoreJ2;

  late final scoreRef;
  get getScoreRef => scoreRef;

  late final dataSigned;
  get getDataSigned => dataSigned;

  Entry(
      {this.timestamp,
      this.kpJ1,
      this.signatureJ1,
      this.kpJ2,
      this.signatureJ2,
      this.kpRef,
      this.signatureRef,
      this.scoreJ1,
      this.scoreJ2,
      this.scoreRef,
      this.dataSigned});
  // recuperer donnée affichage
  Entry.fromJson(Map<String, dynamic> json) {
    timestamp = json['timestamp'];
    // on recrée clef public joueur 1
    var publicKeyModulusKpJ1 = json['publicKeyModulusKpJ1'];
    var publicKeyExponentKpJ1 = json['publicKeyExponentKpJ1'];
    var m1 = BigInt.parse(publicKeyModulusKpJ1);
    var e1 = BigInt.parse(publicKeyExponentKpJ1);
    kpJ1 = RSAPublicKey(m1, e1);

    var signText1 = json['signatureJ1'];
    List<int> signList1 = utf8.encode(signText1);
    signatureJ1 = Uint8List.fromList(signList1);

    // on recrée clef public joueur 2
    var publicKeyModulusKpJ2 = json['publicKeyModulusKpJ2'];
    var publicKeyExponentKpJ2 = json['publicKeyExponentKpJ2'];
    var m2 = BigInt.parse(publicKeyModulusKpJ2);
    var e2 = BigInt.parse(publicKeyExponentKpJ2);
    kpJ2 = RSAPublicKey(m2, e2);

    var signText2 = json['signatureJ2'];
    List<int> signList2 = utf8.encode(signText2);
    signatureJ2 = Uint8List.fromList(signList2);

    // on recrée clef public du ref
    var publicKeyModulusKpRef = json['publicKeyModulusKpRef'];
    var publicKeyExponentKpRef = json['publicKeyExponentKpRef'];
    var m3 = BigInt.parse(publicKeyModulusKpRef);
    var e3 = BigInt.parse(publicKeyExponentKpRef);
    kpRef = RSAPublicKey(m3, e3);

    var signText3 = json['signatureRef'];
    List<int> signList3 = utf8.encode(signText3);
    signatureRef = Uint8List.fromList(signList3);

    scoreJ1 = json['scoreJ1'];
    scoreJ2 = json['scoreJ2'];
    scoreRef = json['scoreRef'];

    var dataSignedText = json['dataSigned'];
    print("datasigned °°° $dataSignedText");
    List<int> dataSignedList = utf8.encode(dataSignedText);
    dataSigned = Uint8List.fromList(dataSignedList);
  }
  // sauvegarder les données dans le fichier json*/

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp,
        'publicKeyModulusKpJ1': kpJ1.modulus.toString(),
        'publicKeyExponentKpJ1': kpJ1.exponent.toString(),
        'signatureJ1': signatureJ1.toString(),
        'publicKeyModulusKpJ2': kpJ2.modulus.toString(),
        'publicKeyExponentKpJ2': kpJ2.exponent.toString(),
        'signatureJ2': signatureJ2.toString(),
        'publicKeyModulusKpRef': kpRef.modulus.toString(),
        'publicKeyExponentKpRef': kpRef.exponent.toString(),
        'signatureRef': signatureRef.toString(),
        'scoreJ1': scoreJ1,
        'scoreJ2': scoreJ2,
        'scoreRef': scoreRef,
        'dataSigned': dataSigned.toString(),
      };
  @override
  String toString() {
    return "{timestamp:\n\t$timestamp,\nClef public joueur 1:\n\t${kpJ1.hashCode},\nSignature joueur 1:\n\t${signatureJ1.hashCode},\nClef public joueur 2:\n\t${kpJ2.hashCode},\nClef public joueur 2:\n\t${signatureJ2.hashCode}, \nClef public de l'arbitre:\n\t${kpRef.hashCode}, \nSignature de l'arbitre:\n\t${signatureRef.hashCode}, \nScore du joueur 1:\n\t$scoreJ1, \nScore du joueur 2:\n\t$scoreJ2, \nScore de l'arbitre:\n\t$scoreRef}";
  }
}
