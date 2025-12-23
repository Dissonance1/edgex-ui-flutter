import 'package:flutter/material.dart';
import '../../api/edgex_service.dart';
import '../../models/support.dart';

class AddIntervalActionScreen extends StatefulWidget {
  final IntervalAction? action;
  
  const AddIntervalActionScreen({Key? key, this.action}) : super(key: key);

  @override
  State<AddIntervalActionScreen> createState() => _AddIntervalActionScreenState();
}

class _AddIntervalActionScreenState extends State<AddIntervalActionScreen> {
  final _formKey = GlobalKey<FormState>();
  final EdgeXService _service = EdgeXService();
  
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _contentController;
  
  List<IntervalDef> _intervals = [];
  String? _selectedInterval;
  bool _isSubmitting = false;
  bool _isLoadingIntervals = true;

  bool get _isEdit => widget.action != null;

  @override
  void initState() {
    super.initState();
    final action = widget.action;
    _nameController = TextEditingController(text: action?.name ?? '');
    _addressController = TextEditingController(text: action?.address ?? '');
    _contentController = TextEditingController(text: action?.content ?? '');
    _selectedInterval = action?.intervalName;
    
    _loadIntervals();
  }

  Future<void> _loadIntervals() async {
    try {
      final intervals = await _service.fetchIntervals();
      if (mounted) {
        setState(() {
          _intervals = intervals;
          _isLoadingIntervals = false;
          if (_selectedInterval == null && _intervals.isNotEmpty) {
            _selectedInterval = _intervals.first.name;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingIntervals = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading intervals: $e'), backgroundColor: Colors.orange),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedInterval == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an interval'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final actionData = {
        'name': _nameController.text.trim(),
        'intervalName': _selectedInterval,
        'address': _addressController.text.trim(),
        'content': _contentController.text.trim(),
        'adminState': widget.action?.adminState ?? 'UNLOCKED',
      };

      if (_isEdit) {
        await _service.updateIntervalAction(actionData);
      } else {
        await _service.createIntervalAction(actionData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Interval Action ${_isEdit ? "updated" : "created"} successfully'), 
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
        title: Text(_isEdit ? 'Edit Interval Action' : 'Add Interval Action'),
      ),
      body: _isLoadingIntervals
          ? const Center(child: CircularProgressIndicator())
          : Form(
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
                      helperText: 'Unique action name',
                    ),
                    validator: (value) => value?.isEmpty ?? true ? 'Name is required' : null,
                  ),
                  const SizedBox(height: 16),
                  
                  DropdownButtonFormField<String>(
                    value: _selectedInterval,
                    decoration: const InputDecoration(
                      labelText: 'Interval *',
                      border: OutlineInputBorder(),
                      helperText: 'Select when this action runs',
                    ),
                    items: _intervals.map((interval) {
                      return DropdownMenuItem(
                        value: interval.name,
                        child: Text('${interval.name} (${interval.frequency})'),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedInterval = value),
                    validator: (value) => value == null ? 'Interval is required' : null,
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'Address *',
                      border: OutlineInputBorder(),
                      helperText: 'REST endpoint URL',
                    ),
                    validator: (value) => value?.isEmpty ?? true ? 'Address is required' : null,
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _contentController,
                    decoration: const InputDecoration(
                      labelText: 'Content',
                      border: OutlineInputBorder(),
                      helperText: 'Optional request body',
                    ),
                    maxLines: 3,
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
                        : Text(_isEdit ? 'Update Interval Action' : 'Create Interval Action'),
                  ),
                ],
              ),
            ),
    );
  }
}
