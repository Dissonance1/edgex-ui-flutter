import 'package:flutter/material.dart';
import '../../api/edgex_service.dart';
import '../../models/support.dart';
import '../../models/subscription.dart';
import 'package:intl/intl.dart';
import '../../utils/error_handler.dart';
import 'add_subscription_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final EdgeXService _service = EdgeXService();
  List<EdgedXNotification> _notifications = [];
  List<Subscription> _subscriptions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _service.fetchNotifications(),
        _service.fetchSubscriptions(),
      ]);
      if (mounted) {
        setState(() {
          _notifications = results[0] as List<EdgedXNotification>;
          _subscriptions = results[1] as List<Subscription>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        // Show error only if it's not a 404 (service might not be configured)
        if (!e.toString().contains('404')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading data: $e'), backgroundColor: Colors.orange),
          );
        }
      }
    }
  }

  Future<void> _deleteNotification(String id) async {
    final confirm = await _showConfirmDialog('Delete Notification', 'Are you sure you want to delete this notification?');
    if (confirm == true) {
      try {
        await _service.deleteNotification(id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification deleted'), backgroundColor: Colors.green),
        );
        _fetchData();
      } catch (e) {
        EdgeXErrorHandler.showSnackBar(context, e);
      }
    }
  }

  Future<void> _cleanupNotifications() async {
    final confirm = await _showConfirmDialog('Cleanup Notifications', 'Delete all processed notifications?');
    if (confirm == true) {
      try {
        await _service.cleanupNotifications();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notifications cleaned up'), backgroundColor: Colors.green),
        );
        _fetchData();
      } catch (e) {
        EdgeXErrorHandler.showSnackBar(context, e);
      }
    }
  }

  Future<void> _deleteSubscription(String name) async {
    final confirm = await _showConfirmDialog('Delete Subscription', 'Are you sure you want to delete subscription "$name"?');
    if (confirm == true) {
      try {
        await _service.deleteSubscription(name);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Subscription deleted'), backgroundColor: Colors.green),
        );
        _fetchData();
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
        title: const Text('Notifications'),
        actions: [
          if (_tabController.index == 0)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: _cleanupNotifications,
              tooltip: 'Cleanup Old',
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchData,
            tooltip: 'Refresh',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Notifications'),
            Tab(text: 'Subscriptions'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildNotificationList(),
                _buildSubscriptionList(),
              ],
            ),
      floatingActionButton: _tabController.index == 1
          ? FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddSubscriptionScreen()),
                );
                if (result == true) {
                  _fetchData();
                }
              },
              child: const Icon(Icons.add),
              tooltip: 'Add Subscription',
            )
          : null,
    );
  }

  Widget _buildNotificationList() {
    if (_notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No notifications found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Make sure support-notifications service is running.'),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _fetchData, child: const Text('Retry')),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _notifications.length,
      itemBuilder: (context, index) {
        final notification = _notifications[index];
        final DateTime date = DateTime.fromMillisecondsSinceEpoch(notification.created);
        final String formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(date);

        Color severityColor = Colors.blue;
        if (notification.severity == 'CRITICAL') severityColor = Colors.red;
        if (notification.severity == 'NORMAL') severityColor = Colors.green;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        notification.sender,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      formattedDate,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      onPressed: () => _deleteNotification(notification.id),
                      tooltip: 'Delete',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(notification.content),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Chip(
                      label: Text(notification.severity),
                      backgroundColor: severityColor.withOpacity(0.1),
                      labelStyle: TextStyle(color: severityColor),
                    ),
                    const SizedBox(width: 8),
                    Chip(label: Text(notification.category)),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubscriptionList() {
    if (_subscriptions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.subscriptions_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No subscriptions found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _fetchData, child: const Text('Retry')),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _subscriptions.length,
      itemBuilder: (context, index) {
        final sub = _subscriptions[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const Icon(Icons.subscriptions, color: Colors.blue),
            title: Text(sub.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Receiver: ${sub.receiver}'),
                Text('Channels: ${sub.channels.join(", ")}'),
                if (sub.categories.isNotEmpty) Text('Categories: ${sub.categories.join(", ")}'),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddSubscriptionScreen(subscription: sub),
                      ),
                    );
                    if (result == true) {
                      _fetchData();
                    }
                  },
                  tooltip: 'Edit',
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _deleteSubscription(sub.name),
                  tooltip: 'Delete',
                ),
              ],
            ),
            isThreeLine: true,
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
