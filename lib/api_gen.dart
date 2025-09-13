library;

/// The `api_gen` package provides tools for generating Dart models and API clients
/// from various data sources such as JSON schemas and API definitions.
///
/// This library exports the main model generator, API client, legacy model generator,
/// exception handling, and result types for use in your Dart projects.

export 'src/generate/model_generator.dart';
export 'src/api_client.dart';

export 'src/exception/exception.dart';
export 'src/result/result.dart';
