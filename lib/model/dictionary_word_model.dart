class DictionaryWord {
  final String word;
  final String pos;
  final String phonetic;
  final String phoneticText;
  final String phoneticAm;
  final String phoneticAmText;
  final List<Sense> senses;

  DictionaryWord({
    required this.word,
    required this.pos,
    required this.phonetic,
    required this.phoneticText,
    required this.phoneticAm,
    required this.phoneticAmText,
    required this.senses,
  });

  factory DictionaryWord.fromJson(Map<String, dynamic> json) {
    return DictionaryWord(
      word: json['word'],
      pos: json['pos'],
      phonetic: json['phonetic'],
      phoneticText: json['phonetic_text'],
      phoneticAm: json['phonetic_am'],
      phoneticAmText: json['phonetic_am_text'],
      senses: (json['senses'] as List).map((s) => Sense.fromJson(s)).toList(),
    );
  }
}

class Sense {
  final String definition;
  final List<Example> examples;

  Sense({required this.definition, required this.examples});

  factory Sense.fromJson(Map<String, dynamic> json) {
    return Sense(
      definition: json['definition'],
      examples: (json['examples'] as List).map((e) => Example.fromJson(e)).toList(),
    );
  }
}

class Example {
  final String x;

  Example({required this.x});

  factory Example.fromJson(Map<String, dynamic> json) {
    return Example(x: json['x']);
  }
}
