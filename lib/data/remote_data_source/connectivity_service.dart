import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged;

  Future<bool> hasInternetConnection() async {
    final connectivityResults = await _connectivity.checkConnectivity();
    if (connectivityResults.contains(ConnectivityResult.none)) {
      return false;
    }

    try {
      final response = await http
          .get(Uri.parse('https://clients3.google.com/generate_204'))
          .timeout(const Duration(seconds: 4));

      return response.statusCode == 204;
    } catch (_) {
      return false;
    }
  }
}
