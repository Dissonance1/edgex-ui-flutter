class IntervalDef {
  final String id;
  final String name;
  final String start;
  final String end;
  final String frequency;

  IntervalDef({
    required this.id,
    required this.name,
    required this.start,
    required this.end,
    required this.frequency,
  });

  factory IntervalDef.fromJson(Map<String, dynamic> json) {
    return IntervalDef(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      start: json['start'] ?? '',
      end: json['end'] ?? '',
      frequency: json['frequency'] ?? '',
    );
  }
}

class IntervalAction {
  final String id;
  final String name;
  final String intervalName;
  final String address;
  final String content;
  final String adminState;

  IntervalAction({
    required this.id,
    required this.name,
    required this.intervalName,
    required this.address,
    required this.content,
    required this.adminState,
  });

  factory IntervalAction.fromJson(Map<String, dynamic> json) {
    return IntervalAction(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      intervalName: json['intervalName'] ?? '',
      address: json['address']?.toString() ?? '',
      content: json['content'] ?? '',
      adminState: json['adminState'] ?? 'UNLOCKED',
    );
  }
}

class EdgedXNotification {
  final String id;
  final String content;
  final String sender;
  final String category;
  final String severity;
  final String status;
  final int created;

  EdgedXNotification({
    required this.id,
    required this.content,
    required this.sender,
    required this.category,
    required this.severity,
    required this.status,
    required this.created,
  });

  factory EdgedXNotification.fromJson(Map<String, dynamic> json) {
    return EdgedXNotification(
      id: json['id'] ?? '',
      content: json['content'] ?? '',
      sender: json['sender'] ?? '',
      category: json['category'] ?? '',
      severity: json['severity'] ?? 'NORMAL',
      status: json['status'] ?? 'NEW',
      created: json['created'] ?? 0,
    );
  }
}
