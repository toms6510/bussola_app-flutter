import 'package:flutter/material.dart';

import '../auth_state.dart';
import '../theme.dart';
import 'cadastro_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _senha = TextEditingController();
  bool _enviando = false;
  bool _ocultar = true;
  String? _erro;

  @override
  void dispose() {
    _email.dispose();
    _senha.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _enviando = true;
      _erro = null;
    });
    try {
      await auth.entrar(_email.text.trim(), _senha.text);
      if (mounted) Navigator.of(context).popUntil((r) => r.isFirst);
    } catch (e) {
      if (mounted) setState(() => _erro = e.toString());
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Entrar')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Bem-vindo de volta', style: titulo(28)),
              const SizedBox(height: 4),
              const Text('Entre para favoritar e cadastrar lugares.', style: TextStyle(color: suave)),
              const SizedBox(height: 24),
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'E-mail'),
                validator: (v) => (v == null || !v.contains('@')) ? 'Informe um e-mail válido' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _senha,
                obscureText: _ocultar,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  suffixIcon: IconButton(
                    icon: Icon(_ocultar ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _ocultar = !_ocultar),
                  ),
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Informe a senha' : null,
              ),
              if (_erro != null) ...[
                const SizedBox(height: 14),
                Text(_erro!, style: const TextStyle(color: Color(0xFF8C2A20))),
              ],
              const SizedBox(height: 22),
              FilledButton(
                onPressed: _enviando ? null : _entrar,
                child: Text(_enviando ? 'Entrando...' : 'Entrar'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CadastroScreen()),
                ),
                child: const Text('Ainda não tem conta? Cadastre-se'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
