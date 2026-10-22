import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>?> buscarCep(String cep) async {
  final r = await http
      .get(Uri.parse('https://viacep.com.br/ws/$cep/json/'))
      .timeout(const Duration(seconds: 10));
  if (r.statusCode != 200) return null;
  final data = jsonDecode(r.body) as Map<String, dynamic>;
  return data['erro'] == true ? null : data;
}