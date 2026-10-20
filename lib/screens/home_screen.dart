import 'package:flutter/material.dart';

import '../auth_state.dart';
import '../theme.dart';
import 'explorar_page.dart';
import 'favoritos_page.dart';
import 'login_screen.dart';
import 'novo_lugar_screen.dart';
import 'perfil_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _aba = 0;
  int _recarregar = 0; // muda para forçar a lista a recarregar

  Future<void> _novoLugar() async {
    if (!auth.logado) {
      await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginScreen()));
      return;
    }
    final criou = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const NovoLugarScreen()),
    );
    if (criou == true) {
      setState(() {
        _aba = 0;
        _recarregar++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final paginas = <Widget>[
      ExplorarPage(key: ValueKey(_recarregar)),
      const FavoritosPage(),
      const PerfilPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text.rich(
          TextSpan(children: [
            TextSpan(text: '✦ ', style: TextStyle(color: terracota)),
            TextSpan(text: 'Bússola'),
          ]),
        ),
      ),
      body: paginas[_aba],
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _novoLugar,
        backgroundColor: terracota,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_a_photo_outlined),
        label: const Text('Novo lugar'),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _aba,
        onDestinationSelected: (i) => setState(() => _aba = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.explore_outlined), selectedIcon: Icon(Icons.explore), label: 'Explorar'),
          NavigationDestination(icon: Icon(Icons.favorite_border), selectedIcon: Icon(Icons.favorite), label: 'Favoritos'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
