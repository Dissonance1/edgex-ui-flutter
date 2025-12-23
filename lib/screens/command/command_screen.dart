import 'package:flutter/material.dart';
import '../../api/edgex_service.dart';
import '../../models/command.dart';
import 'dart:convert';

class CommandScreen extends StatefulWidget {
  final String deviceName;

  const CommandScreen({Key? key, required this.deviceName}) : super(key: key);

  @override
  State<CommandScreen> createState() => _CommandScreenState();
}

class _CommandScreenState extends State<CommandScreen> {
  final EdgeXService _service = EdgeXService();
  List<CoreCommand> _commands = [];
  bool _isLoading = true;
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _fetchCommands();
  }

  Future<void> _fetchCommands() async {
    try {
      final commands = await _service.fetchDeviceCoreCommands(widget.deviceName);
      if (mounted) {
        setState(() {
          _commands = commands;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading commands: $e')),
        );
      }
    }
  }

  Future<void> _executeCommand(CoreCommand command, String method) async {
    try {
      Map<String, dynamic>? body;
      
      if (method == 'PUT') {
        // Construct body from parameters
        final Map<String, dynamic> params = {};
        bool hasParams = false;
        
        for (var param in command.parameters) {
          final controller = _controllers['${command.name}_${param.resourceName}'];
          if (controller != null && controller.text.isNotEmpty) {
            // Basic type inference
            if (param.valueType == 'Bool') {
              params[param.resourceName] = controller.text.toLowerCase() == 'true';
            } else if (['Int8', 'Int16', 'Int32', 'Int64'].contains(param.valueType)) {
              params[param.resourceName] = int.parse(controller.text);
            } else if (['Float32', 'Float64'].contains(param.valueType)) {
              params[param.resourceName] = double.parse(controller.text);
            } else {
              params[param.resourceName] = controller.text;
            }
            hasParams = true;
          }
        }
        
        if (hasParams) {
          body = params;
        } else {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter parameters for PUT command')),
          );
          return;
        }
      }

      await _service.executeCommand(widget.deviceName, command.name, method, body: body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Command $method executed successfully'),
            backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Execution failed: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Commands: ${widget.deviceName}'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _commands.length,
              itemBuilder: (context, index) {
                final command = _commands[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ExpansionTile(
                    title: Text(command.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Path: ${command.path}'),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (command.get)
                              ElevatedButton(
                                onPressed: () => _executeCommand(command, 'GET'),
                                child: const Text('Execute GET'),
                              ),
                            const SizedBox(height: 16),
                            if (command.set) ...[
                              const Text('Parameters (for PUT):', style: TextStyle(fontWeight: FontWeight.bold)),
                              ...command.parameters.map((param) {
                                final key = '${command.name}_${param.resourceName}';
                                _controllers.putIfAbsent(key, () => TextEditingController());
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: TextField(
                                    controller: _controllers[key],
                                    decoration: InputDecoration(
                                      labelText: '${param.resourceName} (${param.valueType})',
                                      border: const OutlineInputBorder(),
                                    ),
                                  ),
                                );
                              }).toList(),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                                onPressed: () => _executeCommand(command, 'PUT'),
                                child: const Text('Execute PUT'),
                              ),
                            ]
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
    );
  }
}
