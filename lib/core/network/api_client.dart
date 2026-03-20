import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cookie_jar/cookie_jar.dart';

class ApiClient {
  late final Dio dio;
  late final PersistCookieJar cookieJar;

  ApiClient._internal(this.dio, this.cookieJar);

  String _resolvePath(String path, Map<String, dynamic>? pathParams) {
    if (pathParams == null) return path;

    pathParams.forEach((key, value) {
      path = path.replaceAll('{$key}', Uri.encodeComponent(value.toString()));
    });

    return path;
  }

  static Future<ApiClient> create() async {
    final dio = Dio(
      BaseOptions(
        baseUrl: "https://epoque.kiet.edu/api/",
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {"Content-Type": "application/json"},
        validateStatus: (status) {
          return status != null && status < 500;
        },
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final cookieJar = PersistCookieJar(
      storage: FileStorage("${dir.path}/.cookies/"),
      ignoreExpires: false,
    );

    dio.interceptors.add(CookieManager(cookieJar));

    dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));

    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            print("Unauthorized - maybe session expired");
          }
          return handler.next(error);
        },
      ),
    );

    return ApiClient._internal(dio, cookieJar);
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? pathParams,
    Options? options,
  }) {
    final resolvedPath = _resolvePath(path, pathParams);

    return dio.get<T>(
      resolvedPath,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? pathParams,
    Options? options,
  }) {
    final resolvedPath = _resolvePath(path, pathParams);

    return dio.post<T>(
      resolvedPath,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? pathParams,
    Options? options,
  }) {
    final resolvedPath = _resolvePath(path, pathParams);

    return dio.put<T>(
      resolvedPath,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? pathParams,
    Options? options,
  }) {
    final resolvedPath = _resolvePath(path, pathParams);

    return dio.delete<T>(
      resolvedPath,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<void> clearCookies() async {
    await cookieJar.deleteAll();
  }
}
