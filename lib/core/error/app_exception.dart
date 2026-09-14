sealed class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => '$runtimeType: $message';
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'Pas de connexion Internet. Vérifiez votre réseau.']);
}

class ServerException extends AppException {
  final int? statusCode;
  const ServerException([super.message = 'Erreur du serveur.', this.statusCode]);
}

class CacheException extends AppException {
  const CacheException([super.message = 'Erreur de lecture du cache local.']);
}

class AuthException extends AppException {
  const AuthException([super.message = "Erreur d'authentification."]);
}

class ValidationException extends AppException {
  const ValidationException([super.message = 'Veuillez remplir tous les champs.']);
}
