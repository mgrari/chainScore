import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pointycastle/export.dart' as crypto;
import 'package:projet_blockchain/DatabaseHandler/db_helper.dart';
import 'package:projet_blockchain/Model/blockchain.dart';
import 'package:projet_blockchain/Model/entry.dart';
import 'package:projet_blockchain/Model/user.dart';
import 'package:projet_blockchain/Screens/login.dart';
import 'package:provider/provider.dart';

import '../Common/socket_service.dart';
import '../Common/terminal_service.dart';
import '../Model/rsa_generation_and_verification.dart';

class MainPage extends StatelessWidget {
  final Socket socket;
  User? myUser;
  MainPage(User? userData, this.socket, {super.key}) {
    myUser = userData;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      //the state is created here and provided to the all app using ChangeNotifierProvider
      create: (context) => MyAppState(myUser!, socket),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Blockchain',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  final Socket socket;
  User myUser;
  String messageReceive = "en attente";

  MyAppState(this.myUser, this.socket) {
    print('Connected to: ${socket.remoteAddress.address}:${socket.remotePort}');
    print("pseudo : ${myUser.getPseudo}");
    print("password : ${myUser.getMdp}");
    initUser();
    listenSocket();
  }
  var invitation = [];

  initUser() {
    Blockchain myCurrentBlockChain =
        getBlockchain(); // en attendant que l'app soit connectée
    myUser.setBlockChain(myCurrentBlockChain);
  }

  Entry _createEntry(String messageReceive) {
    print(messageReceive);
    var e = json.decode(messageReceive);
    Entry newEntry = Entry.fromJson(e);
    return newEntry;
  }

  listenSocket() {
    print("----------------dans le listener--------------");
    sendMessageToServer(socket, MapEntry(SocketAction.login, myUser.getPseudo));

    socket.listen(
      (Uint8List data) {
        final serverResponse = String.fromCharCodes(data);
        var parsedCommand = parseCommand(serverResponse);

        switch (parsedCommand.key) {
          case SocketAction.successMessage:
            printGreen(parsedCommand.value.toString());
            break;

          case SocketAction.invitation:
            print("recu message");
            printRed(parsedCommand.value.toString());
            messageReceive = parsedCommand.value.toString();
            notifyListeners();
            break;
          case SocketAction.newEntry:
            print("recu entrée");
            var e = _createEntry(parsedCommand.value.toString());
            myUser.addEntry(e);
            notifyListeners();
            break;
          default:
        }
      },

      // handle errors
      onError: (error) {
        print(error);
        socket.destroy();
      },

      // handle server ending connection
      onDone: () {
        print('Server left.');
        socket.destroy();
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0; // only want to track this property

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = const GeneratorPage();
        break;
      case 1:
        page =
            const MyBlockchainPage(); //a handy widget that draws a crossed rectangle wherever you place it, marking that part of the UI as unfinished.
        break;
      case 2:
        page = const Placeholder();
        break;
      case 3:
        page = const InvitationPage();
        break;
      case 4:
        page = const NotificationCenter();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                extended: constraints.maxWidth >=
                    600, //make it automatically show the labels (using extended: true) when there's enough room for them.
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.link),
                    label: Text('MyBlockChain'),
                  ),
                  NavigationRailDestination(
                      icon: Icon(Icons.leaderboard),
                      label: Text("Leaderboard")),
                  NavigationRailDestination(
                      icon: Icon(Icons.insert_invitation),
                      label: Text("Invitation")),
                  NavigationRailDestination(
                      icon: Icon(Icons.notifications),
                      label: Text("Mes Notification,")),
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: (value) {
                  setState(() {
                    selectedIndex = value;
                  });
                },
              ),
            ),
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child:
                    page, // it will call the right page according to selectedIndex
              ),
            ),
          ],
        ),
      );
    });
  }
}

class NotificationCenter extends StatelessWidget {
  const NotificationCenter({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.invitation.isEmpty) {
      return const Center(
        child: Text("Pas de notification."),
      );
    }
    return Column();
  }
}

class InvitationPage extends StatefulWidget {
  const InvitationPage({super.key});

