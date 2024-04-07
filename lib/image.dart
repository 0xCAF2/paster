@JS()
library get_image;

// ignore: depend_on_referenced_packages
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:js/js.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:js_util';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

@JS('getImage')
external _getImage();

Future<String?> getImage() async {
  final promise = _getImage();
  final imageData = await promiseToFuture(promise);
  // convert blob to string
  final reader = html.FileReader();
  reader.readAsArrayBuffer(imageData);
  await reader.onLoad.first;
  final imageString = base64Encode(reader.result as Uint8List);
  return imageString;
}

@JS('setImage')
external _setImage(html.Blob data);

void setImage(String data) {
  final blob = html.Blob([Uint8List.fromList(base64Decode(data))], 'image/png');
  _setImage(blob);
}
