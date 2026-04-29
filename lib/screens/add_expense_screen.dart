import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

import '../models/expense.dart';
import '../models/category.dart';
import '../providers/expense_provider.dart';
import '../services/receipt_image_service.dart';
import '../widgets/image_preview_dialog.dart';
import '../widgets/category_icon.dart';

class AddExpenseScreen extends StatefulWidget {
  final Expense? expenseToEdit;

  const AddExpenseScreen({super.key, this.expenseToEdit});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;
  late String _selectedCategory;

  // 🔥 TAMBAHAN FOTO
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  final ReceiptImageService _receiptImageService = const ReceiptImageService();

  @override
  void initState() {
    super.initState();
    if (widget.expenseToEdit != null) {
      _titleController = TextEditingController(
        text: widget.expenseToEdit!.title,
      );
      _amountController = TextEditingController(
        text: widget.expenseToEdit!.amount.toString(),
      );
      _descriptionController = TextEditingController(
        text: widget.expenseToEdit!.description,
      );
      _selectedDate = widget.expenseToEdit!.date;
      _selectedCategory = widget.expenseToEdit!.category;

      // 🔥 load gambar lama kalau ada
      if (widget.expenseToEdit!.imagePath != null) {
        _selectedImage = File(widget.expenseToEdit!.imagePath!);
      }
    } else {
      _titleController = TextEditingController();
      _amountController = TextEditingController();
      _descriptionController = TextEditingController();
      _selectedDate = DateTime.now();
      _selectedCategory = categories[0].name;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // 🔥 FUNCTION AMBIL GAMBAR
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      final compressed = await _receiptImageService.compressAndPersist(
        sourcePath: pickedFile.path,
        targetReductionFactor: 10,
      );
      setState(() {
        _selectedImage = compressed;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveExpense() {
    if (_titleController.text.isEmpty || _amountController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Harap isi semua field')));
      return;
    }

    final expense = Expense(
      id: widget.expenseToEdit?.id,
      title: _titleController.text,
      amount: double.parse(_amountController.text),
      category: _selectedCategory,
      date: _selectedDate,
      description: _descriptionController.text,
      imagePath: _selectedImage?.path, // 🔥 simpan foto
    );

    final provider = context.read<ExpenseProvider>();
    if (widget.expenseToEdit != null) {
      provider.updateExpense(expense);
    } else {
      provider.addExpense(expense);
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.expenseToEdit != null
              ? 'Pengeluaran diperbarui'
              : 'Pengeluaran ditambahkan',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMMM yyyy', 'id_ID');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.expenseToEdit != null
              ? 'Edit Pengeluaran'
              : 'Tambah Pengeluaran',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title Field
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Judul Pengeluaran',
                prefixText: '📝 ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Amount Field
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'Jumlah (Rp)',
                prefixText: '💰 ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 🔥 FOTO
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Foto Bukti',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 12),

                    _selectedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: InkWell(
                              onTap: () {
                                final path = _selectedImage?.path;
                                if (path == null) return;
                                showImagePreviewDialog(
                                  context,
                                  imagePath: path,
                                  title: 'Foto Bukti',
                                );
                              },
                              child: Image.file(
                                _selectedImage!,
                                height: 150,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                        : Container(
                            height: 150,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('Belum ada foto'),
                          ),

                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _pickImage(ImageSource.camera),
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Kamera'),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _pickImage(ImageSource.gallery),
                          icon: const Icon(Icons.photo),
                          label: const Text('Galeri'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Category Selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kategori',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: categories.map((category) {
                        final isSelected = _selectedCategory == category.name;
                        return FilterChip(
                          selected: isSelected,
                          onSelected: (_) {
                            setState(() {
                              _selectedCategory = category.name;
                            });
                          },
                          avatar: CategoryIcon(category: category, size: 18),
                          label: Text(category.name),
                          backgroundColor: category.color.withAlpha(51),
                          selectedColor: category.color,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : null,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Date
            Card(
              child: ListTile(
                leading: const Text('📅'),
                title: Text(dateFormat.format(_selectedDate)),
                trailing: const Text('✎'),
                onTap: () => _selectDate(context),
              ),
            ),

            const SizedBox(height: 16),

            // Description
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Keterangan',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _saveExpense,
              child: Text(widget.expenseToEdit != null ? 'Perbarui' : 'Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}
