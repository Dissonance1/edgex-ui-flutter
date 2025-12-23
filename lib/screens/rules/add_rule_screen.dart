import 'package:flutter/material.dart';
import 'dart:convert';
import '../../api/edgex_service.dart';

class AddRuleScreen extends StatefulWidget {
  const AddRuleScreen({Key? key}) : super(key: key);

  @override
  State<AddRuleScreen> createState() => _AddRuleScreenState();
}

class _AddRuleScreenState extends State<AddRuleScreen> {
  final _idController = TextEditingController();
  final _sqlController = TextEditingController(text: 'SELECT * FROM demo');
  final _actionsController = TextEditingController(
    text: '[\n  {\n    "log": {}\n  }\n]',
  );
  final EdgeXService _service = EdgeXService();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _idController.dispose();
    _sqlController.dispose();
    _actionsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_idController.text.trim().isEmpty || _sqlController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ID and SQL are required')),
      );
      return;
    }

    List<Map<String, dynamic>> actions;
    try {
      final decoded = json.decode(_actionsController.text);
      if (decoded is List) {
        actions = decoded.cast<Map<String, dynamic>>();
      } else {
        throw const FormatException('Actions must be a list');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid JSON in Actions: $e')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await _service.createRule(
        _idController.text.trim(),
        _sqlController.text.trim(),
        actions,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rule created successfully'), backgroundColor: Colors.green),
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
        title: const Text('Add Rule'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _idController,
              decoration: const InputDecoration(
                labelText: 'Rule ID *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Rule SQL *:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(
              height: 100,
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
            const Text('Actions JSON List *:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: TextFormField(
                controller: _actionsController,
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
                  ? const CircularProgressIndicator()
                  : const Text('CREATE RULE'),
            ),
          ],
        ),
      ),
    );
  }
}
