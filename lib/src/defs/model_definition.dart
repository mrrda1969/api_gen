import 'property_definition.dart';

/// Represents a Dart model definition parsed from a schema.
class ModelDefinition {
  /// The model name.
  final String name;

  /// The list of properties in the model.
  final List<PropertyDefinition> properties;

  /// Creates a [ModelDefinition].
  ModelDefinition({required this.name, required this.properties});
}
