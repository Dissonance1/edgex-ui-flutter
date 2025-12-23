import 'package:flutter/material.dart';
import '../api/edgex_service.dart';
import '../models/device.dart';
import '../models/event.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final EdgeXService _service = EdgeXService();
  List<Device> _devices = [];
  List<Event> _recentEvents = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final devices = await _service.fetchDevices();
      final events = await _service.fetchEvents(limit: 5);
      if (mounted) {
        setState(() {
          _devices = devices;
          _recentEvents = events;
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
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $_error', style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final int upCount = _devices.where((d) => d.isUp).length;
    final int lockedCount = _devices.where((d) => d.isLocked).length;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Honeycomb Edge Overview',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildStatCard('Total Devices', '${_devices.length}', Colors.blue),
              const SizedBox(width: 16),
              _buildStatCard('Operational', '$upCount', Colors.green),
              const SizedBox(width: 16),
              _buildStatCard('Locked', '$lockedCount', Colors.orange),
            ],
          ),
          const SizedBox(height: 40),
          const Text(
            'Recent Events',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: _recentEvents.length,
              itemBuilder: (context, index) {
                final event = _recentEvents[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.analytics_outlined),
                    title: Text(event.deviceName),
                    subtitle: Text('${event.sourceName} - ${event.readings.length} readings'),
                    trailing: Text(event.profileName),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Expanded(
      child: Card(
        elevation: 4,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: color, width: 6)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
