import 'dart:io';

import 'package:alfred/alfred.dart';
import 'package:alfred/src/type_handlers/websocket_type_handler.dart';

void main() async {
  final app = Alfred();

  app.get('/helloworld', (req, res) => 'Hello world!');

  app.get(
      '/totallynotarickroll',
      (req, res) => res
          .redirect(Uri.parse('https://www.youtube.com/watch?v=dQw4w9WgXcQ')));

  app.get('/ws', (req, res) {
    return WebSocketSession(
      onOpen: (ws) {

      },
      onClose: (ws) {

      },
      onMessage: (ws, dynamic data) async {

      },
    );
  });

  final envPort = Platform.environment['PORT'];

  final server = await app.listen(envPort != null ? int.parse(envPort) : 8080);

  print('Listening on ${server.port}');
}
