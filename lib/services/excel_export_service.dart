import 'dart:io';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import '../models/expense.dart';

class ExcelExportService {
  static Future<String?> exportExpensesToExcel(
    List<Expense> expenses, {
    required String monthYear,
  }) async {
    try {
      // Format date
      final dateFormat = DateFormat('dd/MM/yyyy', 'id_ID');

      // Prepare headers
      List<List<dynamic>> csvData = [
        ['LAPORAN PENGELUARAN - $monthYear'],
        [], // Empty row
        ['Tanggal', 'Judul', 'Kategori', 'Jumlah (Rp)', 'Keterangan'],
      ];

      // Add data rows
      double totalAmount = 0;
      for (final expense in expenses) {
        totalAmount += expense.amount;
        csvData.add([
          dateFormat.format(expense.date),
          expense.title,
          expense.category,
          expense.amount.toStringAsFixed(0),
          expense.description ?? '-',
        ]);
      }

      // Add empty row and total
      csvData.add([]);
      csvData.add(['', '', 'TOTAL', totalAmount.toStringAsFixed(0), '']);

      // Convert to CSV
      String csv = const ListToCsvConverter().convert(csvData);

      // Save file
      final fileName =
          'Laporan_Pengeluaran_${monthYear.replaceAll(' ', '_')}.xlsx';
      final filePath = await _getExcelFilePath(fileName);

      final file = File(filePath);
      await file.writeAsString(csv, encoding: utf8);

      return filePath;
    } catch (e) {
      print('Error exporting to Excel: $e');
      return null;
    }
  }

  /// Get file path untuk menyimpan Excel file
  static Future<String> _getExcelFilePath(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$fileName';
  }

  /// Open file dengan aplikasi yang dipilih
  static Future<void> openFile(String filePath, String appChoice) async {
    try {
      if (appChoice == 'excel') {
        // Untuk Excel
        await OpenFile.open(filePath, type: 'application/vnd.ms-excel');
      } else if (appChoice == 'wps') {
        // Untuk WPS Office
        await OpenFile.open(filePath, type: 'application/vnd.ms-excel');
      } else {
        // Default
        await OpenFile.open(filePath);
      }
    } catch (e) {
      print('Error opening file: $e');
    }
  }
}
