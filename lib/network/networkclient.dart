import 'package:dio/dio.dart';
import 'package:mobil_app_project/errors/exception.dart';
import 'package:mobil_app_project/utils/constants.dart';

class NetworkClient {
  String? _baseURL;
  Dio _dio = Dio();

  NetworkClient({this._baseURL}) {
    _baseURL ??= Constants.baseURL;

    final baseOptions = BaseOptions(
      receiveTimeout: Duration(seconds: 120),
      connectTimeout: Duration(seconds: 120),
      baseUrl: _baseURL!,
      maxRedirects: 2,
      contentType: "application/json",
    );

    _dio = Dio(baseOptions);

    _dio.interceptors.add(
      LogInterceptor(request: true, responseBody: true, error: true),
    );
  }

  Future<Response> post(
    String url,
    Map<String, dynamic> params, {
    String? token,
  }) async {
    Response respone;

    try {
      Map<String, dynamic> map = {"Accept": "application/json"};

      if (token != null) {
        map.addAll({"Authorization": "Bearer $token"});
      }
      respone = await _dio.post(
        url,
        data: params,
        options: Options(
          headers: map,
          responseType: ResponseType.json,
          validateStatus: (_) => true,
        ),
      );
    } on DioException catch (e) {
      throw RemoteException(e);
    }
    return respone;
  }

  Future<Response> get(
    String url, {
    Map<String, dynamic>? params,
    String? token,
  }) async {
    Response respone;

    try {
      Map<String, dynamic> map = {"Accept": "application/json"};

      if (token != null) {
        map.addAll({"Authorization": "Bearer $token"});
      }
      respone = await _dio.get(
        url,
        queryParameters: params,
        options: Options(headers: map),
      );
    } on DioException catch (e) {
      throw RemoteException(e);
    }
    return respone;
  }

  Future<Response> put(
    String url,
    Map<String, dynamic> params, {
    String? token,
  }) async {
    Response respone;

    try {
      Map<String, dynamic> map = {"Accept": "application/json"};

      if (token != null) {
        map.addAll({"Authorization": "Bearer $token"});
      }
      respone = await _dio.put(
        url,
        data: params,
        options: Options(
          headers: map,
          responseType: ResponseType.json,
          validateStatus: (_) => true,
        ),
      );
    } on DioException catch (e) {
      throw RemoteException(e);
    }
    return respone;
  }

  Future<Response> patch(
    String url,
    Map<String, dynamic> params, {
    String? token,
  }) async {
    try {
      final headers = <String, dynamic>{"Accept": "application/json"};
      if (token != null) {
        headers["Authorization"] = "Bearer $token";
      }
      return await _dio.patch(
        url,
        data: params,
        options: Options(
          headers: headers,
          responseType: ResponseType.json,
          validateStatus: (_) => true,
        ),
      );
    } on DioException catch (e) {
      throw RemoteException(e);
    }
  }

  Future<Response> delete(
    String url, {
    Map<String, dynamic>? params,
    String? token,
  }) async {
    Response respone;

    try {
      Map<String, dynamic> map = {"Accept": "application/json"};

      if (token != null) {
        map.addAll({"Authorization": "Bearer $token"});
      }
      respone = await _dio.delete(
        url,
        data: params,
        options: Options(
          headers: map,
          responseType: ResponseType.json,
          validateStatus: (_) => true,
        ),
      );
    } on DioException catch (e) {
      throw RemoteException(e);
    }
    return respone;
  }
}
