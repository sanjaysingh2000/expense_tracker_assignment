import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyService {
  Future<double> convert({
    required String from,
    required String to,
    required double amount,
  }) async {
    try {
      final url = 'https://open.er-api.com/v6/latest/$from';


      final response = await http.get(Uri.parse(url));

      final data = jsonDecode(response.body);


      if (data['result'] == 'success') {
        final rate = data['rates'][to];

        if (rate == null) return 0.0;

        final converted = amount * rate;


        return converted;
      }

      return 0.0;
    } catch (e) {
      return 0.0;
    }
  }
}
