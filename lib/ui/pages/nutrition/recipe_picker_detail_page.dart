import 'package:flutter/material.dart';
import 'package:smart_fridge_system/data/models/recipe_model.dart';
import 'package:smart_fridge_system/providers/ndata/foodn_item.dart';

class RecipeDetailPage extends StatefulWidget {
  final Recipe recipe;
  final bool pickMode; // 선택 모드: true면 "추가하기" 노출

  const RecipeDetailPage({
    super.key,
    required this.recipe,
    this.pickMode = false,
  });

  @override
  State<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  static const Color primary = Color(0xFF003508);
  static const Color border = Color(0xFFD5E8C6);

  double count = 1.0; // 0.5 단위 증감

  @override
  Widget build(BuildContext context) {
    final r = widget.recipe;
    final kcal = r.kcal * count;
    final carb = r.carb * count;
    final protein = r.protein * count;
    final fat = r.fat * count;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('레시피', style: TextStyle(color: primary, fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(r.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: primary)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.local_fire_department, color: primary, size: 18),
                const SizedBox(width: 6),
                Text('${r.kcal}kcal', style: const TextStyle(color: primary)),
              ],
            ),
            const SizedBox(height: 16),

            // 수량 + 총영양
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: border),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => setState(() => count = (count - 0.5).clamp(0.5, 99.0)),
                        icon: const Icon(Icons.remove, color: primary),
                      ),
                      Text(count.toStringAsFixed(1),
                          style: const TextStyle(color: primary, fontWeight: FontWeight.w700)),
                      IconButton(
                        onPressed: () => setState(() => count = (count + 0.5).clamp(0.5, 99.0)),
                        icon: const Icon(Icons.add, color: primary),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('예상 섭취열량', style: TextStyle(color: Colors.black54)),
                    Text('${kcal.toStringAsFixed(1)} kcal',
                        style: const TextStyle(color: primary, fontSize: 20, fontWeight: FontWeight.w800)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(height: 1, color: Colors.grey.shade200),
            const SizedBox(height: 12),

            const Text('영양성분 (선택 수량 기준)',
                style: TextStyle(fontWeight: FontWeight.w700, color: primary)),
            const SizedBox(height: 6),
            _kv('탄수화물', '${carb.toStringAsFixed(1)} g'),
            _kv('단백질',  '${protein.toStringAsFixed(1)} g'),
            _kv('지방',    '${fat.toStringAsFixed(1)} g'),
            const SizedBox(height: 16),

            if (r.ingredients.isNotEmpty) ...[
              const Text('재료', style: TextStyle(fontWeight: FontWeight.w700, color: primary)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 10, runSpacing: 8,
                children: r.ingredients.keys.map((e) =>
                    Chip(label: Text(e), backgroundColor: border.withOpacity(.35))).toList(),
              ),
              const SizedBox(height: 16),
            ],

            const Text('조리순서', style: TextStyle(fontWeight: FontWeight.w700, color: primary)),
            const SizedBox(height: 8),
            ...r.steps.asMap().entries.map((e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(radius: 12, backgroundColor: border,
                      child: Text('${e.key + 1}', style: const TextStyle(color: primary))),
                  const SizedBox(width: 8),
                  Expanded(child: Text(e.value, style: const TextStyle(color: primary))),
                ],
              ),
            )),
            const SizedBox(height: 80),
          ],
        ),
      ),

      bottomNavigationBar: widget.pickMode
          ? SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primary, foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                final item = FoodItemn(
                  name: r.title,
                  calories: r.kcal.toDouble(),
                  carbohydrates: r.carb,
                  protein: r.protein,
                  fat: r.fat,
                  amount: 100,
                  count: count, // ★ 선택 수량 반영
                );
                Navigator.pop(context, item); // ★ 상위로 결과 반환
              },
              child: const Text('추가하기'),
            ),
          ),
        ),
      )
          : null,
    );
  }

  Widget _kv(String k, String v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(k, style: const TextStyle(color: Colors.black54)),
        Text(v, style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    ),
  );
}
