import 'package:flutter/material.dart';

import '../api.dart';
import '../auth_state.dart';
import '../theme.dart';

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _form = GlobalKey<FormState>();
  final _nome = TextEditingController();
  final _email = TextEditingController();
  final _senha = TextEditingController();
  final _cidade = TextEditingController();
  bool _enviando = false;
  String? _erro;

  @override
  void dispose() {
    _nome.dispose();
    _email.dispose();
    _senha.dispose();
    _cidade.dispose();
    super.dispose();
  }

  Future<void> _cadastrar() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _enviando = true;
      _erro = null;
    });
    try {
      final dados = <String, dynamic>{
        'nome': _nome.text.trim(),
        'email': _email.text.trim(),
        'senha': _senha.text,
      };
      if (_cidade.text.trim().isNotEmpty) dados['cidade'] = _cidade.text.trim();

      await api.cadastrar(dados);
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
      appBar: AppBar(title: const Text('Criar conta')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Crie sua conta', style: titulo(28)),
              const SizedBox(height: 4),
              const Text('Leva menos de um minuto.', style: TextStyle(color: suave)),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nome,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe seu nome' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'E-mail'),
                validator: (v) => (v == null || !v.contains('@')) ? 'Informe um e-mail válido' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _senha,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Senha (mín. 6 caracteres)'),
                validator: (v) => (v == null || v.length < 6) ? 'A senha precisa de 6 ou mais caracteres' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _cidade,
                decoration: const InputDecoration(labelText: 'Cidade (opcional)'),
              ),
              if (_erro != null) ...[
                const SizedBox(height: 14),
                Text(_erro!, style: const TextStyle(color: Color(0xFF8C2A20))),
              ],
              const SizedBox(height: 22),
              FilledButton(
                onPressed: _enviando ? null : _cadastrar,
                child: Text(_enviando ? 'Criando...' : 'Criar conta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
