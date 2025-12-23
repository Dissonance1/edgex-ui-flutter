class KuiperStream {
  final String name;
  final String sql;

  KuiperStream({required this.name, required this.sql});

  factory KuiperStream.fromJson(Map<String, dynamic> json, String name) {
    return KuiperStream(
      name: name,
      sql: json.toString(), // Simplified for now
    );
  }
}

class KuiperRule {
  final String id;
  final String name;
  final String sql;
  final String status;

  KuiperRule({
    required this.id,
    required this.name,
    required this.sql,
    required this.status,
  });

  factory KuiperRule.fromJson(Map<String, dynamic> json) {
    return KuiperRule(
      id: json['id'] ?? '',
      name: json['original_rule_id'] ?? json['id'] ?? '', // Fallback
      sql: json['sql'] ?? '',
      status: json['status'] ?? 'stopped', // Varies by version
    );
  }
}
