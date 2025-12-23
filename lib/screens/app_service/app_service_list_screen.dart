import 'package:flutter/material.dart';
import '../../api/edgex_service.dart';
import '../../models/app_service.dart';
import 'app_service_detail_screen.dart';

class AppServiceListScreen extends StatefulWidget {
  const AppServiceListScreen({Key? key}) : super(key: key);

  @override
  State<AppServiceListScreen> createState() => _AppServiceListScreenState();
}

class _AppServiceListScreenState extends State<AppServiceListScreen> {
  final EdgeXService _service = EdgeXService();
  List<AppService> _appServices = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAppServices();
  }

  Future<void> _fetchAppServices() async {
    try {
      final services = await _service.fetchAppServices();
      if (mounted) {
        setState(() {
          _appServices = services;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading app services: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Application Services'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchAppServices,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _appServices.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.apps, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No Application Services Found',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Application services will appear here when registered',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _appServices.length,
                  itemBuilder: (context, index) {
                    final service = _appServices[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AppServiceDetailScreen(service: service),
                            ),
                          );
                        },
                        leading: Icon(
                          Icons.apps,
                          color: service.isUp ? Colors.green : Colors.red,
                          size: 32,
                        ),
                        title: Text(
                          service.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text('Address: ${service.baseAddress}'),
                            Text('Service Key: ${service.serviceKey}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Chip(
                                  label: Text(service.operatingState),
                                  backgroundColor: service.isUp
                                      ? Colors.green.withOpacity(0.1)
                                      : Colors.red.withOpacity(0.1),
                                  labelStyle: TextStyle(
                                    color: service.isUp ? Colors.green : Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Chip(
                                  label: Text(service.adminState),
                                  backgroundColor: service.isLocked
                                      ? Colors.orange.withOpacity(0.1)
                                      : Colors.blue.withOpacity(0.1),
                                  labelStyle: TextStyle(
                                    color: service.isLocked ? Colors.orange : Colors.blue,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const Icon(Icons.chevron_right, color: Colors.grey),
                          ],
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
    );
  }
}
