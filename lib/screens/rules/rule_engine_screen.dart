import 'package:flutter/material.dart';
import '../../api/edgex_service.dart';
import '../../models/rules.dart';
import '../../utils/error_handler.dart';
import 'add_stream_screen.dart';
import 'add_rule_screen.dart';

class RuleEngineScreen extends StatefulWidget {
  const RuleEngineScreen({Key? key}) : super(key: key);

  @override
  State<RuleEngineScreen> createState() => _RuleEngineScreenState();
}

class _RuleEngineScreenState extends State<RuleEngineScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final EdgeXService _service = EdgeXService();
  
  List<KuiperStream> _streams = [];
  List<KuiperRule> _rules = [];
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
      final results = await Future.wait([
        _service.fetchStreams(),
        _service.fetchRules(),
      ]);
      
      if (mounted) {
        setState(() {
          _streams = results[0] as List<KuiperStream>;
          _rules = results[1] as List<KuiperRule>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading rules engine: $e. Is eKuiper running?'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _deleteStream(String name) async {
    final confirm = await _showConfirmDialog('Delete Stream', 'Delete stream "$name"?');
    if (confirm == true) {
      try {
        await _service.deleteStream(name);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Stream deleted'), backgroundColor: Colors.green),
        );
        _loadData();
      } catch (e) {
        EdgeXErrorHandler.showSnackBar(context, e);
      }
    }
  }

  Future<void> _deleteRule(String id) async {
    final confirm = await _showConfirmDialog('Delete Rule', 'Delete rule "$id"?');
    if (confirm == true) {
      try {
        await _service.deleteRule(id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rule deleted'), backgroundColor: Colors.green),
        );
        _loadData();
      } catch (e) {
        EdgeXErrorHandler.showSnackBar(context, e);
      }
    }
  }

  Future<void> _toggleRule(KuiperRule rule) async {
    try {
      if (rule.status.toLowerCase() == 'running') {
        await _service.stopRule(rule.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rule stopped'), backgroundColor: Colors.orange),
        );
      } else {
        await _service.startRule(rule.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rule started'), backgroundColor: Colors.green),
        );
      }
      _loadData();
    } catch (e) {
      EdgeXErrorHandler.showSnackBar(context, e);
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
        title: const Text('Rules Engine'),
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
            Tab(text: 'Streams'),
            Tab(text: 'Rules'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildStreamList(),
                _buildRuleList(),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          bool? result;
          if (_tabController.index == 0) {
            result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddStreamScreen()),
            );
          } else {
            result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddRuleScreen()),
            );
          }
          if (result == true) {
            _loadData();
          }
        },
        child: const Icon(Icons.add),
        tooltip: _tabController.index == 0 ? 'Add Stream' : 'Add Rule',
      ),
    );
  }

  Widget _buildStreamList() {
    if (_streams.isEmpty) {
      return const Center(child: Text('No streams found.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _streams.length,
      itemBuilder: (context, index) {
        final stream = _streams[index];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.waves, color: Colors.blue),
            title: Text(stream.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(stream.sql),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddStreamScreen(stream: stream),
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
                  onPressed: () => _deleteStream(stream.name),
                  tooltip: 'Delete',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRuleList() {
    if (_rules.isEmpty) {
      return const Center(child: Text('No rules found.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _rules.length,
      itemBuilder: (context, index) {
        final rule = _rules[index];
        final isRunning = rule.status.toLowerCase() == 'running';
        return Card(
          child: ListTile(
            leading: Icon(
              Icons.gavel, 
              color: isRunning ? Colors.green : Colors.grey
            ),
            title: Text(rule.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(rule.sql),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(isRunning ? Icons.stop : Icons.play_arrow),
                  onPressed: () => _toggleRule(rule),
                  tooltip: isRunning ? 'Stop' : 'Start',
                  color: isRunning ? Colors.orange : Colors.green,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _deleteRule(rule.id),
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
