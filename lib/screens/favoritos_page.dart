import 'package:flutter/material.dart';

import '../api.dart';
import '../auth_state.dart';
import '../theme.dart';
import '../widgets/lugar_card.dart';
import 'login_screen.dart';

class FavoritosPage extends StatefulWidget {
  const FavoritosPage({super.key});

  @override
  State<FavoritosPage> createState() => _FavoritosPageState();
}

class _FavoritosPageState extends State<FavoritosPage> {
  List<Lugar> _lugares = [];
  bool _carregando = false;
  String? _erro;

  @override
  void initState() {
    super.initState();
    if (auth.logado) _carregar();
  }

  Future<void> _carregar() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final lista = await api.favoritos();
      if (mounted) setState(() => _lugares = lista);
    } catch (e) {
      if (mounted) setState(() => _erro = e.toString());
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: auth,
      builder: (context, _) {
        if (!auth.logado) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.favorite_border, size: 56, color: terracota),
                  const SizedBox(height: 12),
                  Text('Seus favoritos ficam aqui', style: titulo(22)),
                  const SizedBox(height: 6),
                  const Text('Entre na sua conta para favoritar lugares.', style: TextStyle(color: suave)),
                  const SizedBox(height: 18),
                  FilledButton(
                    onPressed: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                      if (auth.logado) _carregar();
                    },
                    child: const Text('Entrar'),
                  ),
                ],
              ),
            ),
          );
        }

        // Se o usuário desfavoritar, o card some da lista
        final visiveis = _lugares.where((l) => auth.favIds.contains(l.id)).toList();

        return RefreshIndicator(
          color: verde,
          onRefresh: _carregar,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            children: [
              Text('Meus favoritos', style: titulo(26)),
              const SizedBox(height: 14),
              if (_erro != null) Text(_erro!, style: const TextStyle(color: Color(0xFF8C2A20))),
              if (_carregando)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator(color: verde)),
                ),
              if (!_carregando && _erro == null && visiveis.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      'Você ainda não favoritou nenhum lugar.\nToque no ♡ de um destino.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: suave),
                    ),
                  ),
                ),
              for (final l in visiveis)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: LugarCard(lugar: l),
                ),
            ],
          ),
        );
      },
    );
  }
}
