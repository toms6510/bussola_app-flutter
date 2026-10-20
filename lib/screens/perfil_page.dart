import 'package:flutter/material.dart';

import '../auth_state.dart';
import '../theme.dart';
import 'cadastro_screen.dart';
import 'login_screen.dart';

class PerfilPage extends StatelessWidget {
  const PerfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: auth,
      builder: (context, _) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: verde,
                  child: Text(
                    auth.logado && (auth.nome ?? '').isNotEmpty
                        ? auth.nome!.substring(0, 1).toUpperCase()
                        : '?',
                    style: titulo(34, cor: Colors.white),
                  ),
                ),
                const SizedBox(height: 14),
                if (auth.logado) ...[
                  Text(auth.nome ?? 'Viajante', style: titulo(24)),
                  const SizedBox(height: 4),
                  const Text('Você está conectado.', style: TextStyle(color: suave)),
                  const SizedBox(height: 24),
                  OutlinedButton(onPressed: auth.sair, child: const Text('Sair')),
                ] else ...[
                  Text('Olá, viajante!', style: titulo(24)),
                  const SizedBox(height: 4),
                  const Text(
                    'Entre para favoritar e cadastrar lugares.',
                    style: TextStyle(color: suave),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    ),
                    child: const Text('Entrar'),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const CadastroScreen()),
                    ),
                    child: const Text('Criar conta'),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
