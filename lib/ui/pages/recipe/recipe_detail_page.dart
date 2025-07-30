import 'package:flutter/material.dart';

class RecipeDetailPage extends StatelessWidget {
  const RecipeDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const _TopBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    _RecipeHeader(),
                    SizedBox(height: 24),
                    _Ingredients(),
                    SizedBox(height: 24),
                    _RecipeSteps(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: SizedBox(
          height: 50,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('추가되었습니다!')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF003508),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              '추가하기',
              style: TextStyle(
                fontFamily: 'Pretendard Variable',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, color: Color(0xFF003508)),
          ),
          const Text(
            '레시피',
            style: TextStyle(
              fontFamily: 'Pretendard Variable',
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: Color(0xFF003508),
            ),
          ),
          const Icon(Icons.notifications_none, color: Color(0xFF003508)),
        ],
      ),
    );
  }
}

class _RecipeHeader extends StatelessWidget {
  const _RecipeHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            'assets/images/avocado_salad.jpg',
            width: 150,
            height: 200,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '아보카도 샐러드',
                style: TextStyle(
                  fontFamily: 'Pretendard Variable',
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: Color(0xFF003508),
                ),
              ),
              const SizedBox(height: 6),
              const Row(
                children: [
                  Icon(Icons.access_time, size: 18, color: Color(0xFF003508)),
                  SizedBox(width: 4),
                  Text('25분', style: TextStyle(color: Color(0xFF003508))),
                  SizedBox(width: 12),
                  Icon(Icons.local_fire_department, size: 18, color: Color(0xFF003508)),
                  SizedBox(width: 4),
                  Text('350kcal', style: TextStyle(color: Color(0xFF003508))),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                height: 20,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                ),
                clipBehavior: Clip.hardEdge,
                child: Row(
                  children: [
                    Expanded(flex: 183, child: Container(color: Color(0xFFD0E7FF))),
                    Expanded(flex: 154, child: Container(color: Color(0xFFD6ECC9))),
                    Expanded(flex: 50, child: Container(color: Color(0xFFBFD9D2))),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const _NutrientRow(),
            ],
          ),
        ),
      ],
    );
  }
}

class _NutrientRow extends StatelessWidget {
  const _NutrientRow();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _NutrientItem('탄수화물', '183.5g', Color(0xFFD0E7FF)),
        _NutrientItem('단백질', '154g', Color(0xFFD6ECC9)),
        _NutrientItem('지방', '50g', Color(0xFFBFD9D2)),
      ],
    );
  }
}

class _NutrientItem extends StatelessWidget {
  final String name;
  final String value;
  final Color color;

  const _NutrientItem(this.name, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          CircleAvatar(radius: 5, backgroundColor: color),
          const SizedBox(width: 6),
          Text(
            name,
            style: const TextStyle(
              fontFamily: 'Pretendard Variable',
              fontSize: 14,
              color: Color(0xFF003508),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Pretendard Variable',
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: Color(0xFF003508),
            ),
          ),
        ],
      ),
    );
  }
}

class _Ingredients extends StatelessWidget {
  const _Ingredients();

  @override
  Widget build(BuildContext context) {
    final List<Map<String, bool>> ingredients = [
      {'아보카도 3개': true},
      {'바나나 1개': true},
      {'골드키위': false},
      {'로메인': false},
      {'발사믹 글레이즈': true},
      {'후춧가루': true},
    ];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFD6E2C0), width: 1.2),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      margin: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFD6E2C0)),
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
            ),
            child: const Text(
              '재료',
              style: TextStyle(
                fontFamily: 'Pretendard Variable',
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: Color(0xFF003508),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 40,
            runSpacing: 16,
            children: ingredients.map((item) {
              final name = item.keys.first;
              final hasItem = item[name]!;

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontFamily: 'Pretendard Variable',
                      color: Color(0xFF003508),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    hasItem ? Icons.check : Icons.clear,
                    size: 20,
                    color: hasItem ? const Color(0xFFC7DDB3) : const Color(0xFFFF8C7C),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _RecipeSteps extends StatelessWidget {
  const _RecipeSteps();

  @override
  Widget build(BuildContext context) {
    final steps = [
      '블루베리를 제외한 모든 과일과 로메인은 비슷한 크기로 썰어준다',
      '접시에 로메인을 먼저 깔아준다',
      '아보카도와 과일을 골고루 뿌리듯 올려준다',
      '리코타치즈를 떠서 올려주고 올리브오일을 골고루 뿌린 후 소금과 후춧가루를 뿌려준다',
      '마지막에 발사믹소스를 뿌려준다',
    ];

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: Color(0xFFD6E2C0)),
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
            ),
            child: const Text(
              '조리순서',
              style: TextStyle(
                fontFamily: 'Pretendard Variable',
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: Color(0xFF003508),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children: steps.asMap().entries.map((entry) {
              final index = entry.key;
              final step = entry.value;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xFFBFD9D2)),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Color(0xFF003508),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        step,
                        style: const TextStyle(
                          fontFamily: 'Pretendard Variable',
                          fontSize: 15,
                          color: Color(0xFF003508),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}