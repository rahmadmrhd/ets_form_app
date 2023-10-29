import 'package:ets_form_app/nota/nota_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ImageViewer extends StatelessWidget {
  const ImageViewer({super.key, required this.image});
  final ImageFile image;

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text(image.name),
      titleTextStyle: const TextStyle(
          color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold),
      children: [
        Image.memory(
          image.bytes ?? Uint8List(10),
          isAntiAlias: true,
        )
      ],
    );
  }
}
