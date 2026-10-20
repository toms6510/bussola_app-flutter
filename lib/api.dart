import 'dart:convert';

import 'package:http/http.dart' as http;

// URL base da API do Guia de Turismo
const String baseUrl = 'https://guia.liliaborges.com.br';

class ApiException implements Exception {
  final String message;
  final int? status;
  ApiException(this.message, [this.status]);

  @override
  String toString() => message;
}

// ---------------------------- Modelos ----------------------------

class Foto {
  final int id;
  final String url;
  Foto({required this.id, required this.url});

  factory Foto.fromJson(Map<String, dynamic> j) => Foto(
        id: (j['id'] as num).toInt(),
        url: (j['urlFoto'] ?? '').toString(),
      );
}

class Categoria {
  final int id;
  final String nome;
  Categoria({required this.id, required this.nome});

  factory Categoria.fromJson(Map<String, dynamic> j) => Categoria(
        id: (j['id'] as num).toInt(),
        nome: (j['nome'] ?? '').toString(),
      );
}

class Lugar {
  final int id;
  final String nome;
  final String descricao;
  final double? latitude;
  final double? longitude;
  final String? categoria;
  List<Foto> galeria;

  Lugar({
    required this.id,
    required this.nome,
    required this.descricao,
    this.latitude,
    this.longitude,
    this.categoria,
    required this.galeria,
  });

  String? get capa => galeria.isNotEmpty ? galeria.first.url : null;

  factory Lugar.fromJson(Map<String, dynamic> j) {
    final cat = j['categoria'];
    final fotos = j['galeria'];
    return Lugar(
      id: (j['id'] as num).toInt(),
      nome: (j['nome'] ?? '').toString(),
      descricao: (j['descricao'] ?? '').toString(),
      latitude: (j['latitude'] as num?)?.toDouble(),
      longitude: (j['longitude'] as num?)?.toDouble(),
      categoria: cat is Map ? cat['nome']?.toString() : null,
      galeria: fotos is List
          ? fotos.map((f) => Foto.fromJson(Map<String, dynamic>.from(f as Map))).toList()
          : <Foto>[],
    );
  }
}

// ---------------------------- Cliente HTTP ----------------------------

class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  String? token;
  void Function()? aoExpirarSessao;

  Future<dynamic> _requisicao(
    String metodo,
    String caminho, {
    Map<String, dynamic>? corpo,
    bool auth = false,
  }) async {
    final uri = Uri.parse('$baseUrl$caminho');
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (auth && token != null) headers['Authorization'] = 'Bearer $token';
    final json = corpo == null ? null : jsonEncode(corpo);

    http.Response res;
    try {
      switch (metodo) {
        case 'POST':
          res = await http.post(uri, headers: headers, body: json);
          break;
        case 'DELETE':
          res = await http.delete(uri, headers: headers);
          break;
        default:
          res = await http.get(uri, headers: headers);
      }
    } catch (_) {
      throw ApiException('Não foi possível conectar à API. Verifique sua internet e tente de novo.');
    }

    dynamic dados;
    if (res.body.isNotEmpty) {
      try {
        dados = jsonDecode(utf8.decode(res.bodyBytes));
      } catch (_) {
        dados = {'message': res.body};
      }
    }

    if (res.statusCode < 200 || res.statusCode >= 300) {
      if (res.statusCode == 401 && auth) aoExpirarSessao?.call();
      var msg = 'Erro ${res.statusCode}';
      if (dados is Map && dados['message'] != null) msg = dados['message'].toString();
      throw ApiException(msg, res.statusCode);
    }

    if (dados is Map && dados.containsKey('data')) return dados['data'];
    return dados;
  }

  // ---- Autenticação ----
  Future<Map<String, dynamic>> login(String email, String senha) async {
    final r = await _requisicao('POST', '/login', corpo: {'email': email, 'senha': senha});
    return Map<String, dynamic>.from(r as Map);
  }

  Future<void> cadastrar(Map<String, dynamic> dados) async {
    await _requisicao('POST', '/usuarios', corpo: dados);
  }

  // ---- Categorias ----
  Future<List<Categoria>> categorias() async {
    final r = await _requisicao('GET', '/categorias');
    return (r as List).map((c) => Categoria.fromJson(Map<String, dynamic>.from(c as Map))).toList();
  }

  // ---- Lugares ----
  Future<List<Lugar>> lugares({int pagina = 1, int limite = 10}) async {
    final r = await _requisicao('GET', '/lugares?pagina=$pagina&limite=$limite');
    return (r as List).map((l) => Lugar.fromJson(Map<String, dynamic>.from(l as Map))).toList();
  }

  Future<Lugar> lugar(int id) async {
    final r = await _requisicao('GET', '/lugares/$id');
    return Lugar.fromJson(Map<String, dynamic>.from(r as Map));
  }

  Future<Lugar> criarLugar({
    required String nome,
    required String descricao,
    required int categoriaId,
    double? latitude,
    double? longitude,
  }) async {
    final corpo = <String, dynamic>{
      'nome': nome,
      'descricao': descricao,
      'categoriaId': categoriaId,
    };
    if (latitude != null) corpo['latitude'] = latitude;
    if (longitude != null) corpo['longitude'] = longitude;
    final r = await _requisicao('POST', '/lugares', corpo: corpo, auth: true);
    return Lugar.fromJson(Map<String, dynamic>.from(r as Map));
  }

  Future<void> excluirLugar(int id) async {
    await _requisicao('DELETE', '/lugares/$id', auth: true);
  }

  // ---- Galeria ----
  Future<Foto> adicionarFoto(int lugarId, String urlFoto) async {
    final r = await _requisicao('POST', '/lugares/$lugarId/galeria', corpo: {'urlFoto': urlFoto}, auth: true);
    return Foto.fromJson(Map<String, dynamic>.from(r as Map));
  }

  Future<void> removerFoto(int idFoto) async {
    await _requisicao('DELETE', '/galeria/$idFoto', auth: true);
  }

  // ---- Favoritos ----
  Future<List<Lugar>> favoritos() async {
    final r = await _requisicao('GET', '/favoritos', auth: true);
    return (r as List).map((l) => Lugar.fromJson(Map<String, dynamic>.from(l as Map))).toList();
  }

  Future<void> favoritar(int lugarId) async {
    await _requisicao('POST', '/favoritos/$lugarId', auth: true);
  }

  Future<void> desfavoritar(int lugarId) async {
    await _requisicao('DELETE', '/favoritos/$lugarId', auth: true);
  }
}

final ApiClient api = ApiClient.instance;
