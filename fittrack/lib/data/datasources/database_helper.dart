import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';
import '../models/exercise.dart';
import '../models/exercise_session.dart';
import '../../core/constants/enums.dart';
import 'exercise_seeder.dart';

class DatabaseHelper {
  static Database? _database;
  static const String _dbName = 'fittrack.db';
  static const int _dbVersion = 1;

  static final DatabaseHelper instance = DatabaseHelper._init();

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    return await openDatabase(path, version: _dbVersion, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT,
        age INTEGER NOT NULL,
        gender TEXT NOT NULL,
        weight REAL NOT NULL,
        height REAL NOT NULL,
        selectedPlan TEXT NOT NULL,
        selectedLevel TEXT NOT NULL,
        selectedCategories TEXT NOT NULL,
        selectedDays TEXT NOT NULL,
        hasCompletedAssessment INTEGER NOT NULL DEFAULT 0,
        createdAt TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await db.execute('''
      CREATE TABLE exercises (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        imageUrl TEXT NOT NULL,
        videoUrl TEXT,
        categories TEXT NOT NULL,
        plan TEXT NOT NULL,
        bodyTarget TEXT NOT NULL,
        sectionType TEXT NOT NULL,
        baseSets INTEGER NOT NULL,
        baseReps INTEGER NOT NULL,
        baseDuration INTEGER NOT NULL,
        restPeriod INTEGER NOT NULL,
        targetMuscles TEXT NOT NULL,
        equipment TEXT NOT NULL,
        instructions TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE exercise_sessions (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        exerciseId TEXT NOT NULL,
        date TEXT NOT NULL,
        setsCompleted INTEGER NOT NULL,
        repsCompleted INTEGER NOT NULL,
        durationSeconds INTEGER NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (exerciseId) REFERENCES exercises (id) ON DELETE CASCADE
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_sessions_userId ON exercise_sessions (userId)',
    );
    await db.execute(
      'CREATE INDEX idx_sessions_date ON exercise_sessions (date)',
    );

    await _seedExercises(db);
  }

  Future<void> _seedExercises(Database db) async {
    final exercises = ExerciseSeeder.getSeedExercises();
    for (final e in exercises) {
      await db.insert('exercises', _exerciseToMap(e));
    }
  }

  Future<void> resetDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
    await deleteDatabase(path);
    _database = await _initDatabase();
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  Future<void> insertUser(User user) async {
    final db = await database;
    await db.insert(
      'users',
      _userToMap(user),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateUser(User user) async {
    final db = await database;
    await db.update(
      'users',
      _userToMap(user),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<List<User>> getAllUsers() async {
    final db = await database;
    final maps = await db.query('users');
    return maps.map((m) => _userFromMap(m)).toList();
  }

  Future<User?> getUserById(String id) async {
    final db = await database;
    final maps = await db.query('users', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return _userFromMap(maps.first);
  }

  Future<User?> getUserByUsername(String username) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'LOWER(name) = LOWER(?)',
      whereArgs: [username],
    );
    if (maps.isEmpty) return null;
    return _userFromMap(maps.first);
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'LOWER(email) = LOWER(?)',
      whereArgs: [email],
    );
    if (maps.isEmpty) return null;
    return _userFromMap(maps.first);
  }

  Future<void> deleteUser(String id) async {
    final db = await database;
    await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteAllUsers() async {
    final db = await database;
    await db.delete('users');
  }

  Future<List<Exercise>> getAllExercises() async {
    final db = await database;
    final maps = await db.query('exercises');
    return maps.map((m) => _exerciseFromMap(m)).toList();
  }

  Future<List<Exercise>> getExercisesByPlan(Plan plan) async {
    final db = await database;
    final maps = await db.query(
      'exercises',
      where: 'plan = ?',
      whereArgs: [plan.name],
    );
    return maps.map((m) => _exerciseFromMap(m)).toList();
  }

  Future<List<Exercise>> getExercisesBySection(SectionType section) async {
    final db = await database;
    final maps = await db.query(
      'exercises',
      where: 'sectionType = ?',
      whereArgs: [section.name],
    );
    return maps.map((m) => _exerciseFromMap(m)).toList();
  }

  Future<List<Exercise>> getExercisesForUser(User user) async {
    final all = await getAllExercises();
    return all.where((e) {
      if (e.plan != user.selectedPlan) return false;
      return e.categories.any((c) => user.selectedCategories.contains(c));
    }).toList();
  }

  Future<void> insertExercise(Exercise exercise) async {
    final db = await database;
    await db.insert(
      'exercises',
      _exerciseToMap(exercise),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertSession(ExerciseSession session) async {
    final db = await database;
    await db.insert(
      'exercise_sessions',
      _sessionToMap(session),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ExerciseSession>> getSessionsForUser(String userId) async {
    final db = await database;
    final maps = await db.query(
      'exercise_sessions',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );
    return maps.map((m) => _sessionFromMap(m)).toList();
  }

  Future<List<ExerciseSession>> getSessionsInRange(
    String userId,
    DateTime start,
    DateTime end,
  ) async {
    final db = await database;
    final maps = await db.query(
      'exercise_sessions',
      where: 'userId = ? AND date >= ? AND date <= ?',
      whereArgs: [userId, start.toIso8601String(), end.toIso8601String()],
      orderBy: 'date DESC',
    );
    return maps.map((m) => _sessionFromMap(m)).toList();
  }

  Future<void> deleteSession(String id) async {
    final db = await database;
    await db.delete('exercise_sessions', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteUserSessions(String userId) async {
    final db = await database;
    await db.delete(
      'exercise_sessions',
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }

  Map<String, dynamic> _userToMap(User user) => {
    'id': user.id,
    'name': user.name,
    'email': user.email,
    'password': user.password,
    'age': user.age,
    'gender': user.gender.name,
    'weight': user.weight,
    'height': user.height,
    'selectedPlan': user.selectedPlan.name,
    'selectedLevel': user.selectedLevel.name,
    'selectedCategories': user.selectedCategories.map((c) => c.name).join(','),
    'selectedDays': user.selectedDays.map((d) => d.name).join(','),
    'hasCompletedAssessment': user.hasCompletedAssessment ? 1 : 0,
    'createdAt': user.createdAt.toIso8601String(),
  };

  User _userFromMap(Map<String, dynamic> m) => User(
    id: m['id'] as String,
    name: m['name'] as String,
    email: m['email'] as String,
    password: m['password'] as String?,
    age: m['age'] as int,
    gender: Gender.values.firstWhere((g) => g.name == m['gender']),
    weight: (m['weight'] as num).toDouble(),
    height: (m['height'] as num).toDouble(),
    selectedPlan: Plan.values.firstWhere((p) => p.name == m['selectedPlan']),
    selectedLevel: Level.values.firstWhere((l) => l.name == m['selectedLevel']),
    selectedCategories: (m['selectedCategories'] as String)
        .split(',')
        .where((s) => s.isNotEmpty)
        .map((c) => Categories.values.firstWhere((cat) => cat.name == c))
        .toList(),
    selectedDays: (m['selectedDays'] as String)
        .split(',')
        .where((s) => s.isNotEmpty)
        .map((d) => DayOfWeek.values.firstWhere((day) => day.name == d))
        .toList(),
    hasCompletedAssessment: m['hasCompletedAssessment'] == 1,
    createdAt: DateTime.parse(m['createdAt'] as String),
  );

  Map<String, dynamic> _exerciseToMap(Exercise e) => {
    'id': e.id,
    'name': e.name,
    'description': e.description,
    'imageUrl': e.imageUrl,
    'videoUrl': e.videoUrl,
    'categories': e.categories.map((c) => c.name).join(','),
    'plan': e.plan.name,
    'bodyTarget': e.bodyTarget.name,
    'sectionType': e.sectionType.name,
    'baseSets': e.baseSets,
    'baseReps': e.baseReps,
    'baseDuration': e.baseDuration,
    'restPeriod': e.restPeriod,
    'targetMuscles': e.targetMuscles.join(','),
    'equipment': e.equipment,
    'instructions': e.instructions.join('|'),
  };

  Exercise _exerciseFromMap(Map<String, dynamic> m) => Exercise(
    id: m['id'] as String,
    name: m['name'] as String,
    description: m['description'] as String,
    imageUrl: m['imageUrl'] as String,
    videoUrl: m['videoUrl'] as String?,
    categories: (m['categories'] as String)
        .split(',')
        .where((s) => s.isNotEmpty)
        .map((c) => Categories.values.firstWhere((cat) => cat.name == c))
        .toList(),
    plan: Plan.values.firstWhere((p) => p.name == m['plan']),
    bodyTarget: BodyTarget.values.firstWhere((b) => b.name == m['bodyTarget']),
    sectionType: SectionType.values.firstWhere(
      (s) => s.name == m['sectionType'],
    ),
    baseSets: m['baseSets'] as int,
    baseReps: m['baseReps'] as int,
    baseDuration: m['baseDuration'] as int,
    restPeriod: m['restPeriod'] as int,
    targetMuscles: (m['targetMuscles'] as String)
        .split(',')
        .where((s) => s.isNotEmpty)
        .toList(),
    equipment: m['equipment'] as String,
    instructions: (m['instructions'] as String)
        .split('|')
        .where((s) => s.isNotEmpty)
        .toList(),
  );

  Map<String, dynamic> _sessionToMap(ExerciseSession s) => {
    'id': s.id,
    'userId': s.userId,
    'exerciseId': s.exerciseId,
    'date': s.date.toIso8601String(),
    'setsCompleted': s.setsCompleted,
    'repsCompleted': s.repsCompleted,
    'durationSeconds': s.durationSeconds,
  };

  ExerciseSession _sessionFromMap(Map<String, dynamic> m) => ExerciseSession(
    id: m['id'] as String,
    userId: m['userId'] as String,
    exerciseId: m['exerciseId'] as String,
    date: DateTime.parse(m['date'] as String),
    setsCompleted: m['setsCompleted'] as int,
    repsCompleted: m['repsCompleted'] as int,
    durationSeconds: m['durationSeconds'] as int,
  );
}
