class Recipe {
  final String title;
  final String description;
  final String imagePath;
  final int time;
  final int kcal;
  final double carb;
  final double protein;
  final double fat;
  final Map<String, bool> ingredients;
  final List<String> steps;

  Recipe({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.time,
    required this.kcal,
    required this.carb,
    required this.protein,
    required this.fat,
    required this.ingredients,
    required this.steps,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imagePath: json['imagePath'] ?? '',
      time: json['time'] ?? 0,
      kcal: json['kcal'] ?? 0,
      carb: (json['carb'] ?? 0).toDouble(),
      protein: (json['protein'] ?? 0).toDouble(),
      fat: (json['fat'] ?? 0).toDouble(),
      ingredients: Map<String, bool>.from(json['ingredients'] ?? {}),
      steps: List<String>.from(json['steps'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'imagePath': imagePath,
      'time': time,
      'kcal': kcal,
      'carb': carb,
      'protein': protein,
      'fat': fat,
      'ingredients': ingredients,
      'steps': steps,
    };
  }
}
