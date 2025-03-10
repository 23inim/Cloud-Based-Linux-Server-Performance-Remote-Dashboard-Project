// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'v1.swagger.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$V1 extends V1 {
  _$V1([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = V1;

  @override
  Future<Response<String>> _stressngGet() {
    final Uri $url = Uri.parse('/Stressng');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<String, String>($request);
  }

  @override
  Future<Response<dynamic>> _stressngPost({required StressParam? body}) {
    final Uri $url = Uri.parse('/Stressng');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<List<Status>>> _stressngGetHistoryGet() {
    final Uri $url = Uri.parse('/Stressng/GetHistory');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<List<Status>, Status>($request);
  }

  @override
  Future<Response<List<WeatherForecast>>> _weatherForecastGet() {
    final Uri $url = Uri.parse('/WeatherForecast');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<List<WeatherForecast>, WeatherForecast>($request);
  }
}
