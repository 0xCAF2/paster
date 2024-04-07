class Item {
  Item({String? text, String? image})
      : assert(text != null || image != null),
        _content = text != null ? 'text:$text' : 'image:$image';

  Item.content(this._content);

  final String _content;

  String get content => _content.startsWith('text:')
      ? _content.substring(5)
      : _content.substring(6);

  bool get isImage => _content.startsWith('image:');

  String get rawData => _content;
}
