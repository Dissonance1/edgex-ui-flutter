import 'package:flutter/material.dart';
import '../../api/edgex_service.dart';
import '../../models/metadata.dart';

class AddProfileScreen extends StatefulWidget {
  final DeviceProfile? profile;
  
  const AddProfileScreen({Key? key, this.profile}) : super(key: key);

  @override
  State<AddProfileScreen> createState() => _AddProfileScreenState();
}

class _AddProfileScreenState extends State<AddProfileScreen> {
  final _yamlController = TextEditingController();
  final EdgeXService _service = EdgeXService();
  bool _isSubmitting = false;
  bool _isLoading = false;

  bool get _isEdit => widget.profile != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _loadProfileYaml();
    }
  }

  Future<void> _loadProfileYaml() async {
    setState(() => _isLoading = true);
    try {
      final yaml = await _service.fetchProfileYamlByName(widget.profile!.name);
      if (mounted) {
        setState(() {
          _yamlController.text = yaml;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile YAML: $e'), backgroundColor: Colors.orange),
        );
      }
    }
  }

  @override
  void dispose() {
    _yamlController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_yamlController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please paste YAML content')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await _service.uploadProfile(_yamlController.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEdit ? 'Profile updated successfully' : 'Profile uploaded successfully'), 
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
        title: Text(_isEdit ? 'Edit Device Profile' : 'Upload Device Profile'),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _isEdit ? 'Edit Profile YAML content:' : 'Paste Profile YAML content below:',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: TextFormField(
                    controller: _yamlController,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'deviceprofile:\n  name: "MyDeviceProfile"\n  ...',
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
                      : Text(_isEdit ? 'UPDATE PROFILE' : 'UPLOAD PROFILE'),
                ),
              ],
            ),
          ),
    );
  }
}
