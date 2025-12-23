class CoreCommand {
  final String name;
  final bool get;
  final bool set;
  final String path;
  final String url;
  final List<CoreCommandParameter> parameters;

  CoreCommand({
    required this.name,
    required this.get,
    required this.set,
    required this.path,
    required this.url,
    required this.parameters,
  });

  factory CoreCommand.fromJson(Map<String, dynamic> json) {
    return CoreCommand(
      name: json['name'] ?? '',
      get: json['get'] ?? false,
      set: json['set'] ?? false,
      path: json['path'] ?? '',
      url: json['url'] ?? '',
      parameters: (json['parameters'] as List?)
          ?.map((e) => CoreCommandParameter.fromJson(e))
          .toList() ?? [],
    );
  }
}

class CoreCommandParameter {
  final String resourceName;
  final String valueType;

  CoreCommandParameter({
    required this.resourceName,
    required this.valueType,
  });

  factory CoreCommandParameter.fromJson(Map<String, dynamic> json) {
    return CoreCommandParameter(
      resourceName: json['resourceName'] ?? '',
      valueType: json['valueType'] ?? '',
    );
  }
}
