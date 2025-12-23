class Subscription {
  final String id;
  final String name;
  final List<String> channels;
  final String receiver;
  final List<String> categories;
  final List<String> labels;
  final String description;
  final bool resendOnChange;
  final int resendLimit;
  final String resendInterval;

  Subscription({
    required this.id,
    required this.name,
    required this.channels,
    required this.receiver,
    required this.categories,
    required this.labels,
    required this.description,
    required this.resendOnChange,
    required this.resendLimit,
    required this.resendInterval,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      channels: List<String>.from(json['channels'] ?? []),
      receiver: json['receiver'] ?? '',
      categories: List<String>.from(json['categories'] ?? []),
      labels: List<String>.from(json['labels'] ?? []),
      description: json['description'] ?? '',
      resendOnChange: json['resendOnChange'] ?? false,
      resendLimit: json['resendLimit'] ?? 0,
      resendInterval: json['resendInterval'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'channels': channels,
      'receiver': receiver,
      'categories': categories,
      'labels': labels,
      'description': description,
      'resendOnChange': resendOnChange,
      'resendLimit': resendLimit,
      'resendInterval': resendInterval,
    };
  }
}
