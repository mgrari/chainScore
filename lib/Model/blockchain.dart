import 'entry.dart';
import 'rsa_generation_and_verification.dart';

class Blockchain {
  List<Entry> listEntries = <Entry>[];
  List<Entry> get getListEntries => listEntries;
  int get scoreBlockchain => listEntries.length;

  int score = 0;
  int get getScore => score;

  Blockchain(this.listEntries);

  void addEntry(Entry newEntry) {
    // if (validation(newEntry)) {
    listEntries.add(newEntry);
    score += 1;
    //print("lol here");
    //} else {
    //print("entrée ajoutée");
    //}
  }

  bool validation(Entry newEntry) {
    var isValid = rsaVerify(
        newEntry.getKpj1, newEntry.getDataSigned, newEntry.getSignatureJ1);
    isValid = rsaVerify(
        newEntry.getKpj2, newEntry.getDataSigned, newEntry.getSignatureJ2);
    isValid = rsaVerify(
        newEntry.getKpRef, newEntry.getDataSigned, newEntry.getSignatureRef);
    return isValid;
  }

  @override
  String toString() {
    String res = "";
    var index = 1;
    for (var entry in listEntries) {
      res += "Entrée $index :\n";
      res += "$entry\n";
      index += 1;
    }
    return res;
  }
}