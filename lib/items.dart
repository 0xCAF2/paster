import 'package:paster/item.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'items.g.dart';

const _itemsKey = 'items';

@riverpod
class Items extends _$Items {
  @override
  FutureOr<List<Item>> build() async {
    final prefs = await SharedPreferences.getInstance();
    final items = prefs
            .getStringList(_itemsKey)
            ?.map((content) => Item.content(content))
            .toList() ??
        [];
    return items;
  }

  void add(Item item) {
    final items = state.value!;
    state = AsyncValue.data([...items, item]);
    _save();
  }

  void remove(int index) {
    final items = state.value!;
    state = AsyncValue.data(
        [...items.sublist(0, index), ...items.sublist(index + 1)]);
    _save();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        _itemsKey, state.value!.map((e) => e.rawData).toList());
  }
}