  @override
  State<InvitationPage> createState() => _InvitationPageState();
}

class _InvitationPageState extends State<InvitationPage> {
  bool isChecked = false;
  final DbHelper _dbHelper = DbHelper.instance;
  List<String>? username;
  @override
  void initState() {
    super.initState();
  }

  void log() async {
    username = await _dbHelper.getUsername();
  }

  var invi = ["ammar", "achraf", "ismael"];

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    log(); // TODO vraiment besoin de mettre ça dans le builder ???

    List<bool>? list = List.filled(100, false);

    return Column(
      children: [
        const SizedBox(
          height: 50,
        ),
        const Text(
          "Mes Invitations",
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
        ),
        Expanded(
          child: ListView(
            scrollDirection: Axis.vertical,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text('Vous avez ${invi.length} invitations de:'),
              ),
              for (var inv in invi)
                ElevatedButton(
                  style: null,
                  onPressed: () {},
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(inv),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () {
                          //code that
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => LoginForm(appState
                                      .socket)), // changer par le model invi
                              (Route<dynamic> route) => false);
                        },
                        child: const Icon(Icons.check, color: Colors.green),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            invi.remove(inv);
                          });
                        },
                        child: const Icon(Icons.close, color: Colors.red),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                  onPressed: () {
                    _dialogInviBuilder(context, username, list);
                  },
                  child: const Icon(Icons.add)),
              const SizedBox(
                width: 20,
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }

  Future<void> _dialogInviBuilder(
      BuildContext context, var invitation, var list) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            scrollable: true,
            title: const Text("Veuillez selectionner 2 joueurs"),
            content: Container(
              height: 200,
              width: 200,
              child: ListView.builder(
                  itemCount: invitation.length,
                  itemBuilder: (BuildContext context, int index) {
                    bool? isChecked = true;
                    return ListTile(
                      title: Text('${invitation[index]}'),
                      trailing: Checkbox(
                          value: list[index],
                          onChanged: (bool? value) {
                            setState(() {
                              list[index] = value ?? false;
                            });
                          }),
                    );
                  }),
            ),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                child: const Text('Confirmer'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
      },
    );
  }
}

getBlockchain() {
  Blockchain myBlockChain = Blockchain([]);

  var keyPair1 = generateRSAkeyPair(exampleSecureRandom()); // user 1

  var keyPair2 = generateRSAkeyPair(exampleSecureRandom()); // user 2

  var keyPair3 = generateRSAkeyPair(exampleSecureRandom()); // user 2

  var mod = keyPair1.privateKey.modulus;
  var pExpo = keyPair1.privateKey.privateExponent;
  var p = keyPair1.privateKey.p;
  var q = keyPair1.privateKey.q;

  crypto.RSAPrivateKey cpKP1 = crypto.RSAPrivateKey(mod!, pExpo!, p, q);

  List<int> d1 = utf8.encode("Signer la partie 1.");
  Uint8List dataToSign1 = d1 as Uint8List;
  var s1_1 = rsaSign(cpKP1, dataToSign1);
  var s2_1 = rsaSign(keyPair2.privateKey, dataToSign1);
  var s3_1 = rsaSign(keyPair3.privateKey, dataToSign1);

  print(dataToSign1.toString());

  var cpSigna1_1 = s1_1;

  List<int> d2 = utf8.encode("Signer la partie 2.");
  Uint8List dataToSign2 = d2 as Uint8List;
  var s1_2 = rsaSign(cpKP1, dataToSign2);
  var s2_2 = rsaSign(keyPair2.privateKey, dataToSign2);
  var s3_2 = rsaSign(keyPair3.privateKey, dataToSign2);

  List<int> d3 = utf8.encode("Signer la partie 3.");
  Uint8List dataToSign3 = d3 as Uint8List;
  var s1_3 = rsaSign(cpKP1, dataToSign3);
  var s2_3 = rsaSign(keyPair2.privateKey, dataToSign3);
  var s3_3 = rsaSign(keyPair3.privateKey, dataToSign3);

  Entry e1 = Entry(
      timestamp: 1,
      kpJ1: keyPair1.publicKey,
      kpJ2: keyPair2.publicKey,
      kpRef: keyPair3.publicKey,
      scoreJ1: 1,
      scoreJ2: 1,
      scoreRef: 0,
      signatureJ1: cpSigna1_1,
      signatureJ2: s2_1,
      signatureRef: s3_1,
      dataSigned: dataToSign1);

  Entry e2 = Entry(
      timestamp: 2,
      kpJ1: keyPair2.publicKey,
      kpJ2: keyPair3.publicKey,
      kpRef: keyPair1.publicKey,
      scoreJ1: 3,
      scoreJ2: 2,
      scoreRef: 12,
      signatureJ1: s2_2,
      signatureJ2: s3_2,
      signatureRef: s1_2,
      dataSigned: dataToSign2);

  BigInt? modulus = keyPair1.publicKey.modulus;
  BigInt? exponent = keyPair1.publicKey.exponent;
  crypto.RSAPublicKey copyKeyPair1 = crypto.RSAPublicKey(modulus!, exponent!);

  Entry e3 = Entry(
      timestamp: 3,
      kpJ1: copyKeyPair1,
      kpJ2: keyPair3.publicKey,
      kpRef: keyPair2.publicKey,
      scoreJ1: 3,
      scoreJ2: 6,
      scoreRef: 17,
      signatureJ1: s1_3,
      signatureJ2: s3_3,
      signatureRef: s2_3,
      dataSigned: dataToSign3);

  myBlockChain.addEntry(e1);
  myBlockChain.addEntry(e2);
  myBlockChain.addEntry(e3);

  return myBlockChain;
}

