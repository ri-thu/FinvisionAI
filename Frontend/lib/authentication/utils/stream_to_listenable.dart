import 'dart:async';
import 'package:flutter/foundation.dart';

class StreamToListenable extends ChangeNotifier {
  late final List<StreamSubscription> subscriptions;

  StreamToListenable(List<Stream> streams) {
    subscriptions =
        streams.map((stream) {
          return stream.asBroadcastStream().listen(
            (event) => notifyListeners(),
          );
        }).toList();
  }

  @override
  void dispose() {
    for (var sub in subscriptions) {
      sub.cancel();
    }
    super.dispose();
  }
}
