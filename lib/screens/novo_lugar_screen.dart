import 'package:flutter/material.dart';

import '../api.dart';
import '../theme.dart';
import '../widgets/foto_rede.dart';

class NovoLugarScreen extends StatefulWidget {
  const NovoLugarScreen({super.key});

  @override
  State<NovoLugarScreen> createState() => _NovoLugarScreenState();
}

class _NovoLugarScreenState extends State<NovoLugarScreen> {
  final _form = GlobalKey<FormState>();
  final _nome = TextEditingController();
  final _descricao = TextEditingController();
  final _latitude = TextEditingController();
  final _longitude = TextEditingController();
  final _foto = TextEditingController();

  List<Categoria> _categorias = [];
  int? _categoriaId;
  bool _carregandoCategorias = true;
  bool _enviando = false;
  String? _erro;

  @override
  void initState() {
    super.initState();
    api.categorias().then((c) {
      if (mounted) setState(() => _categorias = c);
    }).catchError((e) {
      if (mounted) setState(() => _erro = e.toString());
    }).whenComplete(() {
      if (mounted) setState(() => _carregandoCategorias = false);
    });
  }

  @override
  void dispose() {
    _nome.dispose();
    _descricao.dispose();
    _latitude.dispose();
    _longitude.dispose();
    _foto.dispose();
    super.dispose();
  }

  double? _numero(String texto) {
    final t = texto.trim().replaceAll(',', '.');
    if (t.isEmpty) return null;
    return double.tryParse(t);
  }

  String? _validarCoordenada(String? v) {
    if (v == null || v.trim().isEmpty) return null; // opcional
    return _numero(v) == null ? 'Número inválido' : null;
  }

  Future<void> _salvar() async {
    if (!_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _enviando = true;
      _erro = null;
    });

    Lugar lugar;
    try {
      lugar = await api.criarLugar(
        nome: _nome.text.trim(),
        descricao: _descricao.text.trim(),
        categoriaId: _categoriaId!,
        latitude: _numero(_latitude.text),
        longitude: _numero(_longitude.text),
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _erro = e.toString();
          _enviando = false;
        });
      }
      return;
    }

    // O lugar já existe; agora vinculamos a foto à galeria dele
    String? avisoFoto;
    try {
      await api.adicionarFoto(lugar.id, _foto.text.trim());
    } catch (e) {
      avisoFoto = 'O lugar foi criado, mas a foto não pôde ser salva: $e';
    }

    if (!mounted) return;
    if (avisoFoto != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(avisoFoto)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lugar cadastrado com sucesso!')),
      );
    }
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novo lugar')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Cadastrar lugar', style: titulo(26)),
              const SizedBox(height: 4),
              const Text('Conte pra galera onde vale a pena ir.', style: TextStyle(color: suave)),
              const SizedBox(height: 20),

              // Foto
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: AspectRatio(
                  aspectRatio: 16 / 10,
                  child: _foto.text.trim().isEmpty
                      ? Container(
                          color: const Color(0xFFE9E2D0),
                          alignment: Alignment.center,
                          child: const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.image_outlined, size: 40, color: suave),
                              SizedBox(height: 6),
                              Text('Pré-visualização da foto', style: TextStyle(color: suave)),
                            ],
                          ),
                        )
                      : FotoRede(key: ValueKey(_foto.text.trim()), url: _foto.text.trim(), letra: '!'),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _foto,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                  labelText: 'Link da foto',
                  hintText: 'https://exemplo.com/foto.jpg',
                  prefixIcon: Icon(Icons.link),
                ),
                onChanged: (_) => setState(() {}),
                validator: (v) {
                  final t = (v ?? '').trim();
                  if (t.isEmpty) return 'Informe o link da foto';
                  if (!t.startsWith('http://') && !t.startsWith('https://')) {
                    return 'O link deve começar com http:// ou https://';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _nome,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Nome do lugar'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe o nome' : null,
              ),
              const SizedBox(height: 14),

              if (_carregandoCategorias)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(child: CircularProgressIndicator(color: verde)),
                )
              else
                DropdownButtonFormField<int>(
                  value: _categoriaId,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Categoria'),
                  items: [
                    for (final c in _categorias) DropdownMenuItem(value: c.id, child: Text(c.nome)),
                  ],
                  onChanged: (v) => setState(() => _categoriaId = v),
                  validator: (v) => v == null ? 'Escolha uma categoria' : null,
                ),
              if (!_carregandoCategorias && _categorias.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Text(
                    'Nenhuma categoria encontrada na API. Cadastre uma categoria antes.',
                    style: TextStyle(color: Color(0xFF8C2A20), fontSize: 13),
                  ),
                ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _descricao,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(labelText: 'Descrição', alignLabelWithHint: true),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe a descrição' : null,
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latitude,
                      keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                      decoration: const InputDecoration(labelText: 'Latitude'),
                      validator: _validarCoordenada,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _longitude,
                      keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                      decoration: const InputDecoration(labelText: 'Longitude'),
                      validator: _validarCoordenada,
                    ),
                  ),
                ],
              ),

              if (_erro != null) ...[
                const SizedBox(height: 14),
                Text(_erro!, style: const TextStyle(color: Color(0xFF8C2A20))),
              ],
              const SizedBox(height: 22),
              FilledButton(
                onPressed: _enviando ? null : _salvar,
                child: Text(_enviando ? 'Salvando...' : 'Salvar lugar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