class MyBlockchainPage extends StatefulWidget {
  const MyBlockchainPage({super.key});

  @override
  State<MyBlockchainPage> createState() => _MyBlockchainPageState();
}

class _MyBlockchainPageState extends State<MyBlockchainPage> {
  Future<void> _dialogBuilder(BuildContext context, Entry block) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          scrollable: true,
          title: Text('Block n°${block.getTimestamp}'),
          content: Text(block.toString()),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _dialogEntryBuilder(
      BuildContext context, MyAppState appState) async {
    TextEditingController textEditingController1 = TextEditingController();
    TextEditingController textEditingController2 = TextEditingController();
    TextEditingController textEditingController3 = TextEditingController();
    TextEditingController textEditingController4 = TextEditingController();
    bool? outcomePlayer1 = false;
    bool? outcomePlayer2 = false;

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          scrollable: true,
          title: const Text('Créer une nouvelle entrée'),
          content: Column(
            children: [
              TextField(
                decoration: const InputDecoration(hintText: "Joueur 1"),
                controller: textEditingController1,
              ),
              TextField(
                decoration: const InputDecoration(hintText: "Joueur 2"),
                controller: textEditingController2,
              ),
              TextField(
                decoration: const InputDecoration(hintText: "Score Joueur 1"),
                controller: textEditingController3,
              ),
              TextField(
                decoration: const InputDecoration(hintText: "Score Joueur 2"),
                controller: textEditingController4,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Victoire Joueur 1'),
              onPressed: () {
                setState(() {
                  Entry e = createEntry(
                      textEditingController1.text,
                      textEditingController2.text,
                      appState.myUser.myBlockChain.getScore,
                      textEditingController3.text,
                      textEditingController4.text);
                  appState.myUser.addEntry(e);
                  String jsonText = jsonEncode(e);
                  sendEntryObject(appState.socket,
                      MapEntry(SocketAction.newEntry, jsonText));
                });

                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Victoire Joueur 2'),
              onPressed: () {
                setState(() {
                  Entry e = createEntry(
                      textEditingController1.text,
                      textEditingController2.text,
                      appState.myUser.myBlockChain.getScore,
                      textEditingController3.text,
                      textEditingController4.text);
                  appState.myUser.addEntry(e);
                  String jsonText = jsonEncode(e);
                  sendEntryObject(appState.socket,
                      MapEntry(SocketAction.newEntry, jsonText));
                });

                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Egalité'),
              onPressed: () {
                setState(() {
                  Entry e = createEntry(
                      textEditingController1.text,
                      textEditingController2.text,
                      appState.myUser.myBlockChain.getScore,
                      textEditingController3.text,
                      textEditingController4.text);
                  appState.myUser.addEntry(e);
                  String jsonText = jsonEncode(e);
                  sendEntryObject(appState.socket,
                      MapEntry(SocketAction.newEntry, jsonText));
                });

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    final ButtonStyle style = ElevatedButton.styleFrom(
        textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700));

    return Column(
      children: [
        const SizedBox(
          height: 50,
        ),
        const Text(
          "Mes Blocs",
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
        ),
        Expanded(
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text('Vous avez '
                    '${appState.myUser.myBlockChain.getScore} bloc(s):'),
              ),
              for (var block in appState.myUser.myBlockChain.getListEntries)
                ElevatedButton.icon(
                  icon: const Icon(Icons.crop_din),
                  style: style,
                  onPressed: () {
                    _dialogBuilder(context, block);
                  },
                  label: Text("Bloc n°${block.getTimestamp}"),
                )
            ],
          ),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                  onPressed: () {
                    _dialogEntryBuilder(context, appState);
                  },
                  child: const Icon(Icons.add)),
              const SizedBox(
                width: 20,
              )
            ],
          ),
        ),
        const SizedBox(
          height: 20,
        )
      ],
    );
  }
}

