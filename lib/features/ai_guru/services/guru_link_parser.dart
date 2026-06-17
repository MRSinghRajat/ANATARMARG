sealed class GuruSegment {
  const GuruSegment();
}

class GuruTextSegment extends GuruSegment {
  final String text;
  const GuruTextSegment(this.text);
}

class GuruLinkSegment extends GuruSegment {
  final String type;
  final String value;
  const GuruLinkSegment({required this.type, required this.value});
}

class GuruLinkParser {
  static final RegExp _regex = RegExp(
    r'\[(VERSE|STORY|SACRED|JOURNEY|MANTRA):\s*([^\]]+)\]',
  );

  static List<GuruSegment> parse(String text) {
    final segments = <GuruSegment>[];
    var cursor = 0;
    for (final m in _regex.allMatches(text)) {
      if (m.start > cursor) {
        segments.add(GuruTextSegment(text.substring(cursor, m.start)));
      }
      segments.add(GuruLinkSegment(
        type: m.group(1)!,
        value: m.group(2)!.trim(),
      ));
      cursor = m.end;
    }
    if (cursor < text.length) {
      segments.add(GuruTextSegment(text.substring(cursor)));
    }
    return segments;
  }
}
