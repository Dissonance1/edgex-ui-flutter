import 'package:flutter/material.dart';
import '../../api/edgex_service.dart';
import '../../models/metadata.dart';
import '../../utils/error_handler.dart';
import 'add_profile_screen.dart';

class ProfileListScreen extends StatefulWidget {
  const ProfileListScreen({Key? key}) : super(key: key);

  @override
  State<ProfileListScreen> createState() => _ProfileListScreenState();
}

class _ProfileListScreenState extends State<ProfileListScreen> {
  final EdgeXService _service = EdgeXService();
  List<DeviceProfile> _profiles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfiles();
  }

  Future<void> _fetchProfiles() async {
    setState(() => _isLoading = true);
    try {
      final profiles = await _service.fetchProfiles();
      if (mounted) {
        setState(() {
          _profiles = profiles;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profiles: $e')),
        );
      }
    }
  }

  Future<void> _deleteProfile(String profileName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Profile'),
        content: Text('Delete profile "$profileName"?'),
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
    if (confirm == true) {
      try {
        await _service.deleteProfile(profileName);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile deleted'), backgroundColor: Colors.green),
        );
        _fetchProfiles();
      } catch (e) {
        EdgeXErrorHandler.showSnackBar(context, e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Profiles'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchProfiles,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _profiles.length,
              itemBuilder: (context, index) {
                final profile = _profiles[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const Icon(Icons.description, color: Colors.purple),
                    title: Text(profile.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${profile.manufacturer} ${profile.model}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Chip(label: Text('${profile.labels.length} labels')),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddProfileScreen(profile: profile),
                              ),
                            );
                            if (result == true) {
                              _fetchProfiles();
                            }
                          },
                          tooltip: 'Edit',
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _deleteProfile(profile.name),
                          tooltip: 'Delete',
                        ),
                      ],
                    ),
                    onTap: () {
                      // TODO: Navigate to detail view or show YAML
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddProfileScreen()),
          );
          if (result == true) {
            _fetchProfiles();
          }
        },
        child: const Icon(Icons.add),
        tooltip: 'Upload Profile',
      ),
    );
  }
}
