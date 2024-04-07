import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:paster/image.dart';
import 'package:paster/item.dart';
import 'package:paster/items.dart';

class Paster extends HookConsumerWidget {
  const Paster({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(itemsProvider);
    final pasteState = useState(false);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Text or PNG images can be pasted here.'),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedButton.icon(
                    onPressed: !pasteState.value
                        ? () async {
                            pasteState.value = true;
                            if (await Clipboard.hasStrings()) {
                              final data =
                                  await Clipboard.getData(Clipboard.kTextPlain);
                              if (data != null && data.text != null) {
                                final item = Item(text: data.text);
                                ref.read(itemsProvider.notifier).add(item);
                              }
                            } else {
                              final data = await getImage();
                              if (data != null) {
                                final item = Item(image: data);
                                ref.read(itemsProvider.notifier).add(item);
                              }
                            }
                            await Future.delayed(const Duration(seconds: 3));
                            pasteState.value = false;
                          }
                        : null,
                    icon: Icon(pasteState.value ? Icons.done : Icons.paste),
                    label: const Text('Paste from clipboard'),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: items.when(
                      data: (data) => ListView(
                        children: [
                          for (var i = 0; i < data.length; ++i)
                            _ItemEntry(item: data[i], index: i),
                        ],
                      ),
                      error: (error, stackTrace) => Center(
                        child: Text('$error'),
                      ),
                      loading: () => const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemEntry extends HookConsumerWidget {
  const _ItemEntry({required this.item, required this.index});

  final Item item;
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final copyState = useState(false);

    return ListTile(
      leading: IconButton(
        icon: Icon(copyState.value ? Icons.done : Icons.copy),
        onPressed: () async {
          copyState.value = true;
          if (item.isImage) {
            setImage(item.content);
          } else {
            await Clipboard.setData(ClipboardData(text: item.content));
          }
          await Future.delayed(const Duration(seconds: 3));
          copyState.value = false;
        },
      ),
      title: item.isImage
          ? Image.memory(base64Decode(item.content))
          : Text(item.content),
      trailing: IconButton(
        icon: const Icon(Icons.highlight_remove),
        onPressed: () {
          ref.read(itemsProvider.notifier).remove(index);
        },
      ),
    );
  }
}
