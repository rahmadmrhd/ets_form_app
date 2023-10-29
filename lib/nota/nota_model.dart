import 'dart:typed_data';

import 'package:intl/intl.dart';

Map<String, double> jenisPembeliOptions = {
  "Biasa": 0,
  "Pelanggan": 0.02,
  "Pelanggan Istimewa": 0.04,
};

Map<String, int> jenisBarangOptions = {
  "ABC": 100,
  "BBB": -500,
  "XYZ": 200,
  "WWW": -100,
};

class ImageFile {
  final String? path;
  final String name;
  Uint8List? bytes;

  ImageFile({
    this.path,
    required this.name,
  });

  @override
  bool operator ==(Object other) {
    if (other is! ImageFile) return false;
    return path == other.path || name == other.name;
  }

  @override
  int get hashCode {
    var result = 17;
    result = 37 * result + path.hashCode;
    result = 37 * result + name.hashCode;
    return result;
  }
}

class Nota {
  late String nomorNota;
  late String namaPembeli;
  late String jenis;
  late DateTime tanggal;
  late double jumlah;
  late double diskon;
  late bool hariLibur;
  late bool saudara;
  late Map<String, bool> jenisBarang;
  late double ppn;
  late double grandTotal;
  late double uangDibayar;
  late double uangKembalian = uangDibayar - grandTotal;
  // late Set<PlatformFile> files;
  late Set<ImageFile> files;

  Nota({
    required this.nomorNota,
    required this.namaPembeli,
    required this.jenis,
    required this.tanggal,
    required this.jumlah,
    required this.diskon,
    required this.hariLibur,
    required this.saudara,
    required this.jenisBarang,
    required this.ppn,
    required this.grandTotal,
    required this.uangDibayar,
    required this.files,
  });

  Map<String, String> toMap() {
    return {
      'Nomer Nota': nomorNota,
      'Nama Pembeli': namaPembeli,
      'Jenis': jenis,
      'Tanggal': DateFormat("dd-MM-yyyy").format(tanggal),
      'Jumlah Pembelian':
          NumberFormat.currency(symbol: 'Rp. ', decimalDigits: 2, locale: 'id')
              .format(jumlah),
      'Diskon':
          NumberFormat.currency(symbol: 'Rp. ', decimalDigits: 2, locale: 'id')
              .format(diskon),
      'Hari Libur': hariLibur ? 'Ya' : 'Tidak',
      'Saudara': saudara ? 'Ya' : 'Tidak',
      'Jenis Barang': jenisBarang.entries
          .where((e) => e.value)
          .map((e) => '- ${e.key}')
          .join('\n'),
      'PPN': NumberFormat.decimalPercentPattern(decimalDigits: 2, locale: 'id')
          .format(ppn),
      'Grand Total':
          NumberFormat.currency(symbol: 'Rp. ', decimalDigits: 2, locale: 'id')
              .format(grandTotal),
      'Uang Dibayar':
          NumberFormat.currency(symbol: 'Rp. ', decimalDigits: 2, locale: 'id')
              .format(uangDibayar),
      'Uang Kembalian':
          NumberFormat.currency(symbol: 'Rp. ', decimalDigits: 2, locale: 'id')
              .format(uangKembalian),
    };
  }
}
