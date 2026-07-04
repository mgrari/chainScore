import 'dart:io';
import 'dart:typed_data';

import 'server_models/player.dart';
import 'socket_service.dart';
import 'terminal_service.dart';

Future<void> main() async {
  final ip = InternetAddress.anyIPv4;
  final server = await ServerSocket.bind(ip, 3000);
  print("Server is running on: ${ip.address}:3000");
  server.listen((Socket event) {
    handleConnection(event);
  });
}

List<Player> players = [];

void handleConnection(Socket client) {
  printGreen(
    "Connection from ${client.remoteAddress.address}:${client.remotePort}",
  );

  client.listen(
    (Uint8List data) async {
      final message = String.fromCharCodes(data);
      print("data received...");
      SocketCommand command = parseCommand(message);
      print(command);

      switch (command.key) {
        case SocketAction.login:
          print("message send");
          for (var player in players) {
            player.socket.write(SocketCommand(SocketAction.successMessage,
                "${command.value} joined the game"));
          }
          players
              .add(Player(socket: client, username: command.value.toString()));

          client.write(
            SocketCommand(SocketAction.successMessage,
                "You are logged in as: ${command.value}"),
          );
          break;
        case SocketAction.invitation:
          print("message ${command.value} send");
          for (var player in players) {
            if (player.socket != client) {
              player.socket.write(
                  SocketCommand(SocketAction.invitation, "${command.value}"));
            }
          }
          break;
        case SocketAction.newEntry:
          //print("entry ${command.value} receive");
          for (var player in players) {
            if (player.socket != client) {
              player.socket.write(
                  SocketCommand(SocketAction.newEntry, "${command.value}"));
            }
          }
          break;
        default:
      }
    }, // handle errors
    onError: (error) {
      print(error);
      client.close();
      players.removeWhere(((element) => element.socket == client));
    },

    // handle the client closing the connection
    onDone: () {
      printRed('Client left');
      client.close();
      players.removeWhere(((element) => element.socket == client));
    },
  );
}
