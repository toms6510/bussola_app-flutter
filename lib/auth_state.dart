import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api.dart';

class AuthState extends ChangeNotifier {
  String? _token;
  String? nome;
  Set<int> favIds = {};

  bool get logado => _token != null;

  // Chamado uma vez ao abrir o app: recupera a sessão salva
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    nome = prefs.getString('nome');
    api.token = _token;
    api.aoExpirarSessao = () {
      sair();
    };
    if (logado) await carregarFavoritos();
  }

  Future<void> entrar(String email, String senha) async {
    final dados = await api.login(email, senha);
    _token = dados['token']?.toString();
    final usuario = dados['usuario'];
    nome = usuario is Map ? usuario['nome']?.toString() : null;
    api.token = _token;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', _token ?? '');
    await prefs.setString('nome', nome ?? '');
    await carregarFavoritos();
    notifyListeners();
  }

  Future<void> sair() async {
    _token = null;
    nome = null;
    favIds = {};
    api.token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('nome');
    notifyListeners();
  }

  Future<void> carregarFavoritos() async {
    try {
      final lista = await api.favoritos();
      favIds = lista.map((l) => l.id).toSet();
    } catch (_) {
      // ignora: a lista de favoritos é um extra
    }
  }

  Future<void> alternarFavorito(int lugarId) async {
    if (favIds.contains(lugarId)) {
      await api.desfavoritar(lugarId);
      favIds = {...favIds}..remove(lugarId);
    } else {
      await api.favoritar(lugarId);
      favIds = {...favIds, lugarId};
    }
    notifyListeners();
  }
}

final AuthState auth = AuthState();
