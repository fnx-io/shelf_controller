import 'package:analyzer/dart/element/element.dart';

/// A doc comment split into the OpenAPI `summary` and `description`.
///
/// The first paragraph becomes the summary, the remaining paragraphs the
/// description.
class DocText {
  /// The first paragraph joined into a single line.
  final String? summary;

  /// The paragraphs after the first one, with line breaks preserved.
  final String? description;

  const DocText(this.summary, this.description);

  /// Parses the doc comment of [element].
  factory DocText.of(Element element) =>
      DocText.parse(element.documentationComment);

  /// Parses a raw `///` or `/** */` doc comment.
  factory DocText.parse(String? comment) {
    if (comment == null) return const DocText(null, null);
    final lines = _trimBlankLines(_stripCommentSyntax(comment));
    final firstBlank = lines.indexWhere((line) => line.trim().isEmpty);
    final summaryLines = firstBlank < 0 ? lines : lines.sublist(0, firstBlank);
    final rest = firstBlank < 0
        ? ''
        : lines.sublist(firstBlank).join('\n').trim();
    final summary = summaryLines.map((line) => line.trim()).join(' ').trim();
    return DocText(
      summary.isEmpty ? null : summary,
      rest.isEmpty ? null : rest,
    );
  }

  /// The whole comment as a single text, or `null` when there is none.
  String? get fullText =>
      [summary, description].whereType<String>().join('\n\n').nullIfEmpty;

  static List<String> _stripCommentSyntax(String comment) {
    final lines = comment
        .split('\n')
        .map((line) {
          final trimmed = line.trimLeft();
          if (trimmed.startsWith('///')) {
            return _dropOneSpace(trimmed.substring(3));
          }
          if (trimmed.startsWith('/**')) {
            return _dropOneSpace(trimmed.substring(3));
          }
          if (trimmed.startsWith('*/')) return '';
          if (trimmed.startsWith('*')) {
            return _dropOneSpace(trimmed.substring(1));
          }
          return trimmed;
        })
        .map(
          (line) =>
              line.endsWith('*/') ? line.substring(0, line.length - 2) : line,
        );
    return lines.toList();
  }

  static List<String> _trimBlankLines(List<String> lines) {
    final first = lines.indexWhere((line) => line.trim().isNotEmpty);
    if (first < 0) return const [];
    final last = lines.lastIndexWhere((line) => line.trim().isNotEmpty);
    return lines.sublist(first, last + 1);
  }

  static String _dropOneSpace(String text) =>
      text.startsWith(' ') ? text.substring(1) : text;
}

extension on String {
  String? get nullIfEmpty => isEmpty ? null : this;
}
