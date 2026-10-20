import 'package:flutter/material.dart';

import '../theme.dart';

// Imagem da internet com carregamento e plano B caso o link esteja quebrado
class FotoRede extends StatelessWidget {
  final String? url;
  final String letra;
  final BoxFit fit;

  const FotoRede({super.key, required this.url, this.letra = '?', this.fit = BoxFit.cover});

  Widget _vazio() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFFDFE8DD), Color(0xFFF0DCCD)]),
      ),
      alignment: Alignment.center,
      child: Text(
        letra.isEmpty ? '?' : letra.substring(0, 1).toUpperCase(),
        style: titulo(40, cor: verde),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.trim().isEmpty) return _vazio();
    return Image.network(
      url!,
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, __, ___) => _vazio(),
      loadingBuilder: (context, child, progresso) {
        if (progresso == null) return child;
        return Container(
          color: const Color(0xFFE9E2D0),
          alignment: Alignment.center,
          child: const SizedBox(
            width: 26,
            height: 26,
            child: CircularProgressIndicator(strokeWidth: 2.5, color: verde),
          ),
        );
      },
    );
  }
}
