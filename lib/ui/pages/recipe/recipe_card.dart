// ✅ lib/widgets/recipe_card.dart
import 'package:flutter/material.dart';

class RecipeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imagePath;
  final String ingredients;
  final String time;
  final String kcal;
  final List<String> ownedIngredients;

  const RecipeCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.ingredients,
    required this.time,
    required this.kcal,
    required this.ownedIngredients,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> ingredientList =
    ingredients.split(',').map((e) => e.trim()).toList();

    return InkWell(
      onTap: () => Navigator.pushNamed(context, '/detail'),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: double.infinity,
                height: 150,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(subtitle),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: ingredientList.map((ingredient) {
                  final hasIngredient = ownedIngredients.any((own) => ingredient.contains(own));
                  return Chip(
                    label: Text(ingredient),
                    backgroundColor:
                    hasIngredient ? Colors.blue[100] : Colors.red[100],
                    labelStyle: TextStyle(
                      color: hasIngredient ? Colors.blue[800] : Colors.red[800],
                      fontWeight: FontWeight.w500,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("\u23F1 $time"),
                  Text("\uD83D\uDD25 $kcal"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
