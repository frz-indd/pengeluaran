import 'package:flutter/material.dart';

class ExportAppSelectionDialog extends StatelessWidget {
  final Function(String) onAppSelected;

  const ExportAppSelectionDialog({required this.onAppSelected, super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pilih Aplikasi'),
      content: const Text('Buka file dengan aplikasi apa?'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onAppSelected('excel');
          },
          child: const Text('Excel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onAppSelected('wps');
          },
          child: const Text('WPS Office'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onAppSelected('default');
          },
          child: const Text('Aplikasi Default'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Batal'),
        ),
      ],
    );
  }
}
