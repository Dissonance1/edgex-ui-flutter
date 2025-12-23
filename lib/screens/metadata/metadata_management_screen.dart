import 'package:flutter/material.dart';
import '../device_list_screen.dart';
import 'profile_list_screen.dart';
import 'service_list_screen.dart';

class MetadataManagementScreen extends StatefulWidget {
  const MetadataManagementScreen({Key? key}) : super(key: key);

  @override
  State<MetadataManagementScreen> createState() => _MetadataManagementScreenState();
}

class _MetadataManagementScreenState extends State<MetadataManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Metadata Management'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Devices', icon: Icon(Icons.devices)),
            Tab(text: 'Profiles', icon: Icon(Icons.description)),
            Tab(text: 'Services', icon: Icon(Icons.router)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          DeviceListScreen(),
          ProfileListScreen(),
          ServiceListScreen(),
        ],
      ),
    );
  }
}
