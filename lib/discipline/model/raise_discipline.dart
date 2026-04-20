final class Discipline {
  String? title;
  List<DisciplineConcern>? concerns;

  Discipline({
    this.title,
    this.concerns,
  });
}

final class DisciplineConcern {
  String? title;
  int? id;
  bool selected;

  DisciplineConcern({
    this.title,
    this.id,
    this.selected = false,
  });
}
