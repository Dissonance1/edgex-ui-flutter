import 'package:flutter/material.dart';
import '../../api/edgex_service.dart';
import '../../models/rules.dart';

class AddStreamScreen extends StatefulWidget {
  final KuiperStream? stream;
  
  const AddStreamScreen({Key? key, this.stream}) : super(key: key);

  @override
  State<AddStreamScreen> createState() => _AddStreamScreenState();
}

class _AddStreamScreenState extends State<AddStreamScreen> {
  late TextEditingController _sqlController;
  final EdgeXService _service = EdgeXService();
  bool _isSubmitting = false;

  bool get _isEdit => widget.stream != null;

  @override
  void initState() {
    super.initState();
    _sqlController = TextEditingController(
      text: _isEdit 
        ? widget.stream!.sql 
        : 'CREATE STREAM demo () WITH (FORMAT="JSON", DATASOURCE="edgex/events")',
    );
  }

  @override
  void dispose() {
    _sqlController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_sqlController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('SQL is required')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      if (_isEdit) {
        await _service.updateStream(widget.stream!.name, _sqlController.text);
      } else {
        await _service.createStream(_sqlController.text);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEdit ? 'Stream updated successfully' : 'Stream created successfully'), 
            backgroundColor: Colors.green
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Stream' : 'Add Stream'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(_isEdit ? 'Update Stream SQL:' : 'Stream SQL:', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: TextFormField(
                controller: _sqlController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  fillColor: Color(0xFF2D2D2D),
                  filled: true,
                ),
                style: const TextStyle(
                  fontFamily: 'monospace', 
                  fontSize: 13,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_isEdit ? 'UPDATE STREAM' : 'CREATE STREAM'),
            ),
          ],
        ),
      ),
    );
  }
}
