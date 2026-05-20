// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weekly_report_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WeeklyReportModelAdapter extends TypeAdapter<WeeklyReportModel> {
  @override
  final int typeId = 6;

  @override
  WeeklyReportModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WeeklyReportModel(
      id: fields[0] as String,
      startDate: fields[1] as DateTime,
      endDate: fields[2] as DateTime,
      sleepQuality: fields[3] as String,
      sleepImprovement: fields[4] as String,
      moodStatus: fields[5] as String,
      moodImprovement: fields[6] as String,
      activityStatus: fields[7] as String,
      activityChange: fields[8] as String,
      avgHeartRate: fields[9] as String,
      dailyHydration: fields[10] as String,
      sleepData: (fields[11] as List).cast<double>(),
    );
  }

  @override
  void write(BinaryWriter writer, WeeklyReportModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.startDate)
      ..writeByte(2)
      ..write(obj.endDate)
      ..writeByte(3)
      ..write(obj.sleepQuality)
      ..writeByte(4)
      ..write(obj.sleepImprovement)
      ..writeByte(5)
      ..write(obj.moodStatus)
      ..writeByte(6)
      ..write(obj.moodImprovement)
      ..writeByte(7)
      ..write(obj.activityStatus)
      ..writeByte(8)
      ..write(obj.activityChange)
      ..writeByte(9)
      ..write(obj.avgHeartRate)
      ..writeByte(10)
      ..write(obj.dailyHydration)
      ..writeByte(11)
      ..write(obj.sleepData);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeeklyReportModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
