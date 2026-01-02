import 'package:uuid/uuid.dart';

class ExerciseSession {
  ExerciseSession({
    String? id,
    required this.userId,
    required this.exerciseId,
    required this.date,
    required this.setsCompleted,
    required this.repsCompleted,
    required this.durationSeconds,
  }) : id = id ?? const Uuid().v4();

  final String id;
  final String userId;
  final String exerciseId;
  final DateTime date;
  final int setsCompleted;
  final int repsCompleted;
  final int durationSeconds;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'exerciseId': exerciseId,
      'date': date.toIso8601String(),
      'setsCompleted': setsCompleted,
      'repsCompleted': repsCompleted,
      'durationSeconds': durationSeconds,
    };
  }

  factory ExerciseSession.fromJson(Map<String, dynamic> json) {
    return ExerciseSession(
      id: json['id'] as String?,
      userId: json['userId'] as String,
      exerciseId: json['exerciseId'] as String,
      date: DateTime.parse(json['date'] as String),
      setsCompleted: json['setsCompleted'] as int,
      repsCompleted: json['repsCompleted'] as int,
      durationSeconds: json['durationSeconds'] as int,
    );
  }
}
