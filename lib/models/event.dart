class Reading {
  final String id;
  final String resourceName;
  final String deviceName;
  final String profileName;
  final String value;
  final String valueType;
  final int origin;

  Reading({
    required this.id,
    required this.resourceName,
    required this.deviceName,
    required this.profileName,
    required this.value,
    required this.valueType,
    required this.origin,
  });

  factory Reading.fromJson(Map<String, dynamic> json) {
    return Reading(
      id: json['id'] ?? '',
      resourceName: json['resourceName'] ?? '',
      deviceName: json['deviceName'] ?? '',
      profileName: json['profileName'] ?? '',
      value: json['value'] ?? '',
      valueType: json['valueType'] ?? '',
      origin: json['origin'] ?? 0,
    );
  }
}

class Event {
  final String id;
  final String deviceName;
  final String profileName;
  final String sourceName;
  final int origin;
  final List<Reading> readings;

  Event({
    required this.id,
    required this.deviceName,
    required this.profileName,
    required this.sourceName,
    required this.origin,
    required this.readings,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    var readingsList = (json['readings'] as List?)?.map((r) => Reading.fromJson(r)).toList() ?? [];
    return Event(
      id: json['id'] ?? '',
      deviceName: json['deviceName'] ?? '',
      profileName: json['profileName'] ?? '',
      sourceName: json['sourceName'] ?? '',
      origin: json['origin'] ?? 0,
      readings: readingsList,
    );
  }
}
