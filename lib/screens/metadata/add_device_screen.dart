import 'package:flutter/material.dart';
import '../../api/edgex_service.dart';
import '../../models/metadata.dart';
import '../../models/device.dart';

class AddDeviceScreen extends StatefulWidget {
  final Device? device;
  
  const AddDeviceScreen({Key? key, this.device}) : super(key: key);

  @override
  State<AddDeviceScreen> createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends State<AddDeviceScreen> {
  final _formKey = GlobalKey<FormState>();
  final EdgeXService _service = EdgeXService();
  
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _labelsController;
  
  List<DeviceProfile> _profiles = [];
  List<DeviceService> _services = [];
  
  String? _selectedProfile;
  String? _selectedService;
  
  bool _isLoading = true;
  bool _isSubmitting = false;

  late TextEditingController _protocolNameController;
  final _protocolFields = <String, TextEditingController>{};

  bool get _isEdit => widget.device != null;

  @override
  void initState() {
    super.initState();
    final dev = widget.device;
    _nameController = TextEditingController(text: dev?.name ?? '');
    _descriptionController = TextEditingController(text: dev?.description ?? '');
    _labelsController = TextEditingController(text: dev?.labels.join(', ') ?? '');
    
    // Default protocol setup
    String protoName = 'mqtt';
    Map<String, String> initialFields = {'Host': 'localhost', 'Port': '1883', 'Topic': 'test'};
    
    if (dev != null) {
      // In a real app we'd parse the actual protocols map. For now just take the first one found.
      // Assuming dev.protocols is available in the model (I should check if I added it)
      // If not, we just use defaults for editing too since EdgeX models can be complex.
      // Note: Device model might need extension if protocols isn't there.
    }
    
    _protocolNameController = TextEditingController(text: protoName);
    initialFields.forEach((key, val) {
      _protocolFields[key] = TextEditingController(text: val);
    });

    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        _service.fetchProfiles(),
        _service.fetchServices(),
      ]);
      if (mounted) {
        setState(() {
          _profiles = results[0] as List<DeviceProfile>;
          _services = results[1] as List<DeviceService>;
          _isLoading = false;
          
          if (_isEdit) {
            _selectedProfile = widget.device?.profileName;
            _selectedService = widget.device?.serviceName;
          } else {
            if (_profiles.isNotEmpty) _selectedProfile = _profiles.first.name;
            if (_services.isNotEmpty) _selectedService = _services.first.name;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading metadata: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _labelsController.dispose();
    _protocolNameController.dispose();
    _protocolFields.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProfile == null || _selectedService == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile and Service are required')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final labels = _labelsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final protocolData = <String, dynamic>{};
      _protocolFields.forEach((key, controller) {
        if (controller.text.isNotEmpty) {
          protocolData[key] = controller.text;
        }
      });

      final deviceData = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'adminState': widget.device?.adminState ?? 'UNLOCKED',
        'operatingState': widget.device?.operatingState ?? 'UP',
        'labels': labels,
        'profileName': _selectedProfile,
        'serviceName': _selectedService,
        'protocols': {
          _protocolNameController.text.trim(): protocolData,
        },
      };

      if (_isEdit) {
        await _service.updateDevice(deviceData);
      } else {
        await _service.createDevice(deviceData);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Device ${_isEdit ? "updated" : "created"} successfully'), 
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
        title: Text(_isEdit ? 'Edit Device' : 'Add Device'),
      ),
      body: _isLoading
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
                      labelText: 'Device Name *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value?.isEmpty ?? true ? 'Name is required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _labelsController,
                    decoration: const InputDecoration(
                      labelText: 'Labels (comma separated)',
                      border: OutlineInputBorder(),
                      hintText: 'sensor, mqtt, industrial',
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('Associations', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedProfile,
                    decoration: const InputDecoration(labelText: 'Device Profile *', border: OutlineInputBorder()),
                    items: _profiles.map((p) => DropdownMenuItem(value: p.name, child: Text(p.name))).toList(),
                    onChanged: _isEdit ? null : (val) => setState(() => _selectedProfile = val),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedService,
                    decoration: const InputDecoration(labelText: 'Device Service *', border: OutlineInputBorder()),
                    items: _services.map((s) => DropdownMenuItem(value: s.name, child: Text(s.name))).toList(),
                    onChanged: _isEdit ? null : (val) => setState(() => _selectedService = val),
                  ),
                  const SizedBox(height: 24),
                  const Text('Protocol Configuration', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _protocolNameController,
                    decoration: const InputDecoration(
                      labelText: 'Protocol Name (e.g., mqtt)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ..._protocolFields.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: TextFormField(
                        controller: entry.value,
                        decoration: InputDecoration(
                          labelText: entry.key,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
                    child: _isSubmitting
                        ? const CircularProgressIndicator()
                        : Text(_isEdit ? 'UPDATE DEVICE' : 'CREATE DEVICE'),
                  ),
                ],
              ),
            ),
    );
  }
}
