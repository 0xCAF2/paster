import 'dart:async';
import 'dart:convert';

import 'dart:js_interop';

import 'package:web/web.dart';

@JS('getImage')
external JSPromise<Blob> _getImage();

Future<String?> getImage() async {
  final promise = _getImage();
  final imageData = await promise.toDart;
  final reader = FileReader();
  final result = Completer<String?>();
  void handler(JSObject _) {
    final data = reader.result as JSArrayBuffer;
    final bytes = data.toDart.asUint8List();
    result.complete(base64Encode(bytes));
  }

  reader.onload = handler.toJS;
  reader.readAsArrayBuffer(imageData);
  return await result.future;
}

@JS('setImage')
external JSPromise _setImage(Blob data);

Future<void> setImage(String data) async {
  final bytes = base64Decode(data);
  final blob = Blob(
      [bytes].jsify() as JSArray<BlobPart>, BlobPropertyBag(type: 'image/png'));
  final promise = _setImage(blob);
  await promise.toDart;
}
