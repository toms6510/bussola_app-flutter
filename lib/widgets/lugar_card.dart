import 'package:flutter/material.dart';

import '../api.dart';
import '../auth_state.dart';
import '../screens/detalhe_screen.dart';
import '../theme.dart';
import 'foto_rede.dart';

class LugarCard extends StatelessWidget {
  final Lugar lugar;
  final VoidCallback? aoVoltar;

  const LugarCard({super.key, required this.lugar, this.aoVoltar});

  Future<void> _favoritar(BuildContext context) async {
    try {
      await auth.alternarFavorito(lugar.id);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: papel,
      elevation: 0,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: borda),
      ),
      child: InkWell(
        onTap: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => DetalheScreen(lugarInicial: lugar)),
          );
          aoVoltar?.call();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 10,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  FotoRede(url: lugar.capa, letra: lugar.nome),
                  if (lugar.categoria != null)
                    Positioned(
                      left: 10,
                      bottom: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: verdeEscuro.withOpacity(0.88),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          lugar.categoria!,
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: ListenableBuilder(
                      listenable: auth,
                      builder: (context, _) {
                        if (!auth.logado) return const SizedBox.shrink();
                        final fav = auth.favIds.contains(lugar.id);
                        return Material(
                          color: fav ? terracota : papel.withOpacity(0.92),
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () => _favoritar(context),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Icon(
                                fav ? Icons.favorite : Icons.favorite_border,
                                color: fav ? Colors.white : terracota,
                                size: 22,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(lugar.nome, style: titulo(19)),
                  const SizedBox(height: 4),
                  Text(
                    lugar.descricao,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: suave),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
