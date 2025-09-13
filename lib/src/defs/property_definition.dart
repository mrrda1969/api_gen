/// Represents a property in a Dart model.
class PropertyDefinition {
  /// The property name.
  final String name;

  /// The Dart type of the property.
  final String dartType;

  /// Whether the property is required.
  final bool isRequired;

  /// Whether the property is nullable.
  final bool isNullable;

  /// The list of enum values, if the property is an enum.
  final List<String>? enumValues;

  /// Creates a [PropertyDefinition].
  PropertyDefinition({
    required this.name,
    required this.dartType,
    required this.isRequired,
    required this.isNullable,
    this.enumValues,
  });
}
