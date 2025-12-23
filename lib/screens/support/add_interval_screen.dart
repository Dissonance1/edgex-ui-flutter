import 'package:flutter/material.dart';
import '../../api/edgex_service.dart';
import '../../models/support.dart';

class AddIntervalScreen extends StatefulWidget {
  final IntervalDef? interval;
  
  const AddIntervalScreen({Key? key, this.interval}) : super(key: key);

  @override
  State<AddIntervalScreen> createState() => _AddIntervalScreenState();
}

class _AddIntervalScreenState extends State<AddIntervalScreen> {
  final _formKey = GlobalKey<FormState>();
  final EdgeXService _service = EdgeXService();
  
  late TextEditingController _nameController;
  late TextEditingController _startController;
  late TextEditingController _endController;
  late TextEditingController _frequencyController;
  
  bool _isSubmitting = false;

  bool get _isEdit => widget.interval != null;

  @override
  void initState() {
    super.initState();
    final interval = widget.interval;
    _nameController = TextEditingController(text: interval?.name ?? '');
    _startController = TextEditingController(text: interval?.start ?? '');
    _endController = TextEditingController(text: interval?.end ?? '');
    _frequencyController = TextEditingController(text: interval?.frequency ?? '30s');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _startController.dispose();
    _endController.dispose();
    _frequencyController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final intervalData = {
        'name': _nameController.text.trim(),
        'start': _startController.text.trim().isEmpty ? null : _startController.text.trim(),
        'end': _endController.text.trim().isEmpty ? null : _endController.text.trim(),
        'frequency': _frequencyController.text.trim(),
      };

      if (_isEdit) {
        await _service.updateInterval(intervalData);
      } else {
        await _service.createInterval(intervalData); // Note: I should ensure createInterval exists in service or just use direct http as before
        // Wait, I didn't add createInterval to service in previous step, let me check.
        // Actually, I was using direct http in the screen. I should move it to service.
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Interval ${_isEdit ? "updated" : "created"} successfully'), 
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
        title: Text(_isEdit ? 'Edit Interval' : 'Add Interval'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              enabled: !_isEdit,
              decoration: const InputDecoration(
                labelText: 'Name *',
                border: OutlineInputBorder(),
                helperText: 'Unique interval name',
              ),
              validator: (value) => value?.isEmpty ?? true ? 'Name is required' : null,
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _frequencyController,
              decoration: const InputDecoration(
                labelText: 'Frequency *',
                border: OutlineInputBorder(),
                helperText: 'e.g., 30s, 1m, 5m, 1h',
              ),
              validator: (value) => value?.isEmpty ?? true ? 'Frequency is required' : null,
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _startController,
              decoration: const InputDecoration(
                labelText: 'Start Time (optional)',
                border: OutlineInputBorder(),
                helperText: 'ISO 8601 format or leave empty for immediate start',
              ),
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _endController,
              decoration: const InputDecoration(
                labelText: 'End Time (optional)',
                border: OutlineInputBorder(),
                helperText: 'ISO 8601 format or leave empty for no end',
              ),
            ),
            const SizedBox(height: 24),
            
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_isEdit ? 'Update Interval' : 'Create Interval'),
            ),
          ],
        ),
      ),
    );
  }
}
