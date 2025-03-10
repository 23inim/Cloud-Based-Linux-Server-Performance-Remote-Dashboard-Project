// ignore_for_file: type=lint

import 'package:json_annotation/json_annotation.dart';
import 'package:json_annotation/json_annotation.dart' as json;
import 'package:collection/collection.dart';
import 'dart:convert';

import 'package:chopper/chopper.dart';

import 'client_mapping.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:http/http.dart' show MultipartFile;
import 'package:chopper/chopper.dart' as chopper;

part 'v1.swagger.chopper.dart';
part 'v1.swagger.g.dart';

// **************************************************************************
// SwaggerChopperGenerator
// **************************************************************************

@ChopperApi()
abstract class V1 extends ChopperService {
  static V1 create({
    ChopperClient? client,
    http.Client? httpClient,
    Authenticator? authenticator,
    ErrorConverter? errorConverter,
    Converter? converter,
    Uri? baseUrl,
    List<Interceptor>? interceptors,
  }) {
    if (client != null) {
      return _$V1(client);
    }

    final newClient = ChopperClient(
        services: [_$V1()],
        converter: converter ?? $JsonSerializableConverter(),
        interceptors: interceptors ?? [],
        client: httpClient,
        authenticator: authenticator,
        errorConverter: errorConverter,
        baseUrl: baseUrl ?? Uri.parse('http://'));
    return _$V1(newClient);
  }

  ///
  Future<chopper.Response<String>> stressngGet() {
    return _stressngGet();
  }

  ///
  @Get(path: '/Stressng')
  Future<chopper.Response<String>> _stressngGet();

  ///
  Future<chopper.Response> stressngPost({required StressParam? body}) {
    return _stressngPost(body: body);
  }

  ///
  @Post(
    path: '/Stressng',
    optionalBody: true,
  )
  Future<chopper.Response> _stressngPost({@Body() required StressParam? body});

  ///
  Future<chopper.Response<List<Status>>> stressngGetHistoryGet() {
    generatedMapping.putIfAbsent(Status, () => Status.fromJsonFactory);

    return _stressngGetHistoryGet();
  }

  ///
  @Get(path: '/Stressng/GetHistory')
  Future<chopper.Response<List<Status>>> _stressngGetHistoryGet();

  ///
  Future<chopper.Response<List<WeatherForecast>>> weatherForecastGet() {
    generatedMapping.putIfAbsent(
        WeatherForecast, () => WeatherForecast.fromJsonFactory);

    return _weatherForecastGet();
  }

  ///
  @Get(path: '/WeatherForecast')
  Future<chopper.Response<List<WeatherForecast>>> _weatherForecastGet();
}

@JsonSerializable(explicitToJson: true)
class Status {
  const Status({
    this.totalMem,
    this.usedMem,
    this.freeMem,
    this.totalSwap,
    this.usedSwap,
    this.freeSwap,
    this.cpuUsage,
    this.diskW,
    this.diskR,
    this.rxBytes,
    this.txBytes,
  });

  factory Status.fromJson(Map<String, dynamic> json) => _$StatusFromJson(json);

  static const toJsonFactory = _$StatusToJson;
  Map<String, dynamic> toJson() => _$StatusToJson(this);