Entry createEntry(
    String pseudo1, String pseudo2, int length, String score1, String score2) {
  User user1 = User(pseudo: pseudo1, password: "mdp");
  User user2 = User(pseudo: pseudo2, password: "mdp");
  var keyPair3 = generateRSAkeyPair(exampleSecureRandom()); // user 2

  List<int> d1 = utf8.encode("Signer la partie 2.");
  Uint8List dataToSign1 = d1 as Uint8List;
  print("dataSigned ### $dataToSign1");
  var s1_1 = rsaSign(user1.getPrivateKey, dataToSign1);
  var s2_1 = rsaSign(user2.getPrivateKey, dataToSign1);
  var s3_1 = rsaSign(keyPair3.privateKey, dataToSign1);

  Entry e1 = Entry(
      timestamp: length + 1,
      kpJ1: user1.getPublicKey,
      kpJ2: user2.getPublicKey,
      kpRef: keyPair3.publicKey,
      scoreJ1: score1,
      scoreJ2: score2,
      scoreRef: 0,
      signatureJ1: s1_1,
      signatureJ2: s2_1,
      signatureRef: s3_1,
      dataSigned: dataToSign1);
  return e1;
}

class GeneratorPage extends StatefulWidget {
  const GeneratorPage({super.key});

  @override
  State<GeneratorPage> createState() => _GeneratorPageState();
}

class _GeneratorPageState extends State<GeneratorPage> {
  TextEditingController messageToSend = TextEditingController();
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "MyBlockchain",
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
          ),
          Image.asset(
            "assets/blockchain.png",
            height: 100.0,
            width: 100.0,
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Score :",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
              ),
              Card(
                color: theme.colorScheme.primary,
                child: Padding(
                  padding: const EdgeInsets.all(1),
                  child: Text(
                    appState.myUser.myBlockChain.getScore.toString(),
                    style: TextStyle(color: theme.colorScheme.onPrimary),
                  ),
                ),
              )
            ],
          ),
          const SizedBox(
            height: 50,
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 50,
                width: 100,
                child: TextField(
                  decoration: const InputDecoration(hintText: "message"),
                  controller: messageToSend,
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              ElevatedButton(
                onPressed: () {
                  sendMessage(context, appState);
                  messageToSend.clear();
                },
                child: const Icon(Icons.add),
              )
            ],
          ),
          const SizedBox(
            height: 50,
          ),
          Text(appState.messageReceive),
        ],
      ),
    );
  }

  sendMessage(BuildContext context, MyAppState appState) {
    if (messageToSend.text.isNotEmpty) {
      sendMessageToServer(appState.socket,
          MapEntry(SocketAction.invitation, messageToSend.text));
    }
  }
}
