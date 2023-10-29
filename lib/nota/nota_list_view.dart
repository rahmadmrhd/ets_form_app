import 'package:ets_form_app/nota/nota_detail.dart';
import 'package:ets_form_app/nota/nota_form.dart';
import 'package:ets_form_app/nota/nota_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotaHomePage extends StatefulWidget {
  const NotaHomePage({super.key});

  static const routeName = '/';

  @override
  State<NotaHomePage> createState() => _NotaHomePageState();
}

class _NotaHomePageState extends State<NotaHomePage> {
  final Map<Nota, bool> _notas = {
    Nota(
        nomorNota: "N001",
        namaPembeli: "Rahmad",
        jenis: "Biasa",
        tanggal: DateTime.now(),
        jumlah: 10000,
        diskon: 200,
        hariLibur: true,
        saudara: true,
        jenisBarang: {"AAA": true},
        ppn: 0.1,
        grandTotal: 2640,
        uangDibayar: 10000,
        files: {}): false,
    Nota(
        nomorNota: "N002",
        namaPembeli: "Maulana",
        jenis: "Biasa",
        tanggal: DateTime.now(),
        jumlah: 20000,
        diskon: 800,
        hariLibur: true,
        saudara: true,
        jenisBarang: {"AAA": true},
        ppn: 0,
        grandTotal: 11800,
        uangDibayar: 15000,
        files: {}): false,
  };

  Future<bool?> confirmDelete() async {
    return showDialog(
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
  }

  bool selectMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        title: Text(!selectMode
            ? "Daftar Nota"
            : '${_notas.entries.where((e) => e.value == true).length} item dipilih'),
        leading: !selectMode
            ? null
            : IconButton(
                tooltip: "Batal",
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    for (var nota in _notas.entries) {
                      _notas[nota.key] = false;
                    }
                    selectMode = false;
                  });
                },
              ),
        actions: !selectMode
            ? null
            : [
                ButtonBar(
                  children: [
                    IconButton(
                      tooltip: "Pilih Semua",
                      icon: const Icon(Icons.select_all),
                      onPressed: () {
                        setState(() {
                          for (var nota in _notas.entries) {
                            _notas[nota.key] = true;
                          }
                        });
                      },
                    ),
                    IconButton(
                      tooltip: "Hapus",
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        var result = await confirmDelete();
                        if (!(result ?? false)) return;
                        var keysToRemove = <Nota>[];
                        for (var nota in _notas.entries) {
                          if (_notas[nota.key] ?? false) {
                            keysToRemove.add(nota.key);
                          }
                        }
                        setState(() {
                          for (var key in keysToRemove) {
                            _notas.remove(key);
                          }
                          selectMode = false;
                        });
                      },
                    )
                  ],
                )
              ],
      ),
      floatingActionButton: selectMode
          ? null
          : FloatingActionButton(
              onPressed: () async {
                final result =
                    await Navigator.pushNamed(context, NotaForm.routeName);
                if (result == null) return;
                setState(() {
                  _notas.addEntries({(result as Nota): false}.entries);
                });

                if (!mounted) return;
                ScaffoldMessenger.of(context)
                  ..removeCurrentSnackBar()
                  ..showSnackBar(SnackBar(
                      content: Text(
                          "Berhasil menyimpan ${(result as Nota).nomorNota}")));
              },
              child: const Icon(Icons.add),
            ),
      body: ListView(
        scrollDirection: Axis.vertical,
        children: _notas.entries.map((item) {
          return Dismissible(
            key: Key(item.key.nomorNota),
            direction: DismissDirection.startToEnd,
            background: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8),
              color: Colors.red,
              child: const Row(
                children: [
                  Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                  SizedBox(width: 10),
                  Text(
                    "Hapus",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
            ),
            confirmDismiss: (direction) async {
              return await confirmDelete();
            },
            onDismissed: (direction) {
              setState(() {
                _notas.remove(item.key);
              });
            },
            child: ListTile(
              selected: item.value,
              selectedTileColor: Colors.grey[300],
              title: Text('${item.key.nomorNota} - ${item.key.namaPembeli}'),
              subtitle: Text(DateFormat("dd-MM-yyyy").format(item.key.tanggal)),
              onTap: () async {
                if (!selectMode) {
                  var result = await Navigator.pushNamed(
                      context, NotaDetail.routeName,
                      arguments: item.key);
                  if (result != true) return;
                  setState(() {
                    _notas.remove(item.key);
                  });
                  return;
                }
                setState(() {
                  if (selectMode) {
                    _notas[item.key] = !_notas[item.key]!;
                  }
                });
                setState(() {
                  if (_notas.entries.where((e) => e.value == true).isEmpty) {
                    selectMode = false;
                  }
                });
              },
              onLongPress: () {
                setState(() {
                  selectMode = true;
                  _notas[item.key] = true;
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}