  @JsonKey(name: 'totalMem')
  final double? totalMem;
  @JsonKey(name: 'usedMem')
  final double? usedMem;
  @JsonKey(name: 'freeMem')
  final double? freeMem;
  @JsonKey(name: 'totalSwap')
  final double? totalSwap;
  @JsonKey(name: 'usedSwap')
  final double? usedSwap;
  @JsonKey(name: 'freeSwap')
  final double? freeSwap;
  @JsonKey(name: 'cpuUsage')
  final double? cpuUsage;
  @JsonKey(name: 'diskW')
  final double? diskW;
  @JsonKey(name: 'diskR')
  final double? diskR;
  @JsonKey(name: 'rxBytes')
  final double? rxBytes;
  @JsonKey(name: 'txBytes')
  final double? txBytes;
  static const fromJsonFactory = _$StatusFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is Status &&
            (identical(other.totalMem, totalMem) ||
                const DeepCollectionEquality()
                    .equals(other.totalMem, totalMem)) &&
            (identical(other.usedMem, usedMem) ||
                const DeepCollectionEquality()
                    .equals(other.usedMem, usedMem)) &&
            (identical(other.freeMem, freeMem) ||
                const DeepCollectionEquality()
                    .equals(other.freeMem, freeMem)) &&
            (identical(other.totalSwap, totalSwap) ||
                const DeepCollectionEquality()
                    .equals(other.totalSwap, totalSwap)) &&
            (identical(other.usedSwap, usedSwap) ||
                const DeepCollectionEquality()
                    .equals(other.usedSwap, usedSwap)) &&
            (identical(other.freeSwap, freeSwap) ||
                const DeepCollectionEquality()
                    .equals(other.freeSwap, freeSwap)) &&
            (identical(other.cpuUsage, cpuUsage) ||
                const DeepCollectionEquality()
                    .equals(other.cpuUsage, cpuUsage)) &&
            (identical(other.diskW, diskW) ||
                const DeepCollectionEquality().equals(other.diskW, diskW)) &&
            (identical(other.diskR, diskR) ||
                const DeepCollectionEquality().equals(other.diskR, diskR)) &&
            (identical(other.rxBytes, rxBytes) ||
                const DeepCollectionEquality()
                    .equals(other.rxBytes, rxBytes)) &&
            (identical(other.txBytes, txBytes) ||
                const DeepCollectionEquality().equals(other.txBytes, txBytes)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(totalMem) ^
      const DeepCollectionEquality().hash(usedMem) ^
      const DeepCollectionEquality().hash(freeMem) ^
      const DeepCollectionEquality().hash(totalSwap) ^
      const DeepCollectionEquality().hash(usedSwap) ^
      const DeepCollectionEquality().hash(freeSwap) ^
      const DeepCollectionEquality().hash(cpuUsage) ^
      const DeepCollectionEquality().hash(diskW) ^
      const DeepCollectionEquality().hash(diskR) ^
      const DeepCollectionEquality().hash(rxBytes) ^
      const DeepCollectionEquality().hash(txBytes) ^
      runtimeType.hashCode;
}

extension $StatusExtension on Status {
  Status copyWith(
      {double? totalMem,
      double? usedMem,
      double? freeMem,
      double? totalSwap,
      double? usedSwap,
      double? freeSwap,
      double? cpuUsage,
      double? diskW,
      double? diskR,
      double? rxBytes,
      double? txBytes}) {
    return Status(
        totalMem: totalMem ?? this.totalMem,
        usedMem: usedMem ?? this.usedMem,
        freeMem: freeMem ?? this.freeMem,
        totalSwap: totalSwap ?? this.totalSwap,
        usedSwap: usedSwap ?? this.usedSwap,
        freeSwap: freeSwap ?? this.freeSwap,
        cpuUsage: cpuUsage ?? this.cpuUsage,
        diskW: diskW ?? this.diskW,
        diskR: diskR ?? this.diskR,
        rxBytes: rxBytes ?? this.rxBytes,
        txBytes: txBytes ?? this.txBytes);
  }

  Status copyWithWrapped(
      {Wrapped<double?>? totalMem,
      Wrapped<double?>? usedMem,
      Wrapped<double?>? freeMem,
      Wrapped<double?>? totalSwap,
      Wrapped<double?>? usedSwap,
      Wrapped<double?>? freeSwap,
      Wrapped<double?>? cpuUsage,
      Wrapped<double?>? diskW,
      Wrapped<double?>? diskR,
      Wrapped<double?>? rxBytes,
      Wrapped<double?>? txBytes}) {
    return Status(
        totalMem: (totalMem != null ? totalMem.value : this.totalMem),
        usedMem: (usedMem != null ? usedMem.value : this.usedMem),
        freeMem: (freeMem != null ? freeMem.value : this.freeMem),
        totalSwap: (totalSwap != null ? totalSwap.value : this.totalSwap),
        usedSwap: (usedSwap != null ? usedSwap.value : this.usedSwap),
        freeSwap: (freeSwap != null ? freeSwap.value : this.freeSwap),
        cpuUsage: (cpuUsage != null ? cpuUsage.value : this.cpuUsage),
        diskW: (diskW != null ? diskW.value : this.diskW),
        diskR: (diskR != null ? diskR.value : this.diskR),
        rxBytes: (rxBytes != null ? rxBytes.value : this.rxBytes),
        txBytes: (txBytes != null ? txBytes.value : this.txBytes));
  }
}

@JsonSerializable(explicitToJson: true)
class StressParam {
  const StressParam({
    this.type,
    this.duration,
  });

  factory StressParam.fromJson(Map<String, dynamic> json) =>
      _$StressParamFromJson(json);

  static const toJsonFactory = _$StressParamToJson;
  Map<String, dynamic> toJson() => _$StressParamToJson(this);

  @JsonKey(name: 'type')
  final int? type;
  @JsonKey(name: 'duration')
  final int? duration;
  static const fromJsonFactory = _$StressParamFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is StressParam &&
            (identical(other.type, type) ||
                const DeepCollectionEquality().equals(other.type, type)) &&
            (identical(other.duration, duration) ||
                const DeepCollectionEquality()
                    .equals(other.duration, duration)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(type) ^
      const DeepCollectionEquality().hash(duration) ^
      runtimeType.hashCode;
}

extension $StressParamExtension on StressParam {
  StressParam copyWith({int? type, int? duration}) {
    return StressParam(
        type: type ?? this.type, duration: duration ?? this.duration);
  }

  StressParam copyWithWrapped({Wrapped<int?>? type, Wrapped<int?>? duration}) {
    return StressParam(
        type: (type != null ? type.value : this.type),
        duration: (duration != null ? duration.value : this.duration));
  }
}

@JsonSerializable(explicitToJson: true)
class WeatherForecast {
  const WeatherForecast({
    this.date,
    this.temperatureC,
    this.temperatureF,
    this.summary,
  });

