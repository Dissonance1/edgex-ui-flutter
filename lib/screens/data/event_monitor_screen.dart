import 'package:flutter/material.dart';
import '../../api/edgex_service.dart';
import '../../models/event.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class EventMonitorScreen extends StatefulWidget {
  const EventMonitorScreen({Key? key}) : super(key: key);

  @override
  State<EventMonitorScreen> createState() => _EventMonitorScreenState();
}

class _EventMonitorScreenState extends State<EventMonitorScreen> {
  final EdgeXService _service = EdgeXService();
  List<Event> _events = [];
  bool _isLoading = true;
  Timer? _timer;
  bool _autoRefresh = true;

  @override
  void initState() {
    super.initState();
    _fetchEvents();
    _startAutoRefresh();
  }

  void _startAutoRefresh() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_autoRefresh) {
        _fetchEvents(silent: true);
      }
    });
  }

  Future<void> _fetchEvents({bool silent = false}) async {
    try {
      final events = await _service.fetchEvents(limit: 50);
      if (mounted) {
        setState(() {
          _events = events;
          if (!silent) _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted && !silent) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Monitor'),
        actions: [
          IconButton(
            icon: Icon(_autoRefresh ? Icons.pause : Icons.play_arrow),
            onPressed: () {
              setState(() {
                _autoRefresh = !_autoRefresh;
              });
            },
            tooltip: _autoRefresh ? 'Pause Auto-Refresh' : 'Resume Auto-Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _fetchEvents(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _events.length,
              itemBuilder: (context, index) {
                final event = _events[index];
                // Event origin is usually in nanoseconds
                final DateTime date = DateTime.fromMillisecondsSinceEpoch((event.origin / 1000000).round());
                final String formattedDate = DateFormat('HH:mm:ss.SSS').format(date);

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ExpansionTile(
                    leading: const Icon(Icons.data_usage, color: Colors.blue),
                    title: Text('${event.deviceName} / ${event.sourceName}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Profile: ${event.profileName} • $formattedDate'),
                    children: event.readings.map((reading) {
                      return ListTile(
                        dense: true,
                        leading: const Icon(Icons.sensors, size: 16),
                        title: Text(reading.resourceName),
                        trailing: Text(
                          '${reading.value} ${reading.valueType}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
