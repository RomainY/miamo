import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/planification_providers.dart';
import 'plat_detail_screen.dart';

/// Liste des plats réutilisables (cahier-des-charges.md §7.5 "Créer/modifier
/// un plat").
class PlatsPage extends ConsumerWidget {
  const PlatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plats = ref.watch(platsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mes plats')),
      body: plats.when(
        data: (liste) {
          if (liste.isEmpty) {
            return const Center(child: Text('Aucun plat pour le moment.'));
          }
          return ListView.separated(
            itemCount: liste.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final plat = liste[i];
              final sousTitre = [
                if (plat.tempsPrepa != null) '${plat.tempsPrepa} min',
                '${plat.portionsDefaut} portion(s) par défaut',
              ].join(' · ');
              return ListTile(
                title: Text(plat.nom),
                subtitle: Text(sousTitre),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PlatDetailScreen(plat: plat),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur : $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const PlatDetailScreen())),
        child: const Icon(Icons.add),
      ),
    );
  }
}
