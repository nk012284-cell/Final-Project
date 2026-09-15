import 'package:dio/dio.dart';

class RemoteException implements Exception {
  DioException dioException;
  RemoteException(this.dioException);
}
