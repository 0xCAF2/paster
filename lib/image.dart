@JS()
library image;

import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

import 'dart:typed_data';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

@JS('getImage')
external JSPromise<web.Blob> _getImage();

Future<String?> getImage() async {
  final promise = _getImage();
  final imageData = await promise.toDart;
  final reader = web.FileReader();
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

@JS('Blob')
extension type Blob._(JSObject _) implements JSObject {
  external factory Blob(JSArray<JSArrayBuffer> blobParts, JSObject? options);

  factory Blob.fromBytes(List<int> bytes) {
    final data = Uint8List.fromList(bytes).buffer.toJS;
    final options = {'type': 'image/png'}.jsify() as JSObject;
    return Blob([data].toJS, options);
  }

  external JSArrayBuffer? get blobParts;
  external JSObject? get options;
}

@JS('setImage')
external JSPromise _setImage(Blob data);

Future<void> setImage(String data) async {
  final blob = Blob.fromBytes(base64Decode(data));
  final dynamic promise = _setImage(blob);
  await promise.toDart;
}
