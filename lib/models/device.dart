class Device {
  final String id;
  final String name;
  final String serviceName;
  final String profileName;
  final String description;
  final String adminState;
  final String operatingState;
  final List<String> labels;

  Device({
    required this.id,
    required this.name,
    required this.serviceName,
    required this.profileName,
    required this.description,
    required this.adminState,
    required this.operatingState,
    required this.labels,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      serviceName: json['serviceName'] ?? '',
      profileName: json['profileName'] ?? '',
      description: json['description'] ?? '',
      adminState: json['adminState'] ?? 'UNKNOWN',
      operatingState: json['operatingState'] ?? 'UNKNOWN',
      labels: List<String>.from(json['labels'] ?? []),
    );
  }

  bool get isUp => operatingState == 'UP';
  bool get isLocked => adminState == 'LOCKED';
}
