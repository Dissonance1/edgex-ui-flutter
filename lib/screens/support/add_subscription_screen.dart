import 'package:flutter/material.dart';
import '../../api/edgex_service.dart';
import '../../models/subscription.dart';

class AddSubscriptionScreen extends StatefulWidget {
  final Subscription? subscription;
  
  const AddSubscriptionScreen({Key? key, this.subscription}) : super(key: key);

  @override
  State<AddSubscriptionScreen> createState() => _AddSubscriptionScreenState();
}

class _AddSubscriptionScreenState extends State<AddSubscriptionScreen> {
  final _formKey = GlobalKey<FormState>();
  final EdgeXService _service = EdgeXService();
  
  late TextEditingController _nameController;
  late TextEditingController _receiverController;
  late TextEditingController _descriptionController;
  late TextEditingController _resendIntervalController;
  
  final List<String> _selectedChannels = [];
  final List<String> _selectedCategories = [];
  final List<String> _selectedLabels = [];
  
  bool _resendOnChange = false;
  int _resendLimit = 0;
  bool _isSubmitting = false;

  final List<String> _availableChannels = ['REST', 'EMAIL'];
  final List<String> _availableCategories = ['SECURITY', 'HW_HEALTH', 'SW_HEALTH'];

  bool get _isEdit => widget.subscription != null;

  @override
  void initState() {
    super.initState();
    final sub = widget.subscription;
    _nameController = TextEditingController(text: sub?.name ?? '');
    _receiverController = TextEditingController(text: sub?.receiver ?? '');
    _descriptionController = TextEditingController(text: sub?.description ?? '');
    _resendIntervalController = TextEditingController(text: sub?.resendInterval ?? '1h');
    
    if (sub != null) {
      _selectedChannels.addAll(sub.channels);
      _selectedCategories.addAll(sub.categories);
      _selectedLabels.addAll(sub.labels);
      _resendOnChange = sub.resendOnChange;
      _resendLimit = sub.resendLimit;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _receiverController.dispose();
    _descriptionController.dispose();
    _resendIntervalController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedChannels.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one channel'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final subscription = Subscription(
        id: widget.subscription?.id ?? '', 
        name: _nameController.text.trim(),
        channels: _selectedChannels,
        receiver: _receiverController.text.trim(),
        categories: _selectedCategories,
        labels: _selectedLabels,
        description: _descriptionController.text.trim(),
        resendOnChange: _resendOnChange,
        resendLimit: _resendLimit,
        resendInterval: _resendIntervalController.text.trim(),
      );

      if (_isEdit) {
        await _service.updateSubscription(subscription);
      } else {
        await _service.createSubscription(subscription);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Subscription ${_isEdit ? "updated" : "created"} successfully'), 
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
        title: Text(_isEdit ? 'Edit Subscription' : 'Add Subscription'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              enabled: !_isEdit, // Name is likely immutable in EdgeX once created
              decoration: const InputDecoration(
                labelText: 'Name *',
                border: OutlineInputBorder(),
                helperText: 'Unique subscription name',
              ),
              validator: (value) => value?.isEmpty ?? true ? 'Name is required' : null,
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _receiverController,
              decoration: const InputDecoration(
                labelText: 'Receiver *',
                border: OutlineInputBorder(),
                helperText: 'Receiver name or identifier',
              ),
              validator: (value) => value?.isEmpty ?? true ? 'Receiver is required' : null,
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            
            const Text('Channels *', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _availableChannels.map((channel) {
                return FilterChip(
                  label: Text(channel),
                  selected: _selectedChannels.contains(channel),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedChannels.add(channel);
                      } else {
                        _selectedChannels.remove(channel);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            
            const Text('Categories', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _availableCategories.map((category) {
                return FilterChip(
                  label: Text(category),
                  selected: _selectedCategories.contains(category),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedCategories.add(category);
                      } else {
                        _selectedCategories.remove(category);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            
            SwitchListTile(
              title: const Text('Resend on Change'),
              value: _resendOnChange,
              onChanged: (value) => setState(() => _resendOnChange = value),
            ),
            
            TextFormField(
              initialValue: _resendLimit.toString(),
              decoration: const InputDecoration(
                labelText: 'Resend Limit',
                border: OutlineInputBorder(),
                helperText: '0 = unlimited',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) => _resendLimit = int.tryParse(value) ?? 0,
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _resendIntervalController,
              decoration: const InputDecoration(
                labelText: 'Resend Interval',
                border: OutlineInputBorder(),
                helperText: 'e.g., 1h, 30m, 1h30m',
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
                  : Text(_isEdit ? 'Update Subscription' : 'Create Subscription'),
            ),
          ],
        ),
      ),
    );
  }
}
