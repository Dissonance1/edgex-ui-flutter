import 'package:flutter/material.dart';
import '../../api/edgex_service.dart';
import '../../models/app_service.dart';
import 'dart:convert';

class AppServiceDetailScreen extends StatefulWidget {
  final AppService service;

  const AppServiceDetailScreen({Key? key, required this.service}) : super(key: key);

  @override
  State<AppServiceDetailScreen> createState() => _AppServiceDetailScreenState();
}

class _AppServiceDetailScreenState extends State<AppServiceDetailScreen> {
  final EdgeXService _service = EdgeXService();
  Map<String, dynamic>? _config;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final config = await _service.fetchAppServiceConfig(widget.service.serviceKey.isEmpty ? widget.service.name : widget.service.serviceKey);
      if (mounted) {
        setState(() {
          _config = config;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('App Service: ${widget.service.name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadConfig,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.orange),
                      const SizedBox(height: 16),
                      Text('Configuration not available for this service'),
                      const SizedBox(height: 8),
                      Text(_error!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 16),
                      ElevatedButton(onPressed: _loadConfig, child: const Text('Retry')),
                    ],
                  ),
                )
              : _buildConfigView(),
    );
  }

  Widget _buildConfigView() {
    if (_config == null) return const Center(child: Text('No configuration data'));

    final trigger = _config!['Trigger'] ?? {};
    final writable = _config!['Writable'] ?? {};
    final appSettings = _config!['ApplicationSettings'] ?? {};

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionTitle('Trigger'),
        _buildInfoCard({
          'Type': trigger['Type'] ?? 'N/A',
          'Subscribe Topics': trigger['SubscribeTopics'] ?? 'N/A',
          'Publish Topic': trigger['PublishTopic'] ?? 'N/A',
        }),
        const SizedBox(height: 24),
        _buildSectionTitle('Writable Settings'),
        _buildInfoCard({
          'Log Level': writable['LogLevel'] ?? 'N/A',
          'Store and Forward': writable['StoreAndForward']?.toString() ?? 'N/A',
          'Pipeline Functions': _extractPipelineNames(writable['Pipeline']),
        }),
        const SizedBox(height: 24),
        _buildSectionTitle('Application Settings'),
        _buildInfoCard(Map<String, String>.fromEntries(
          appSettings.entries.map((e) => MapEntry(e.key, e.value.toString()))
        )),
        const SizedBox(height: 24),
        _buildSectionTitle('Full RAW JSON'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              const JsonEncoder.withIndent('  ').convert(_config),
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }

  String _extractPipelineNames(dynamic pipeline) {
    if (pipeline == null) return 'N/A';
    if (pipeline is Map) {
      final funcs = pipeline['Functions'];
      if (funcs is Map) {
        return funcs.keys.join(', ');
      }
    }
    return pipeline.toString();
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 1.2,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildInfoCard(Map<String, String> data) {
    if (data.isEmpty) {
      return const Card(child: ListTile(title: Text('No data', style: TextStyle(fontStyle: FontStyle.italic))));
    }
    return Card(
      child: Column(
        children: data.entries.map((e) => ListTile(
          title: Text(e.key, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          subtitle: Text(e.value, style: const TextStyle(color: Colors.grey)),
          dense: true,
        )).toList(),
      ),
    );
  }
}
