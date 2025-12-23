class DeviceProfile {
  final String id;
  final String name;
  final String description;
  final String manufacturer;
  final String model;
  final List<String> labels;

  DeviceProfile({
    required this.id,
    required this.name,
    required this.description,
    required this.manufacturer,
    required this.model,
    required this.labels,
  });

  factory DeviceProfile.fromJson(Map<String, dynamic> json) {
    return DeviceProfile(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      manufacturer: json['manufacturer'] ?? '',
      model: json['model'] ?? '',
      labels: (json['labels'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

class DeviceService {
  final String id;
  final String name;
  final String description;
  final String adminState;
  final String operatingState;
  final String baseAddress;
  final List<String> labels;

  DeviceService({
    required this.id,
    required this.name,
    required this.description,
    required this.adminState,
    required this.operatingState,
    required this.baseAddress,
    required this.labels,
  });

  factory DeviceService.fromJson(Map<String, dynamic> json) {
    return DeviceService(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      adminState: json['adminState'] ?? 'UNKNOWN',
      operatingState: json['operatingState'] ?? 'UNKNOWN',
      baseAddress: json['baseAddress'] ?? '',
      labels: (json['labels'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  bool get isUp => operatingState == 'UP';
}
