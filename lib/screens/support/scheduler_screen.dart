import 'package:flutter/material.dart';
import '../../api/edgex_service.dart';
import '../../models/support.dart';
import '../../utils/error_handler.dart';
import 'add_interval_screen.dart';
import 'add_interval_action_screen.dart';

class SchedulerScreen extends StatefulWidget {
  const SchedulerScreen({Key? key}) : super(key: key);

  @override
  State<SchedulerScreen> createState() => _SchedulerScreenState();
}

class _SchedulerScreenState extends State<SchedulerScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final EdgeXService _service = EdgeXService();
  
  List<IntervalDef> _intervals = [];
  List<IntervalAction> _actions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final intervals = await _service.fetchIntervals();
      final actions = await _service.fetchIntervalActions();
      if (mounted) {
        setState(() {
          _intervals = intervals;
          _actions = actions;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading scheduler data: $e')),
        );
      }
    }
  }

  Future<void> _deleteInterval(String name) async {
    final confirm = await _showConfirmDialog('Delete Interval', 'Delete interval "$name"?');
    if (confirm == true) {
      try {
        await _service.deleteInterval(name);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Interval deleted'), backgroundColor: Colors.green),
        );
        _loadData();
      } catch (e) {
        EdgeXErrorHandler.showSnackBar(context, e);
      }
    }
  }

  Future<void> _deleteAction(String name) async {
    final confirm = await _showConfirmDialog('Delete Action', 'Delete interval action "$name"?');
    if (confirm == true) {
      try {
        await _service.deleteIntervalAction(name);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Action deleted'), backgroundColor: Colors.green),
        );
        _loadData();
      } catch (e) {
        EdgeXErrorHandler.showSnackBar(context, e);
      }
    }
  }

  Future<bool?> _showConfirmDialog(String title, String message) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scheduler'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Intervals'),
            Tab(text: 'Interval Actions'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildIntervalList(),
                _buildActionList(),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          bool? result;
          if (_tabController.index == 0) {
            result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddIntervalScreen()),
            );
          } else {
            result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddIntervalActionScreen()),
            );
          }
          if (result == true) {
            _loadData();
          }
        },
        child: const Icon(Icons.add),
        tooltip: _tabController.index == 0 ? 'Add Interval' : 'Add Interval Action',
      ),
    );
  }

  Widget _buildIntervalList() {
    if (_intervals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.timer_off_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No intervals found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Make sure support-scheduler service is running.'),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _intervals.length,
      itemBuilder: (context, index) {
        final interval = _intervals[index];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.timer, color: Colors.blue),
            title: Text(interval.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Frequency: ${interval.frequency}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddIntervalScreen(interval: interval),
                      ),
                    );
                    if (result == true) {
                      _loadData();
                    }
                  },
                  tooltip: 'Edit',
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _deleteInterval(interval.name),
                  tooltip: 'Delete',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionList() {
    if (_actions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.play_disabled_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No interval actions found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _actions.length,
      itemBuilder: (context, index) {
        final action = _actions[index];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.play_arrow, color: Colors.green),
            title: Text(action.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Interval: ${action.intervalName}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddIntervalActionScreen(action: action),
                      ),
                    );
                    if (result == true) {
                      _loadData();
                    }
                  },
                  tooltip: 'Edit',
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _deleteAction(action.name),
                  tooltip: 'Delete',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
