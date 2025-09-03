class PropertyDefinition {
  final String name;
  final String dartType;
  final bool isRequired;
  final bool isNullable;
  final List<String>? enumValues;

  PropertyDefinition({
    required this.name,
    required this.dartType,
    required this.isRequired,
    required this.isNullable,
    this.enumValues,
  });
}
