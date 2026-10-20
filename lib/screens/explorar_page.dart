import 'package:flutter/material.dart';

import '../api.dart';
import '../theme.dart';
import '../widgets/lugar_card.dart';

const int _porPagina = 10;

class ExplorarPage extends StatefulWidget {
  const ExplorarPage({super.key});

  @override
  State<ExplorarPage> createState() => _ExplorarPageState();
}

class _ExplorarPageState extends State<ExplorarPage> {
  final List<Lugar> _lugares = [];
  List<Categoria> _categorias = [];
  int _pagina = 1;
  bool _temMais = false;
  bool _carregando = true;
  String? _erro;
  String _busca = '';
  String? _categoriaSelecionada;

  @override
  void initState() {
    super.initState();
    _carregar(1);
    api.categorias().then((c) {
      if (mounted) setState(() => _categorias = c);
    }).catchError((_) {});
  }

  Future<void> _carregar(int pagina) async {
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final lista = await api.lugares(pagina: pagina, limite: _porPagina);
      if (!mounted) return;
      setState(() {
        if (pagina == 1) _lugares.clear();
        _lugares.addAll(lista);
        _temMais = lista.length == _porPagina;
        _pagina = pagina;
      });
    } catch (e) {
      if (mounted) setState(() => _erro = e.toString());
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  List<Lugar> get _filtrados {
    final termo = _busca.trim().toLowerCase();
    return _lugares.where((l) {
      final okCategoria = _categoriaSelecionada == null || l.categoria == _categoriaSelecionada;
      final okBusca = termo.isEmpty ||
          l.nome.toLowerCase().contains(termo) ||
          l.descricao.toLowerCase().contains(termo);
      return okCategoria && okBusca;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final lista = _filtrados;

    return RefreshIndicator(
      color: verde,
      onRefresh: () => _carregar(1),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          // Banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: verde,
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [verde, verde, terracota.withOpacity(0.75)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Descubra seu próximo destino', style: titulo(26, cor: Colors.white)),
                const SizedBox(height: 6),
                const Text(
                  'Lugares cadastrados por viajantes como você.',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 14),
                TextField(
                  onChanged: (v) => setState(() => _busca = v),
                  decoration: const InputDecoration(
                    hintText: 'Buscar por nome ou descrição...',
                    prefixIcon: Icon(Icons.search),
                    contentPadding: EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Filtro de categorias
          if (_categorias.isNotEmpty)
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: const Text('Todos'),
                      selected: _categoriaSelecionada == null,
                      onSelected: (_) => setState(() => _categoriaSelecionada = null),
                    ),
                  ),
                  for (final c in _categorias)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(c.nome),
                        selected: _categoriaSelecionada == c.nome,
                        onSelected: (_) => setState(() => _categoriaSelecionada = c.nome),
                      ),
                    ),
                ],
              ),
            ),
          const SizedBox(height: 14),

          if (_erro != null)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFBE5E1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(_erro!, style: const TextStyle(color: Color(0xFF8C2A20))),
            ),

          for (final l in lista)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: LugarCard(lugar: l, aoVoltar: () => _carregar(1)),
            ),

          if (_carregando)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator(color: verde)),
            ),

          if (!_carregando && _erro == null && lista.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: Text('Nenhum lugar encontrado.', style: TextStyle(color: suave))),
            ),

          if (_temMais && !_carregando)
            OutlinedButton(
              onPressed: () => _carregar(_pagina + 1),
              child: const Text('Carregar mais'),
            ),
        ],
      ),
    );
  }
}
