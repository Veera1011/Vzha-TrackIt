import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:excel/excel.dart';

class FilePreviewScreen extends StatelessWidget {
  final String filePath;
  final String fileName;

  const FilePreviewScreen({
    super.key,
    required this.filePath,
    required this.fileName,
  });

  @override
  Widget build(BuildContext context) {
    final extension = fileName.split('.').last.toLowerCase();

    return Scaffold(
      appBar: AppBar(
        title: Text(fileName),
      ),
      body: _buildPreview(extension),
    );
  }

  Widget _buildPreview(String extension) {
    if (extension == 'pdf') {
      return PdfPreview(
        build: (format) => File(filePath).readAsBytes(),
        canChangePageFormat: false,
        canChangeOrientation: false,
        canDebug: false,
      );
    } else if (extension == 'xlsx' || extension == 'xls') {
      return _ExcelPreview(filePath: filePath);
    } else {
      return const Center(child: Text('Unsupported file format'));
    }
  }
}

class _ExcelPreview extends StatefulWidget {
  final String filePath;
  const _ExcelPreview({required this.filePath});

  @override
  State<_ExcelPreview> createState() => _ExcelPreviewState();
}

class _ExcelPreviewState extends State<_ExcelPreview> {
  List<List<dynamic>> _data = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExcel();
  }

  Future<void> _loadExcel() async {
    try {
      final bytes = await File(widget.filePath).readAsBytes();
      final excel = Excel.decodeBytes(bytes);
      final List<List<dynamic>> rows = [];
      
      // Load first sheet
      for (var table in excel.tables.keys) {
        final sheet = excel.tables[table];
        if (sheet != null) {
          for (var row in sheet.rows) {
            rows.add(row.map((cell) => cell?.value?.toString() ?? '').toList());
          }
        }
        break; // Only show first sheet for preview
      }

      if (mounted) {
        setState(() {
          _data = rows;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_data.isEmpty) return const Center(child: Text('No data found in Excel'));

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: _data.first.map((col) => DataColumn(label: Text(col?.toString() ?? ''))).toList(),
          rows: _data.skip(1).map((row) {
            return DataRow(
              cells: row.map((cell) => DataCell(Text(cell?.toString() ?? ''))).toList(),
            );
          }).toList(),
        ),
      ),
    );
  }
}
