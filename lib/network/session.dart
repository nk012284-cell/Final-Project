import 'package:mobil_app_project/models/authentication/jwt_response_model.dart';

class Session {
  Session._();

  static final Session instance = Session._();

  JwtResponse? credentials;

  String? get accessToken => credentials?.token;
  String? get refreshToken => credentials?.refreshToken;

  void setCredentials(JwtResponse value) {
    credentials = value;
  }

  void clear() {
    credentials = null;
  }
}
