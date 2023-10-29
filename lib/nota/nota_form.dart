// ignore_for_file: prefer_final_fields
import 'dart:io';
import 'dart:math';

import 'package:ets_form_app/componets/image_viewer.dart';
import 'package:ets_form_app/formatter/currency_formatter.dart';
import 'package:ets_form_app/formatter/percent_formatter.dart';
import 'package:ets_form_app/nota/nota_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:open_file/open_file.dart';

class NotaForm extends StatefulWidget {
  const NotaForm({super.key});
  static const routeName = '/addnota';

  @override
  State<NotaForm> createState() => _NotaFormState();
}

class _NotaFormState extends State<NotaForm> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _noNotaController = TextEditingController(
      text: 'N${NumberFormat("000").format(Random().nextInt(1000))}');
  TextEditingController _namaController = TextEditingController();
  TextEditingController _tanggalController = TextEditingController();
  TextEditingController _jumlahController = TextEditingController();
  TextEditingController _diskonController = TextEditingController();
  TextEditingController _ppnController = TextEditingController();
  TextEditingController _grandTotalController = TextEditingController();
  TextEditingController _uangBayarController = TextEditingController();
  TextEditingController _uangKembalianController = TextEditingController();
  DateTime? _tanggal;
  String? _jenisPembeli;
  bool _hariLibur = false;
  bool _saudara = false;
  Map<String, bool> _jenisBarang = Map<String, bool>.fromIterables(
      jenisBarangOptions.entries.map((e) => e.key),
      List<bool>.filled(jenisBarangOptions.length, false));
  Set<ImageFile> _files = {};

  Future<void> openFilePicker() async {
    // MOBILE
    if (!kIsWeb) {
      bool? isCamera = await showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 140,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              color: Colors.white,
            ),
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.only(top: 18, bottom: 18),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                // alignment: MainAxisAlignment.center,
                children: [
                  // const Text('Modal BottomSheet'),
                  TextButton(
                    style: ButtonStyle(
                      shape: MaterialStatePropertyAll(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0),
                        ),
                      ),
                      textStyle: const MaterialStatePropertyAll<TextStyle>(
                        TextStyle(
                          color: Colors.black87,
                          fontSize: 18,
                        ),
                      ),
                      foregroundColor:
                          const MaterialStatePropertyAll(Colors.black87),
                    ),
                    onPressed: () => Navigator.pop(context, true),
                    child: Container(
                      height: 36,
                      alignment: Alignment.center,
                      width: double.infinity,
                      child: const Text("Kamera"),
                    ),
                  ),
                  TextButton(
                    style: ButtonStyle(
                      shape: MaterialStatePropertyAll(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0),
                        ),
                      ),
                      textStyle: const MaterialStatePropertyAll<TextStyle>(
                        TextStyle(
                          color: Colors.black87,
                          fontSize: 18,
                        ),
                      ),
                      foregroundColor:
                          const MaterialStatePropertyAll(Colors.black87),
                    ),
                    onPressed: () => Navigator.pop(context, false),
                    child: Container(
                      height: 36,
                      alignment: Alignment.center,
                      width: double.infinity,
                      child: const Text("Galeri"),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
      if (isCamera == null) return;

      if (isCamera) {
        final ImagePicker picker = ImagePicker();
        var image = await picker.pickImage(source: ImageSource.camera);
        if (image == null) return;
        setState(() {
          _files.add(ImageFile(
            name: image.name,
            path: image.path,
          ));
        });
      } else {
        FilePickerResult? photo = await FilePicker.platform.pickFiles(
            dialogTitle: 'Pilih Foto',
            type: FileType.image,
            allowMultiple: true);

        if (photo != null) {
          setState(() {
            for (var img in photo.files) {
              final image = ImageFile(
                name: img.name,
                path: img.path,
              );
              _files.add(image);
            }
          });
        }
      }
    } else if (kIsWeb) {
      final ImagePicker picker = ImagePicker();
      var images = await picker.pickMultiImage();
      Set<ImageFile> imageFiles = {};
      for (var img in images) {
        final image = ImageFile(
          name: img.name,
        );
        image.bytes = await img.readAsBytes();
        imageFiles.add(image);
      }
      setState(() {
        _files = {..._files, ...imageFiles};
      });
    } else {
      showToast("Permission not granted");
    }
  }

  void showToast(String message) {
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void removeFile(ImageFile file) {
    setState(() {
      _files.remove(file);
    });
  }

  void resetAll() {
    _noNotaController.clear();
    _namaController.clear();
    _tanggalController.clear();
    _jumlahController.clear();
    _diskonController.clear();
    _ppnController.clear();
    _grandTotalController.clear();
    _uangBayarController.clear();
    _uangKembalianController.clear();
    setState(() {
      _files.clear();
      _jenisPembeli = null;
      _jenisBarang.forEach((key, value) {
        _jenisBarang[key] = false;
      });
      _hariLibur = false;
      _saudara = false;
    });
    _formKey.currentState?.reset();
  }

  void save() {
    if (_formKey.currentState!.validate()) {
      Nota result = Nota(
        nomorNota: _noNotaController.text,
        namaPembeli: _namaController.text,
        jenis: _jenisPembeli ?? '',
        tanggal: _tanggal!,
        jumlah: CurrencyFormatter.toDouble(_jumlahController.text),
        diskon: CurrencyFormatter.toDouble(_diskonController.text),
        hariLibur: _hariLibur,
        saudara: _saudara,
        jenisBarang: _jenisBarang,
        ppn: (double.tryParse(_ppnController.text
                    .replaceAll(RegExp(r'%|\.'), '')
                    .replaceAll(RegExp(r','), '.')) ??
                0) /
            100,
        grandTotal: CurrencyFormatter.toDouble(_grandTotalController.text),
        uangDibayar: CurrencyFormatter.toDouble(_uangBayarController.text),
        files: _files,
      );
      Navigator.pop(context, result);
    }
  }

  String? validatorNotEmpty(String? value, String label) {
    if (value == null || value.isEmpty) {
      return '$label tidak boleh kosong';
    }
    return null;
  }

  String? validatorNumber(String? value) {
    if (value == null || value.isEmpty) null;
    RegExp numRgx = RegExp(r'^(\d+(?:\.\d+)?|\.\d+)$');
    return numRgx.hasMatch(value ?? "") ? null : "Format penulisan salah";
  }

  void _hariLiburChanged(bool? value) {
    setState(() {
      _hariLibur = value ?? false;
    });
    reCalculate();
  }

  void _saudaraChanged(bool? value) {
    setState(() {
      _saudara = value ?? false;
    });
    reCalculate();
  }

  double reCalculate() {
    double total = CurrencyFormatter.toDouble(_jumlahController.text);
    double diskon = total * (jenisPembeliOptions[_jenisPembeli] ?? 0);
    _diskonController.text = CurrencyFormatter.format(
        total * (jenisPembeliOptions[_jenisPembeli] ?? 0));
    double ppn = (double.tryParse(_ppnController.text
                .replaceAll(RegExp(r'%|\.'), '')
                .replaceAll(RegExp(r','), '.')) ??
            0) /
        100;
    double kembalian = 0;
    if (total > 0) {
      total -= diskon;
      total -= _hariLibur ? 2500 : 0;
      total += _saudara ? -5000 : 3000;
      _jenisBarang.forEach((key, value) {
        if (!value) return;
        total += jenisBarangOptions[key] ?? 0;
      });
      total += total * ppn;
      kembalian = CurrencyFormatter.toDouble(_uangBayarController.text,
              defaultValue: total) -
          total;
    }
    _grandTotalController.text =
        NumberFormat.currency(symbol: 'Rp ', decimalDigits: 2, locale: 'id')
            .format(total);
    _uangKembalianController.text =
        NumberFormat.currency(symbol: 'Rp ', decimalDigits: 2, locale: 'id')
            .format(kembalian < 0 ? 0 : kembalian);
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        title: const Text("Form Nota"),
        actions: [
          TextButton(
            style: ButtonStyle(
                textStyle: MaterialStatePropertyAll<TextStyle>(
                  TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 18,
                  ),
                ),
                foregroundColor: MaterialStatePropertyAll(
                    Theme.of(context).colorScheme.onPrimary)),
            onPressed: resetAll,
            child: const Text("Reset"),
          ),
          TextButton(
            style: ButtonStyle(
                textStyle: MaterialStatePropertyAll<TextStyle>(
                  TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 18,
                  ),
                ),
                foregroundColor: MaterialStatePropertyAll(
                    Theme.of(context).colorScheme.onPrimary)),
            onPressed: save,
            child: const Text("Simpan"),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    textInputAction: TextInputAction.next,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    autofocus: true,
                    decoration: const InputDecoration(labelText: 'No Nota'),
                    controller: _noNotaController,
                    validator: (value) => validatorNotEmpty(value, "No Nota"),
                  ),
                  TextFormField(
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.name,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    autofocus: true,
                    decoration:
                        const InputDecoration(labelText: 'Nama Pembeli'),
                    controller: _namaController,
                    validator: (value) =>
                        validatorNotEmpty(value, "Nama Pembeli"),
                  ),
                  DropdownButtonFormField(
                    decoration: const InputDecoration(labelText: 'Jenis'),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    items: jenisPembeliOptions.entries.map((item) {
                      return DropdownMenuItem(
                        value: item.key,
                        child: Text(item.key),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _jenisPembeli = value;
                      });
                      reCalculate();
                    },
                    validator: (value) => validatorNotEmpty(value, "Jenis"),
                  ),
                  TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    autofocus: true,
                    decoration: const InputDecoration(labelText: 'Tanggal'),
                    controller: _tanggalController,
                    readOnly: true,
                    validator: (value) => validatorNotEmpty(value, "Tanggal"),
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialEntryMode: DatePickerEntryMode.calendarOnly,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101));
                      _tanggalController.text = pickedDate != null
                          ? DateFormat('dd-MM-yyyy').format(pickedDate)
                          : _tanggalController.text;
                      setState(() {
                        _tanggal = pickedDate ?? _tanggal;
                      });
                    },
                  ),
                  TextFormField(
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.number,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    autofocus: true,
                    decoration:
                        const InputDecoration(labelText: 'Jumlah Pembelian'),
                    controller: _jumlahController,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      CurrencyFormatter()
                    ],
                    validator: (value) {
                      return validatorNotEmpty(value, "Jumlah Pembelian");
                    },
                    onChanged: (value) => reCalculate(),
                  ),
                  TextFormField(
                    enabled: false,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    // autofocus: true,
                    decoration: const InputDecoration(labelText: 'Diskon'),
                    controller: _diskonController,
                    readOnly: true,
                  ),
                  Row(
                    children: [
                      const SizedBox(
                        width: 80,
                        child: Text(
                          "Hari Libur",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      RadioMenuButton(
                        value: false,
                        groupValue: _hariLibur,
                        onChanged: _hariLiburChanged,
                        child: const Text("Tidak"),
                      ),
                      RadioMenuButton(
                        value: true,
                        groupValue: _hariLibur,
                        onChanged: _hariLiburChanged,
                        child: const Text("Ya"),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const SizedBox(
                        width: 80,
                        child: Text(
                          "Saudara",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      RadioMenuButton(
                        value: false,
                        groupValue: _saudara,
                        onChanged: _saudaraChanged,
                        child: const Text("Tidak"),
                      ),
                      RadioMenuButton(
                        value: true,
                        groupValue: _saudara,
                        onChanged: _saudaraChanged,
                        child: const Text("Ya"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Jenis Barang Dibeli",
                    style: TextStyle(fontSize: 16),
                  ),
                  Wrap(
                    direction: Axis.horizontal,
                    spacing: 12,
                    children: _jenisBarang.entries.map((item) {
                      return FilterChip(
                        label: Text(item.key),
                        selected: item.value,
                        onSelected: (value) {
                          setState(() {
                            _jenisBarang[item.key] = value;
                          });
                          reCalculate();
                        },
                      );
                    }).toList(),
                  ),
                  TextFormField(
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.number,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    autofocus: true,
                    decoration: const InputDecoration(labelText: 'PPN'),
                    controller: _ppnController,
                    inputFormatters: [
                      // FilteringTextInputFormatter.digitsOnly,
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\,?\d*')),
                      PercentFormatter(),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) return null;
                      RegExp numRgx = RegExp(r'^(\d+(?:\,\d+)?|\,\d+)%?$');
                      return numRgx.hasMatch(value)
                          ? null
                          : "Format penulisan salah";
                    },
                    onChanged: (value) => reCalculate(),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    enabled: false,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    autofocus: true,
                    readOnly: true,
                    decoration: const InputDecoration(labelText: 'Grand Total'),
                    controller: _grandTotalController,
                  ),
                  TextFormField(
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.number,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    autofocus: true,
                    decoration:
                        const InputDecoration(labelText: 'Uang Dibayar'),
                    controller: _uangBayarController,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      CurrencyFormatter()
                    ],
                    validator: (value) {
                      String? validasi =
                          validatorNotEmpty(value, "Uang Dibayar");
                      if (validasi != null) return validasi;

                      double uang = CurrencyFormatter.toDouble(value ?? "");
                      double total = CurrencyFormatter.toDouble(
                          _grandTotalController.text);
                      if (uang < total) return "Uang yang dibayarkan kurang";
                      return null;
                    },
                    onChanged: (value) => reCalculate(),
                  ),
                  TextFormField(
                    enabled: false,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    autofocus: true,
                    readOnly: true,
                    decoration:
                        const InputDecoration(labelText: 'Uang Kembali'),
                    controller: _uangKembalianController,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Flexible(
                        flex: 3,
                        fit: FlexFit.tight,
                        child: Text(
                          "File Lampiran",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      ElevatedButton(
                        style: ButtonStyle(
                          alignment: Alignment.center,
                          backgroundColor: MaterialStatePropertyAll(
                              Theme.of(context).colorScheme.primary),
                          foregroundColor: MaterialStatePropertyAll(
                              Theme.of(context).colorScheme.onPrimary),
                        ),
                        onPressed: openFilePicker,
                        child: const Text("Browse"),
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                        border: Border.all(width: 1, color: Colors.grey[500]!),
                        borderRadius: BorderRadius.circular(8)),
                    child: ListView(
                      scrollDirection: Axis.vertical,
                      children: _files.map(
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
                                      style:
                                          const TextStyle(color: Colors.black),
                                    ),
                                  ),
                                  IconButton(
                                    style: ButtonStyle(
                                        alignment: Alignment.center,
                                        foregroundColor:
                                            MaterialStatePropertyAll(
                                                Colors.red[600])),
                                    onPressed: () => removeFile(item),
                                    icon: const Icon(Icons.delete),
                                  )
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
      ),
    );
  }
}
