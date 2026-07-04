import 'dart:io';

enum SocketAction { login, successMessage, invitation, newEntry, unknown }

SocketAction parseStringToSocketAction(String value) {
  switch (value) {
    case "SocketAction.login":
      return SocketAction.login;
    case "SocketAction.successMessage":
      return SocketAction.successMessage;
    case "SocketAction.invitation":
      return SocketAction.invitation;
    case "SocketAction.newEntry":
      return SocketAction.newEntry;
    default:
      return SocketAction.unknown;
  }
}

typedef SocketCommand = MapEntry<SocketAction, Object>;
typedef LoginCommand = MapEntry<SocketAction, String>;

void sendMessageToServer(Socket socket, SocketCommand message) {
  // print("Client: ${message.key} - ${message.value}");
  socket.write(message);
}

SocketCommand parseCommand(String message) {
  print("-------------dans le parser---------------");
  print(message);
  var idx = message.indexOf(":");
  var end = message.indexOf(")");

  List splittedMessage = [
    message.substring(9, idx).trim(),
    message.substring(idx + 1, end).trim(),
  ];
  print(splittedMessage);
  print("------------------------------------------");

  print(splittedMessage);

  return SocketCommand(
    parseStringToSocketAction(splittedMessage.first),
    splittedMessage.last,
  );
}
