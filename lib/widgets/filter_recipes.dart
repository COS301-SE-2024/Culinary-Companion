class Filters {
  List<String>? course;
  int? spiceLevel;
  List<String>? cuisine;
  List<String>? dietaryOptions;
  String? ingredientOption;

  Filters({
    this.course,
    this.spiceLevel,
    this.cuisine,
    this.dietaryOptions,
    this.ingredientOption,
  });

  Map<String, dynamic> toJson() {
    return {
      'course': course,
      'spiceLevel': spiceLevel,
      'cuisine': cuisine,
      'dietaryOptions': dietaryOptions,
      'ingredientOption': ingredientOption,
    };
  }
}