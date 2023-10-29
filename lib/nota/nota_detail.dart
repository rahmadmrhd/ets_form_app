import 'dart:io';

import 'package:ets_form_app/componets/image_viewer.dart';
import 'package:ets_form_app/nota/nota_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';

class NotaDetail extends StatelessWidget {
  const NotaDetail({super.key});
  static const routeName = '/detailnota';

  @override
  Widget build(BuildContext context) {
    final Nota nota = ModalRoute.of(context)!.settings.arguments as Nota;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        title: const Text("Detail Nota"),
        actions: [
          IconButton(
            tooltip: "Hapus",
            icon: const Icon(Icons.delete),
            onPressed: () async {
              bool result = await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    // title: const Text('Dialog Title'),
                    content: const Text('Yakin untuk menghapus data ini?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context, false);
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context, true);
                        },
                        child: const Text('Ok'),
                      ),
                    ],
                  );
                },
              );
              // if (!result) return;
              if (!context.mounted) return;

              Navigator.pop(context, result);
            },
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Table(
                  columnWidths: const {
                    0: FlexColumnWidth(2),
                    1: FixedColumnWidth(5),
                    2: FlexColumnWidth(3)
                  },
                  children: nota.toMap().entries.map((e) {
                    return TableRow(children: [
                      Text(e.key),
                      const Text(":"),
                      Text(e.value),
                    ]);
                  }).toList(),
                ),
                const SizedBox(height: 12),
                const Text("File Lampiran"),
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                      border: Border.all(width: 1, color: Colors.grey[500]!),
                      borderRadius: BorderRadius.circular(8)),
                  child: ListView(
                    scrollDirection: Axis.vertical,
                    children: nota.files.map(
                      (item) {
                        return TextButton(
                          style: ButtonStyle(
                            shape: MaterialStatePropertyAll(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0),
                              ),
                            ),
                          ),
                          onPressed: () async {
                            if (kIsWeb) {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return ImageViewer(image: item);
                                },
                              );
                            } else {
                              await OpenFile.open(item.path);
                            }
                          },
                          child: Container(
                            height: 48,
                            padding: const EdgeInsets.all(8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                kIsWeb
                                    ? Image.memory(
                                        item.bytes ?? Uint8List(10),
                                        width: 48,
                                        isAntiAlias: true,
                                      )
                                    : Image.file(
                                        File(item.path ?? ""),
                                        width: 48,
                                        isAntiAlias: true,
                                      ),
                                const SizedBox(width: 10),
                                Expanded(
                                  flex: 5,
                                  child: Text(
                                    item.name,
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
