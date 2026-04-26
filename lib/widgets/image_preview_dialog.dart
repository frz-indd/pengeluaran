import 'dart:io';

import 'package:flutter/material.dart';

Future<void> showImagePreviewDialog(
  BuildContext context, {
  required String imagePath,
  String? title,
}) async {
  final file = File(imagePath);
  if (!file.existsSync()) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('File gambar tidak ditemukan')),
    );
    return;
  }

  await showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return Dialog(
        insetPadding: const EdgeInsets.all(12),
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Positioned.fill(
              child: InteractiveViewer(
                minScale: 1,
                maxScale: 5,
                child: Center(child: Image.file(file, fit: BoxFit.contain)),
              ),
            ),
            Positioned(
              top: 8,
              left: 8,
              right: 8,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title ?? 'Preview',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                    tooltip: 'Tutup',
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}
