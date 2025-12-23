class AppService {
  final String name;
  final String baseAddress;
  final String adminState;
  final String operatingState;
  final int lastConnected;
  final String serviceKey;

  AppService({
    required this.name,
    required this.baseAddress,
    required this.adminState,
    required this.operatingState,
    required this.lastConnected,
    required this.serviceKey,
  });

  factory AppService.fromJson(Map<String, dynamic> json) {
    return AppService(
      name: json['name'] ?? '',
      baseAddress: json['baseAddress'] ?? '',
      adminState: json['adminState'] ?? 'UNLOCKED',
      operatingState: json['operatingState'] ?? 'UP',
      lastConnected: json['lastConnected'] ?? 0,
      serviceKey: json['serviceKey'] ?? '',
    );
  }

  bool get isUp => operatingState == 'UP';
  bool get isLocked => adminState == 'LOCKED';
}
