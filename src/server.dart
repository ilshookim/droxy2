import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:alfred/alfred.dart';
import 'package:alfred/src/type_handlers/websocket_type_handler.dart';

Future<void> main() async {
  // Start listening on this isolate also
  startInstance(_sid());

  // Fire up 5 isolates
  // for (var i = 1; i < 10; i++) {
  //   unawaited(Isolate.spawn(startInstance, '$i'));
  // }
}

/// The start function needs to be top level or static. You probably want to
/// run your entire app in an isolate so you don't run into trouble sharing DB
/// connections etc. However you can engineer this however you like.
///
void startInstance(dynamic sid) async {
  final app = Alfred();
  final Map<WebSocket, dynamic> _connections = Map();

  app.get('/helloworld', (req, res) => 'Hello world!');

  app.get(
      '/totallynotarickroll',
      (req, res) => res
          .redirect(Uri.parse('https://www.youtube.com/watch?v=dQw4w9WgXcQ')));

  app.get('/ws', (req, res) {
    return WebSocketSession(
      onOpen: (ws) async {
        _connections[ws] = sid;
        print('open: connections=${_connections.length}, sid=$sid');
      },
      onMessage: (ws, dynamic data) async {
        final int ts2 = DateTime.now().millisecondsSinceEpoch;
        final Map payload = json.decode(data);
        final String sid = _connections[ws];
        payload['ts2'] = '$ts2';
        payload['sid'] = sid;
        final String cid = payload['cid'];
        final int ts1 = int.tryParse(payload['ts1'])!;
        final int dur = ts2 - ts1;
        print('[message] sid=$sid, dur=$dur ms <- cid=$cid, length=${data.length}');

        // final int ts3 = DateTime.now().millisecondsSinceEpoch;
        // payload['ts3'] = '$ts3';
        // ws.send(json.encode(payload));
     },
      onClose: (ws) async {
        final String sid = _connections[ws];
        _connections.remove(ws);
        print('close: sid=$sid, connections=${_connections.length}');
      },
      onError: (ws, dynamic error) async {
        final String sid = _connections[ws];
        _connections.remove(ws);
        print('error: sid=$sid, connections=${_connections.length}');
      },
    );
  });

  final envPort = Platform.environment['PORT'];
  final server = await app.listen(envPort != null ? int.parse(envPort) : 9451);

  print('Listening on ${server.port} for $sid');
}

/// Simple function to prevent linting errors, can be ignored
void unawaited(Future future) {}

String _sid({bool epoch = true}) {
  final DateTime now = DateTime.now();
  if (epoch) return '${now.microsecondsSinceEpoch}';
  return now.toIso8601String();
}
