import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/device.dart';
import '../models/event.dart';
import '../models/metadata.dart';
import '../models/support.dart';
import '../models/rules.dart';
import '../models/command.dart';
import '../models/app_service.dart';
import '../models/subscription.dart';

class EdgeXService {
  static const String _metadataUrl = 'http://localhost:59881/api/v3';
  static const String _dataUrl = 'http://localhost:59880/api/v3';
  static const String _commandUrl = 'http://localhost:59882/api/v3';
  static const String _schedulerUrl = 'http://localhost:59861/api/v3';
  static const String _notificationUrl = 'http://localhost:59860/api/v3';
  static const String _kuiperUrl = 'http://localhost:9081';

  // ==================== DEVICES ====================
  Future<List<Device>> fetchDevices() async {
    try {
      final response = await http.get(Uri.parse('$_metadataUrl/device/all?offset=0&limit=100'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> devicesJson = data['devices'] ?? [];
        return devicesJson.map((json) => Device.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load devices: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching devices: $e');
      throw Exception('Error fetching devices');
    }
  }

  Future<void> createDevice(Map<String, dynamic> device) async {
    try {
      final response = await http.post(
        Uri.parse('$_metadataUrl/device'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode([device]),
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Failed to create device: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error creating device: $e');
      throw Exception('Error creating device');
    }
  }

  Future<void> updateDevice(Map<String, dynamic> device) async {
    try {
      final response = await http.patch(
        Uri.parse('$_metadataUrl/device'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode([device]),
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Failed to update device: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error updating device: $e');
      throw Exception('Error updating device');
    }
  }

  Future<void> deleteDevice(String deviceName) async {
    try {
      final response = await http.delete(Uri.parse('$_metadataUrl/device/name/$deviceName'));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Failed to delete device: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting device: $e');
      throw Exception('Error deleting device');
    }
  }

  // ==================== DEVICE PROFILES ====================
  Future<List<DeviceProfile>> fetchProfiles() async {
    try {
      final response = await http.get(Uri.parse('$_metadataUrl/deviceprofile/all?offset=0&limit=100'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> profilesJson = data['profiles'] ?? [];
        return profilesJson.map((json) => DeviceProfile.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load profiles: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching profiles: $e');
      throw Exception('Error fetching profiles');
    }
  }

  Future<void> uploadProfile(String yamlContent) async {
    try {
      final response = await http.post(
        Uri.parse('$_metadataUrl/deviceprofile/uploadfile'),
        headers: {'Content-Type': 'application/x-yaml'},
        body: yamlContent,
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Failed to upload profile: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error uploading profile: $e');
      throw Exception('Error uploading profile');
    }
  }

  Future<String> fetchProfileYamlByName(String name) async {
    try {
      final response = await http.get(Uri.parse('$_metadataUrl/deviceprofile/name/$name'));
      if (response.statusCode == 200) {
        // EdgeX returns the profile object as JSON. 
        // To get YAML, we might need to rely on the server supporting a specific Accept header 
        // or just convert the JSON back to YAML in the app.
        // Actually, EdgeX UI Go usually fetches the YAML content if available or converts it.
        // For now, let's try requesting YAML.
        final yamlResponse = await http.get(
          Uri.parse('$_metadataUrl/deviceprofile/name/$name'),
          headers: {'Accept': 'application/x-yaml'},
        );
        if (yamlResponse.statusCode == 200) {
          return yamlResponse.body;
        }
        return response.body; // Fallback to JSON if YAML not supported directly
      } else {
        throw Exception('Failed to fetch profile: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching profile YAML: $e');
      throw Exception('Error fetching profile YAML');
    }
  }

  Future<void> deleteProfile(String profileName) async {
    try {
      final response = await http.delete(Uri.parse('$_metadataUrl/deviceprofile/name/$profileName'));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Failed to delete profile: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting profile: $e');
      throw Exception('Error deleting profile');
    }
  }

  // ==================== DEVICE SERVICES ====================
  Future<List<DeviceService>> fetchServices() async {
    try {
      final response = await http.get(Uri.parse('$_metadataUrl/deviceservice/all?offset=0&limit=100'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> servicesJson = data['services'] ?? [];
        return servicesJson.map((json) => DeviceService.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load services: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching services: $e');
      throw Exception('Error fetching services');
    }
  }

  // ==================== SUBSCRIPTIONS ====================
  Future<List<Subscription>> fetchSubscriptions() async {
    try {
      final response = await http.get(Uri.parse('$_notificationUrl/subscription/all?offset=0&limit=100'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> jsonList = data['subscriptions'] ?? [];
        return jsonList.map((json) => Subscription.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load subscriptions: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching subscriptions: $e');
      return [];
    }
  }

  Future<void> createSubscription(Subscription subscription) async {
    try {
      final response = await http.post(
        Uri.parse('$_notificationUrl/subscription'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode([subscription.toJson()]),
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Failed to create subscription: ${response.statusCode}');
      }
    } catch (e) {
      print('Error creating subscription: $e');
      throw Exception('Error creating subscription');
    }
  }

  Future<void> updateSubscription(Subscription subscription) async {
    try {
      final response = await http.patch(
        Uri.parse('$_notificationUrl/subscription'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode([subscription.toJson()]),
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Failed to update subscription: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error updating subscription: $e');
      throw Exception('Error updating subscription');
    }
  }

  Future<void> deleteSubscription(String subscriptionName) async {
    try {
      final response = await http.delete(Uri.parse('$_notificationUrl/subscription/name/$subscriptionName'));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Failed to delete subscription: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting subscription: $e');
      throw Exception('Error deleting subscription');
    }
  }

  // ==================== SCHEDULER - INTERVALS ====================
  Future<List<IntervalDef>> fetchIntervals() async {
    try {
      final response = await http.get(Uri.parse('$_schedulerUrl/interval/all?offset=0&limit=100'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> jsonList = data['intervals'] ?? [];
        return jsonList.map((json) => IntervalDef.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load intervals: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching intervals');
    }
  }

  Future<void> createInterval(Map<String, dynamic> interval) async {
    try {
      final response = await http.post(
        Uri.parse('$_schedulerUrl/interval'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode([interval]),
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Failed to create interval: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error creating interval: $e');
      throw Exception('Error creating interval');
    }
  }

  Future<void> updateInterval(Map<String, dynamic> interval) async {
    try {
      final response = await http.patch(
        Uri.parse('$_schedulerUrl/interval'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode([interval]),
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Failed to update interval: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error updating interval: $e');
      throw Exception('Error updating interval');
    }
  }

  Future<void> deleteInterval(String intervalName) async {
    try {
      final response = await http.delete(Uri.parse('$_schedulerUrl/interval/name/$intervalName'));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Failed to delete interval: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting interval: $e');
      throw Exception('Error deleting interval');
    }
  }

  // ==================== SCHEDULER - INTERVAL ACTIONS ====================
  Future<List<IntervalAction>> fetchIntervalActions() async {
    try {
      final response = await http.get(Uri.parse('$_schedulerUrl/intervalaction/all?offset=0&limit=100'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> jsonList = data['actions'] ?? [];
        return jsonList.map((json) => IntervalAction.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load interval actions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching interval actions');
    }
  }

  Future<void> createIntervalAction(Map<String, dynamic> action) async {
    try {
      final response = await http.post(
        Uri.parse('$_schedulerUrl/intervalaction'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode([action]),
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Failed to create interval action: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error creating interval action: $e');
      throw Exception('Error creating interval action');
    }
  }

  Future<void> updateIntervalAction(Map<String, dynamic> action) async {
    try {
      final response = await http.patch(
        Uri.parse('$_schedulerUrl/intervalaction'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode([action]),
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Failed to update interval action: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error updating interval action: $e');
      throw Exception('Error updating interval action');
    }
  }

  Future<void> deleteIntervalAction(String actionName) async {
    try {
      final response = await http.delete(Uri.parse('$_schedulerUrl/intervalaction/name/$actionName'));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Failed to delete interval action: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting interval action: $e');
      throw Exception('Error deleting interval action');
    }
  }

  // ==================== NOTIFICATIONS ====================
  Future<List<EdgedXNotification>> fetchNotifications() async {
    try {
      final response = await http.get(Uri.parse('$_notificationUrl/notification/status/NEW?offset=0&limit=50'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> jsonList = data['notifications'] ?? [];
        return jsonList.map((json) => EdgedXNotification.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load notifications: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching notifications: $e');
      throw Exception('Error fetching notifications');
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      final response = await http.delete(Uri.parse('$_notificationUrl/notification/id/$notificationId'));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Failed to delete notification: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting notification: $e');
      throw Exception('Error deleting notification');
    }
  }

  Future<void> cleanupNotifications() async {
    try {
      final response = await http.delete(Uri.parse('$_notificationUrl/notification/age/0'));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Failed to cleanup notifications: ${response.statusCode}');
      }
    } catch (e) {
      print('Error cleaning up notifications: $e');
      throw Exception('Error cleaning up notifications');
    }
  }

  // ==================== RULES ENGINE - STREAMS ====================
  Future<List<KuiperStream>> fetchStreams() async {
    try {
      final response = await http.get(Uri.parse('$_kuiperUrl/streams'));
      if (response.statusCode == 200) {
        final List<dynamic> streamNames = json.decode(response.body);
        final List<KuiperStream> streams = [];
        for (var name in streamNames) {
          try {
            final detailResponse = await http.get(Uri.parse('$_kuiperUrl/streams/$name'));
            if (detailResponse.statusCode == 200) {
              final detail = json.decode(detailResponse.body);
              streams.add(KuiperStream.fromJson(detail, name));
            } else {
              streams.add(KuiperStream(name: name, sql: 'Error loading SQL'));
            }
          } catch (e) {
            streams.add(KuiperStream(name: name, sql: 'Error connecting'));
          }
        }
        return streams;
      } else {
        throw Exception('Failed to load streams: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching streams: $e');
      return [];
    }
  }

  Future<void> createStream(String sql) async {
    try {
      final response = await http.post(
        Uri.parse('$_kuiperUrl/streams'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'sql': sql}),
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Failed to create stream: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error creating stream: $e');
      throw Exception('Error creating stream');
    }
  }

  Future<void> updateStream(String name, String sql) async {
    try {
      final response = await http.put(
        Uri.parse('$_kuiperUrl/streams/$name'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'sql': sql}),
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Failed to update stream: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error updating stream: $e');
      throw Exception('Error updating stream');
    }
  }

  Future<void> deleteStream(String streamName) async {
    try {
      final response = await http.delete(Uri.parse('$_kuiperUrl/streams/$streamName'));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Failed to delete stream: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting stream: $e');
      throw Exception('Error deleting stream');
    }
  }

  // ==================== RULES ENGINE - RULES ====================
  Future<List<KuiperRule>> fetchRules() async {
    try {
      final response = await http.get(Uri.parse('$_kuiperUrl/rules'));
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => KuiperRule.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load rules: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching rules: $e');
      return [];
    }
  }

  Future<void> createRule(String id, String sql, List<Map<String, dynamic>> actions) async {
    try {
      final response = await http.post(
        Uri.parse('$_kuiperUrl/rules'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'id': id,
          'sql': sql,
          'actions': actions,
        }),
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Failed to create rule: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error creating rule: $e');
      throw Exception('Error creating rule');
    }
  }

  Future<void> deleteRule(String ruleId) async {
    try {
      final response = await http.delete(Uri.parse('$_kuiperUrl/rules/$ruleId'));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Failed to delete rule: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting rule: $e');
      throw Exception('Error deleting rule');
    }
  }

  Future<void> startRule(String ruleId) async {
    try {
      final response = await http.post(Uri.parse('$_kuiperUrl/rules/$ruleId/start'));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Failed to start rule: ${response.statusCode}');
      }
    } catch (e) {
      print('Error starting rule: $e');
      throw Exception('Error starting rule');
    }
  }

  Future<void> stopRule(String ruleId) async {
    try {
      final response = await http.post(Uri.parse('$_kuiperUrl/rules/$ruleId/stop'));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Failed to stop rule: ${response.statusCode}');
      }
    } catch (e) {
      print('Error stopping rule: $e');
      throw Exception('Error stopping rule');
    }
  }

  // ==================== EVENTS ====================
  Future<List<Event>> fetchEvents({int limit = 20}) async {
    try {
      final response = await http.get(Uri.parse('$_dataUrl/event/all?limit=$limit&desc=true'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> eventsJson = data['events'] ?? [];
        return eventsJson.map((json) => Event.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load events: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching events: $e');
      throw Exception('Error fetching events');
    }
  }

  // ==================== COMMANDS ====================
  Future<void> executeCommand(String deviceName, String commandName, String method, {Map<String, dynamic>? body}) async {
    final url = '$_commandUrl/device/name/$deviceName/command/$commandName';
    try {
      http.Response response;
      if (method.toUpperCase() == 'GET') {
        response = await http.get(Uri.parse(url));
      } else {
        response = await http.put(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(body),
        );
      }
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('Command executed successfully');
      } else {
        throw Exception('Command failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error executing command: $e');
      throw Exception('Error executing command');
    }
  }

  Future<List<CoreCommand>> fetchDeviceCoreCommands(String deviceName) async {
    try {
      final response = await http.get(Uri.parse('$_commandUrl/device/name/$deviceName'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final Map<String, dynamic> deviceCoreCommand = data['deviceCoreCommand'] ?? {};
        final List<dynamic> commandsJson = deviceCoreCommand['coreCommands'] ?? [];
        return commandsJson.map((json) => CoreCommand.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load commands: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching commands: $e');
      throw Exception('Error fetching commands');
    }
  }

  // ==================== APP SERVICES ====================
  Future<List<AppService>> fetchAppServices() async {
    try {
      final response = await http.get(Uri.parse('$_metadataUrl/deviceservice/all?offset=0&limit=100'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> servicesJson = data['services'] ?? [];
        
        // EdgeX App Services are usually registered with core-metadata
        // They often start with 'app-' or are specifically tagged.
        // We'll also try to fetch from registry-center if available in future steps.
        final appServices = servicesJson
            .where((json) {
              final name = json['name']?.toString() ?? '';
              return name.startsWith('app-') || name.contains('app-service');
            })
            .map((json) => AppService.fromJson(json))
            .toList();
        return appServices;
      } else {
        throw Exception('Failed to load app services: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching app services: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> fetchAppServiceConfig(String serviceKey) async {
    // Registry Service (e.g., Consul or Keeper) usually provides the config
    // In EdgeX V3, we can often hit the service's own /api/v3/config if exposed
    // or use the Registry Center API if edgex-ui-go uses it.
    try {
      // First attempt: Try the service's own config endpoint via UI backend proxy or directly
      // Since we are a client UI, we might need a specific proxy or know the service port.
      // For now, let's assume we can fetch it via the registry center proxy if available
      // or directly if the host/port is known.
      
      // edgex-ui-go uses: /api/v3/registrycenter/config/{serviceKey}
      // Note: This requires the edgex-ui-go backend or similar proxy.
      // If running locally, we might need to hit the service directly if we can resolve its address.
      
      final response = await http.get(Uri.parse('http://localhost:59890/api/v3/registry/config/$serviceKey'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      
      // Fallback: search for the service endpoint and hit it directly
      // This is a placeholder for more complex service discovery.
      throw Exception('Failed to fetch config for $serviceKey: ${response.statusCode}');
    } catch (e) {
      print('Error fetching app service config: $e');
      rethrow;
    }
  }
}
