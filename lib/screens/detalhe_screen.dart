import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api.dart';
import '../auth_state.dart';
import '../theme.dart';
import '../widgets/foto_rede.dart';

class DetalheScreen extends StatefulWidget {
  final Lugar lugarInicial;

  const DetalheScreen({super.key, required this.lugarInicial});

  @override
  State<DetalheScreen> createState() => _DetalheScreenState();
}

class _DetalheScreenState extends State<DetalheScreen> {
  late Lugar _lugar;
  final _pageController = PageController();
  final _novaFoto = TextEditingController();
  int _fotoAtual = 0;
  bool _ocupado = false;

  @override
  void initState() {
    super.initState();
    _lugar = widget.lugarInicial;
    _atualizar();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _novaFoto.dispose();
    super.dispose();
  }

  void _aviso(String texto) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  // Busca os dados completos do lugar (a lista traz só um resumo)
  Future<void> _atualizar() async {
    try {
      final completo = await api.lugar(_lugar.id);
      if (mounted) setState(() => _lugar = completo);
    } catch (_) {
      // mantém os dados que já temos
    }
  }

  Future<void> _favoritar() async {
    try {
      await auth.alternarFavorito(_lugar.id);
    } catch (e) {
      _aviso(e.toString());
    }
  }

  Future<void> _adicionarFoto() async {
    final url = _novaFoto.text.trim();
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      _aviso('Informe um link que comece com http:// ou https://');
      return;
    }
    setState(() => _ocupado = true);
    try {
      final foto = await api.adicionarFoto(_lugar.id, url);
      if (!mounted) return;
      setState(() {
        _lugar.galeria = [..._lugar.galeria, foto];
        _novaFoto.clear();
      });
      FocusScope.of(context).unfocus();
      _pageController.animateToPage(
        _lugar.galeria.length - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } catch (e) {
      _aviso(e.toString());
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  Future<bool> _confirmar(String titulo, String texto) async {
    final r = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(titulo),
        content: Text(texto),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Confirmar')),
        ],
      ),
    );
    return r == true;
  }

  Future<void> _removerFotoAtual() async {
    if (_lugar.galeria.isEmpty) return;
    final foto = _lugar.galeria[_fotoAtual.clamp(0, _lugar.galeria.length - 1)];
    if (!await _confirmar('Remover foto', 'Deseja remover esta foto?')) return;
    try {
      await api.removerFoto(foto.id);
      if (!mounted) return;
      setState(() {
        _lugar.galeria = _lugar.galeria.where((f) => f.id != foto.id).toList();
        _fotoAtual = 0;
      });
    } catch (e) {
      _aviso(e.toString());
    }
  }

  Future<void> _excluirLugar() async {
    if (!await _confirmar('Excluir lugar', 'Excluir "${_lugar.nome}" definitivamente?')) return;
    try {
      await api.excluirLugar(_lugar.id);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      _aviso(e.toString());
    }
  }

  Future<void> _abrirMapa() async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${_lugar.latitude},${_lugar.longitude}',
    );
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok) _aviso('Não consegui abrir o mapa.');
    } catch (_) {
      _aviso('Não consegui abrir o mapa.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final galeria = _lugar.galeria;
    final temCoordenadas = _lugar.latitude != null && _lugar.longitude != null;

    return Scaffold(
      appBar: AppBar(title: Text(_lugar.nome, style: const TextStyle(fontSize: 18))),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 40),
        children: [
          // Galeria
          AspectRatio(
            aspectRatio: 4 / 3,
            child: Stack(
              children: [
                if (galeria.isEmpty)
                  FotoRede(url: null, letra: _lugar.nome)
                else
                  PageView.builder(
                    controller: _pageController,
                    itemCount: galeria.length,
                    onPageChanged: (i) => setState(() => _fotoAtual = i),
                    itemBuilder: (_, i) => FotoRede(url: galeria[i].url, letra: _lugar.nome),
                  ),
                if (galeria.length > 1)
                  Positioned(
                    bottom: 10,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var i = 0; i < galeria.length; i++)
                          Container(
                            width: i == _fotoAtual ? 18 : 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            decoration: BoxDecoration(
                              color: i == _fotoAtual ? terracota : Colors.white70,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_lugar.categoria != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: verdeEscuro,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(_lugar.categoria!, style: const TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                const SizedBox(height: 10),
                Text(_lugar.nome, style: titulo(30)),
                const SizedBox(height: 12),
                Text(_lugar.descricao, style: const TextStyle(fontSize: 16, height: 1.45)),
                const SizedBox(height: 20),

                if (temCoordenadas)
                  OutlinedButton.icon(
                    onPressed: _abrirMapa,
                    icon: const Icon(Icons.map_outlined),
                    label: const Text('Ver no mapa'),
                  ),

                ListenableBuilder(
                  listenable: auth,
                  builder: (context, _) {
                    if (!auth.logado) {
                      return const Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: Text(
                          'Entre na sua conta (aba Perfil) para favoritar e adicionar fotos.',
                          style: TextStyle(color: suave),
                        ),
                      );
                    }
                    final fav = auth.favIds.contains(_lugar.id);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 12),
                        fav
                            ? FilledButton.icon(
                                onPressed: _favoritar,
                                icon: const Icon(Icons.favorite),
                                label: const Text('Favoritado'),
                              )
                            : OutlinedButton.icon(
                                onPressed: _favoritar,
                                icon: const Icon(Icons.favorite_border),
                                label: const Text('Favoritar'),
                              ),
                        const SizedBox(height: 24),
                        Text('Fotos', style: titulo(20)),
                        const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _novaFoto,
                                keyboardType: TextInputType.url,
                                decoration: const InputDecoration(
                                  hintText: 'Link de outra foto',
                                  isDense: true,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              height: 48,
                              child: FilledButton(
                                style: FilledButton.styleFrom(minimumSize: const Size(90, 48)),
                                onPressed: _ocupado ? null : _adicionarFoto,
                                child: Text(_ocupado ? '...' : 'Adicionar'),
                              ),
                            ),
                          ],
                        ),
                        if (galeria.isNotEmpty)
                          TextButton.icon(
                            onPressed: _removerFotoAtual,
                            icon: const Icon(Icons.delete_outline, color: Color(0xFFA3322A)),
                            label: const Text('Remover foto atual', style: TextStyle(color: Color(0xFFA3322A))),
                          ),
                        const Divider(height: 32),
                        TextButton.icon(
                          onPressed: _excluirLugar,
                          icon: const Icon(Icons.delete_forever_outlined, color: Color(0xFFA3322A)),
                          label: const Text('Excluir lugar', style: TextStyle(color: Color(0xFFA3322A))),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
