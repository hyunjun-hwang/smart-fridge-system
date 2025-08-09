import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RecipesTestPage extends StatelessWidget {
  const RecipesTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    final query = FirebaseFirestore.instance
        .collection('recipes')
        .orderBy('name');

    return Scaffold(
      appBar: AppBar(title: const Text('레시피 (Firestore 테스트)')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: query.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('오류가 발생했습니다.'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('레시피가 없습니다.'));
          }

          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final d = docs[i].data();
              final name = (d['name'] ?? '').toString();
              final category = (d['category'] ?? '').toString();
              final calorie = d['calorie'];
              final imageUrl = (d['imageUrl'] ?? d['image'] ?? '').toString();

              return ListTile(
                leading: imageUrl.isNotEmpty
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                  ),
                )
                    : const Icon(Icons.image_not_supported),
                title: Text(name.isEmpty ? '(이름 없음)' : name),
                subtitle: Text([
                  if (category.isNotEmpty) category,
                  if (calorie != null) '${calorie} kcal',
                ].join(' · ')),
              );
            },
          );
        },
      ),
    );
  }
}
