import 'dart:io';

void main() async {
  print('Connecting to Websocket...');
  final socket = await WebSocket.connect('wss://stream.binance.us:9443/ws/btcusdt@trade');
  print('Connected! Waiting for events...');
  
  socket.listen((event) {
    print('Received: $event');
    socket.close();
  });
}