  factory WeatherForecast.fromJson(Map<String, dynamic> json) =>
      _$WeatherForecastFromJson(json);

  static const toJsonFactory = _$WeatherForecastToJson;
  Map<String, dynamic> toJson() => _$WeatherForecastToJson(this);

  @JsonKey(name: 'date', toJson: _dateToJson)
  final DateTime? date;
  @JsonKey(name: 'temperatureC')
  final int? temperatureC;
  @JsonKey(name: 'temperatureF')
  final int? temperatureF;
  @JsonKey(name: 'summary')
  final String? summary;
  static const fromJsonFactory = _$WeatherForecastFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is WeatherForecast &&
            (identical(other.date, date) ||
                const DeepCollectionEquality().equals(other.date, date)) &&
            (identical(other.temperatureC, temperatureC) ||
                const DeepCollectionEquality()
                    .equals(other.temperatureC, temperatureC)) &&
            (identical(other.temperatureF, temperatureF) ||
                const DeepCollectionEquality()
                    .equals(other.temperatureF, temperatureF)) &&
            (identical(other.summary, summary) ||
                const DeepCollectionEquality().equals(other.summary, summary)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(date) ^
      const DeepCollectionEquality().hash(temperatureC) ^
      const DeepCollectionEquality().hash(temperatureF) ^
      const DeepCollectionEquality().hash(summary) ^
      runtimeType.hashCode;
}

extension $WeatherForecastExtension on WeatherForecast {
  WeatherForecast copyWith(
      {DateTime? date, int? temperatureC, int? temperatureF, String? summary}) {
    return WeatherForecast(
        date: date ?? this.date,
        temperatureC: temperatureC ?? this.temperatureC,
        temperatureF: temperatureF ?? this.temperatureF,
        summary: summary ?? this.summary);
  }

  WeatherForecast copyWithWrapped(
      {Wrapped<DateTime?>? date,
      Wrapped<int?>? temperatureC,
      Wrapped<int?>? temperatureF,
      Wrapped<String?>? summary}) {
    return WeatherForecast(
        date: (date != null ? date.value : this.date),
        temperatureC:
            (temperatureC != null ? temperatureC.value : this.temperatureC),
        temperatureF:
            (temperatureF != null ? temperatureF.value : this.temperatureF),
        summary: (summary != null ? summary.value : this.summary));
  }
}

typedef $JsonFactory<T> = T Function(Map<String, dynamic> json);

class $CustomJsonDecoder {
  $CustomJsonDecoder(this.factories);

  final Map<Type, $JsonFactory> factories;

  dynamic decode<T>(dynamic entity) {
    if (entity is Iterable) {
      return _decodeList<T>(entity);
    }

    if (entity is T) {
      return entity;
    }

    if (isTypeOf<T, Map>()) {
      return entity;
    }

    if (isTypeOf<T, Iterable>()) {
      return entity;
    }

    if (entity is Map<String, dynamic>) {
      return _decodeMap<T>(entity);
    }

    return entity;
  }

  T _decodeMap<T>(Map<String, dynamic> values) {
    final jsonFactory = factories[T];
    if (jsonFactory == null || jsonFactory is! $JsonFactory<T>) {
      return throw "Could not find factory for type $T. Is '$T: $T.fromJsonFactory' included in the CustomJsonDecoder instance creation in bootstrapper.dart?";
    }

    return jsonFactory(values);
  }

  List<T> _decodeList<T>(Iterable values) =>
      values.where((v) => v != null).map<T>((v) => decode<T>(v) as T).toList();
}

class $JsonSerializableConverter extends chopper.JsonConverter {
  @override
  FutureOr<chopper.Response<ResultType>> convertResponse<ResultType, Item>(
      chopper.Response response) async {
    if (response.bodyString.isEmpty) {
      // In rare cases, when let's say 204 (no content) is returned -
      // we cannot decode the missing json with the result type specified
      return chopper.Response(response.base, null, error: response.error);
    }

    if (ResultType == String) {
      return response.copyWith();
    }

    if (ResultType == DateTime) {
      return response.copyWith(
          body: DateTime.parse((response.body as String).replaceAll('"', ''))
              as ResultType);
    }

    final jsonRes = await super.convertResponse(response);
    return jsonRes.copyWith<ResultType>(
        body: $jsonDecoder.decode<Item>(jsonRes.body) as ResultType);
  }
}

final $jsonDecoder = $CustomJsonDecoder(generatedMapping);

// ignore: unused_element
String? _dateToJson(DateTime? date) {
  if (date == null) {
    return null;
  }

  final year = date.year.toString();
  final month = date.month < 10 ? '0${date.month}' : date.month.toString();
  final day = date.day < 10 ? '0${date.day}' : date.day.toString();

  return '$year-$month-$day';
}

class Wrapped<T> {
  final T value;
  const Wrapped.value(this.value);
}
