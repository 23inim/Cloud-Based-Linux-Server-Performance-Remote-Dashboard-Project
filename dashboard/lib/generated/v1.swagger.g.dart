// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'v1.swagger.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Status _$StatusFromJson(Map<String, dynamic> json) => Status(
      totalMem: (json['totalMem'] as num?)?.toDouble(),
      usedMem: (json['usedMem'] as num?)?.toDouble(),
      freeMem: (json['freeMem'] as num?)?.toDouble(),
      totalSwap: (json['totalSwap'] as num?)?.toDouble(),
      usedSwap: (json['usedSwap'] as num?)?.toDouble(),
      freeSwap: (json['freeSwap'] as num?)?.toDouble(),
      cpuUsage: (json['cpuUsage'] as num?)?.toDouble(),
      diskW: (json['diskW'] as num?)?.toDouble(),
      diskR: (json['diskR'] as num?)?.toDouble(),
      rxBytes: (json['rxBytes'] as num?)?.toDouble(),
      txBytes: (json['txBytes'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$StatusToJson(Status instance) => <String, dynamic>{
      'totalMem': instance.totalMem,
      'usedMem': instance.usedMem,
      'freeMem': instance.freeMem,
      'totalSwap': instance.totalSwap,
      'usedSwap': instance.usedSwap,
      'freeSwap': instance.freeSwap,
      'cpuUsage': instance.cpuUsage,
      'diskW': instance.diskW,
      'diskR': instance.diskR,
      'rxBytes': instance.rxBytes,
      'txBytes': instance.txBytes,
    };

StressParam _$StressParamFromJson(Map<String, dynamic> json) => StressParam(
      type: (json['type'] as num?)?.toInt(),
      duration: (json['duration'] as num?)?.toInt(),
    );

Map<String, dynamic> _$StressParamToJson(StressParam instance) =>
    <String, dynamic>{
      'type': instance.type,
      'duration': instance.duration,
    };

WeatherForecast _$WeatherForecastFromJson(Map<String, dynamic> json) =>
    WeatherForecast(
      date:
          json['date'] == null ? null : DateTime.parse(json['date'] as String),
      temperatureC: (json['temperatureC'] as num?)?.toInt(),
      temperatureF: (json['temperatureF'] as num?)?.toInt(),
      summary: json['summary'] as String?,
    );

Map<String, dynamic> _$WeatherForecastToJson(WeatherForecast instance) =>
    <String, dynamic>{
      'date': _dateToJson(instance.date),
      'temperatureC': instance.temperatureC,
      'temperatureF': instance.temperatureF,
      'summary': instance.summary,
    };
