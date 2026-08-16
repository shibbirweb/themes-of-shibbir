// Dart sample: null safety, mixins, async streams, cascades, Flutter-style code.

import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

const String defaultHex = '#EEFFFF';
const int maxDepth = 8;

final RegExp hexPattern = RegExp(r'^#(?:[0-9a-fA-F]{3}){1,2}$');

enum TokenKind {
  comment('comment'),
  keyword('keyword'),
  stringLiteral('string'),
  number('constant.numeric');

  const TokenKind(this.scope);

  final String scope;

  bool get isItalic => this == TokenKind.comment;
}

class InvalidHexException implements Exception {
  InvalidHexException(this.hex);

  final String hex;

  @override
  String toString() => 'InvalidHexException: $hex';
}

mixin Describable {
  String get label;

  String describe();

  String shout() => describe().toUpperCase();
}

class Swatch with Describable {
  Swatch({
    required this.label,
    this.hex = defaultHex,
    List<String>? tags,
  })  : tags = tags ?? <String>[] {
    if (!hexPattern.hasMatch(hex)) {
      throw InvalidHexException(hex);
    }
  }

  factory Swatch.fromJson(Map<String, dynamic> json) => Swatch(
        label: json['label'] as String,
        hex: json['hex'] as String? ?? defaultHex,
        tags: (json['tags'] as List<dynamic>?)?.cast<String>(),
      );

  @override
  final String label;

  final String hex;
  final List<String> tags;

  double get luminance {
    final value = int.parse(hex.substring(1), radix: 16);
    final red = (value >> 16) & 0xFF;
    final green = (value >> 8) & 0xFF;
    final blue = value & 0xFF;

    return (0.2126 * red + 0.7152 * green + 0.0722 * blue) / 255;
  }

  bool get isDark => luminance < 0.5;

  @override
  String describe() => '$label => $hex';

  Map<String, dynamic> toJson() => <String, dynamic>{
        'label': label,
        'hex': hex,
        'tags': tags,
      };
}

class Registry {
  Registry(this.name, {this.strict = false});

  final String name;
  final bool strict;
  final Map<String, Swatch> _swatches = <String, Swatch>{};

  int get size => _swatches.length;

  Swatch? operator [](String label) => _swatches[label];

  void operator []=(String label, Swatch swatch) => _swatches[label] = swatch;

  void add(Swatch swatch) => _swatches[swatch.label] = swatch;

  List<String> sortedLabels() => _swatches.values
      .where((swatch) => swatch.hex != defaultHex)
      .map((swatch) => swatch.label)
      .toList()
    ..sort();

  Stream<Swatch> watch() async* {
    for (final swatch in _swatches.values) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
      yield swatch;
    }
  }

  Future<List<Swatch>> loadAll(List<String> payloads) async {
    final futures = payloads.map((payload) async {
      try {
        return Swatch.fromJson(jsonDecode(payload) as Map<String, dynamic>);
      } on FormatException catch (error) {
        print('skipped: $error');
        return null;
      }
    });

    final results = await Future.wait(futures);
    return results.whereType<Swatch>().toList();
  }
}

Future<void> main() async {
  final registry = Registry('Themes of Shibbir', strict: true)
    ..add(Swatch(label: 'background', hex: '#263238', tags: <String>['ui']))
    ..add(Swatch(label: 'keyword', hex: '#C792EA'));

  await for (final swatch in registry.watch()) {
    final rounded = swatch.luminance.toStringAsFixed(4);
    print('${swatch.describe()}  luminance=$rounded  ${swatch.isDark ? 'dark' : 'light'}');
  }

  print('${registry.size} swatches, max depth $maxDepth');
  print(TokenKind.values.where((kind) => kind.isItalic).map((kind) => kind.scope));
  print(math.max(registry.size, 1));
}
