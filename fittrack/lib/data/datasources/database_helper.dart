import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';
import '../models/exercise.dart';
import '../models/exercise_session.dart';
import '../../core/constants/enums.dart';

/// SQLite Database Helper
/// Singleton pattern ensures single database connection throughout app
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  // Database version - increment when schema changes
  static const int _databaseVersion = 1;
  static const String _databaseName = 'fittrack.db';

  // Table names
  static const String tableUsers = 'users';
  static const String tableExercises = 'exercises';
  static const String tableSessions = 'exercise_sessions';

  // Private constructor
  DatabaseHelper._internal();

  // Factory constructor returns singleton instance
  factory DatabaseHelper() => _instance;

  /// Get database instance (lazy initialization)
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize database
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    print('📂 Database path: $path');

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Create tables when database is first created
  Future<void> _onCreate(Database db, int version) async {
    print('🔨 Creating database tables...');

    // Users table
    await db.execute('''
      CREATE TABLE $tableUsers (
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
        createdAt TEXT NOT NULL
      )
    ''');
    print('✅ Users table created');

    // Exercises table
    await db.execute('''
      CREATE TABLE $tableExercises (
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
    print('✅ Exercises table created');

    // Exercise sessions table
    await db.execute('''
      CREATE TABLE $tableSessions (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        exerciseId TEXT NOT NULL,
        date TEXT NOT NULL,
        setsCompleted INTEGER NOT NULL,
        repsCompleted INTEGER NOT NULL,
        durationSeconds INTEGER NOT NULL,
        FOREIGN KEY (userId) REFERENCES $tableUsers (id),
        FOREIGN KEY (exerciseId) REFERENCES $tableExercises (id)
      )
    ''');
    print('✅ Sessions table created');

    // Seed exercises
    await _seedExercises(db);
  }

  /// Handle database upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('🔄 Upgrading database from v$oldVersion to v$newVersion');
    // Handle migrations here when schema changes
  }

  /// Seed default exercises into database
  Future<void> _seedExercises(Database db) async {
    print('🌱 Seeding exercises...');

    final exercises = _getSeedExercises();
    for (final exercise in exercises) {
      await db.insert(tableExercises, _exerciseToMap(exercise));
    }
    print('✅ Seeded ${exercises.length} exercises');
  }

  // ===========================================================================
  // USER OPERATIONS
  // ===========================================================================

  /// Insert a new user
  Future<void> insertUser(User user) async {
    final db = await database;
    await db.insert(
      tableUsers,
      _userToMap(user),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print('✅ User inserted: ${user.name}');
  }

  /// Update existing user
  Future<void> updateUser(User user) async {
    final db = await database;
    await db.update(
      tableUsers,
      _userToMap(user),
      where: 'id = ?',
      whereArgs: [user.id],
    );
    print('✅ User updated: ${user.name}');
  }

  /// Get all users
  Future<List<User>> getAllUsers() async {
    final db = await database;
    final maps = await db.query(tableUsers);
    return maps.map((map) => _userFromMap(map)).toList();
  }

  /// Get user by ID
  Future<User?> getUserById(String id) async {
    final db = await database;
    final maps = await db.query(tableUsers, where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return _userFromMap(maps.first);
  }

  /// Get user by username (name)
  Future<User?> getUserByUsername(String username) async {
    final db = await database;
    final maps = await db.query(
      tableUsers,
      where: 'LOWER(name) = LOWER(?)',
      whereArgs: [username],
    );
    if (maps.isEmpty) return null;
    return _userFromMap(maps.first);
  }

  /// Get user by email
  Future<User?> getUserByEmail(String email) async {
    final db = await database;
    final maps = await db.query(
      tableUsers,
      where: 'LOWER(email) = LOWER(?)',
      whereArgs: [email],
    );
    if (maps.isEmpty) return null;
    return _userFromMap(maps.first);
  }

  /// Delete user by ID
  Future<void> deleteUser(String id) async {
    final db = await database;
    await db.delete(tableUsers, where: 'id = ?', whereArgs: [id]);
    print('✅ User deleted: $id');
  }

  /// Delete all users
  Future<void> deleteAllUsers() async {
    final db = await database;
    await db.delete(tableUsers);
    print('✅ All users deleted');
  }

  // ===========================================================================
  // EXERCISE OPERATIONS
  // ===========================================================================

  /// Get all exercises
  Future<List<Exercise>> getAllExercises() async {
    final db = await database;
    final maps = await db.query(tableExercises);
    return maps.map((map) => _exerciseFromMap(map)).toList();
  }

  /// Get exercises by plan type
  Future<List<Exercise>> getExercisesByPlan(Plan plan) async {
    final db = await database;
    final maps = await db.query(
      tableExercises,
      where: 'plan = ?',
      whereArgs: [plan.name],
    );
    return maps.map((map) => _exerciseFromMap(map)).toList();
  }

  /// Get exercises by section type
  Future<List<Exercise>> getExercisesBySection(SectionType section) async {
    final db = await database;
    final maps = await db.query(
      tableExercises,
      where: 'sectionType = ?',
      whereArgs: [section.name],
    );
    return maps.map((map) => _exerciseFromMap(map)).toList();
  }

  /// Get exercises by body target
  Future<List<Exercise>> getExercisesByBodyTarget(BodyTarget target) async {
    final db = await database;
    final maps = await db.query(
      tableExercises,
      where: 'bodyTarget = ?',
      whereArgs: [target.name],
    );
    return maps.map((map) => _exerciseFromMap(map)).toList();
  }

  /// Get exercises matching user's categories and plan
  Future<List<Exercise>> getExercisesForUser(User user) async {
    final allExercises = await getAllExercises();
    return allExercises.where((exercise) {
      // Must match user's plan
      if (exercise.plan != user.selectedPlan) return false;
      // Must match at least one of user's categories
      return exercise.categories.any(
        (cat) => user.selectedCategories.contains(cat),
      );
    }).toList();
  }

  /// Insert a new exercise
  Future<void> insertExercise(Exercise exercise) async {
    final db = await database;
    await db.insert(
      tableExercises,
      _exerciseToMap(exercise),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ===========================================================================
  // SESSION OPERATIONS
  // ===========================================================================

  /// Insert exercise session
  Future<void> insertSession(ExerciseSession session) async {
    final db = await database;
    await db.insert(
      tableSessions,
      _sessionToMap(session),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print('✅ Session saved');
  }

  /// Get all sessions for a user
  Future<List<ExerciseSession>> getSessionsForUser(String userId) async {
    final db = await database;
    final maps = await db.query(
      tableSessions,
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );
    return maps.map((map) => _sessionFromMap(map)).toList();
  }

  /// Get sessions in date range
  Future<List<ExerciseSession>> getSessionsInRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await database;
    final maps = await db.query(
      tableSessions,
      where: 'userId = ? AND date >= ? AND date <= ?',
      whereArgs: [
        userId,
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ],
      orderBy: 'date DESC',
    );
    return maps.map((map) => _sessionFromMap(map)).toList();
  }

  /// Delete session
  Future<void> deleteSession(String sessionId) async {
    final db = await database;
    await db.delete(tableSessions, where: 'id = ?', whereArgs: [sessionId]);
  }

  /// Delete all sessions for a user
  Future<void> deleteUserSessions(String userId) async {
    final db = await database;
    await db.delete(tableSessions, where: 'userId = ?', whereArgs: [userId]);
  }

  // ===========================================================================
  // UTILITY METHODS
  // ===========================================================================

  /// Close database connection
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  /// Get database path (for debugging)
  Future<String> getDatabasePath() async {
    final dbPath = await getDatabasesPath();
    return join(dbPath, _databaseName);
  }

  /// Check if database exists
  Future<bool> databaseExists() async {
    final path = await getDatabasePath();
    return databaseFactory.databaseExists(path);
  }

  /// Delete and recreate database (for testing)
  Future<void> resetDatabase() async {
    final path = await getDatabasePath();
    await close();
    await deleteDatabase(path);
    _database = await _initDatabase();
    print('🔄 Database reset complete');
  }

  // ===========================================================================
  // MAPPING FUNCTIONS (Convert between models and database maps)
  // ===========================================================================

  /// Convert User to Map for database
  Map<String, dynamic> _userToMap(User user) {
    return {
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
      'selectedCategories': user.selectedCategories
          .map((c) => c.name)
          .join(','),
      'selectedDays': user.selectedDays.map((d) => d.name).join(','),
      'hasCompletedAssessment': user.hasCompletedAssessment ? 1 : 0,
      'createdAt': user.createdAt.toIso8601String(),
    };
  }

  /// Convert Map to User from database
  User _userFromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      password: map['password'] as String?,
      age: map['age'] as int,
      gender: Gender.values.firstWhere((g) => g.name == map['gender']),
      weight: (map['weight'] as num).toDouble(),
      height: (map['height'] as num).toDouble(),
      selectedPlan: Plan.values.firstWhere(
        (p) => p.name == map['selectedPlan'],
      ),
      selectedLevel: Level.values.firstWhere(
        (l) => l.name == map['selectedLevel'],
      ),
      selectedCategories: (map['selectedCategories'] as String)
          .split(',')
          .where((s) => s.isNotEmpty)
          .map((c) => Categories.values.firstWhere((cat) => cat.name == c))
          .toList(),
      selectedDays: (map['selectedDays'] as String)
          .split(',')
          .where((s) => s.isNotEmpty)
          .map((d) => DayOfWeek.values.firstWhere((day) => day.name == d))
          .toList(),
      hasCompletedAssessment: map['hasCompletedAssessment'] == 1,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  /// Convert Exercise to Map for database
  Map<String, dynamic> _exerciseToMap(Exercise exercise) {
    return {
      'id': exercise.id,
      'name': exercise.name,
      'description': exercise.description,
      'imageUrl': exercise.imageUrl,
      'videoUrl': exercise.videoUrl,
      'categories': exercise.categories.map((c) => c.name).join(','),
      'plan': exercise.plan.name,
      'bodyTarget': exercise.bodyTarget.name,
      'sectionType': exercise.sectionType.name,
      'baseSets': exercise.baseSets,
      'baseReps': exercise.baseReps,
      'baseDuration': exercise.baseDuration,
      'restPeriod': exercise.restPeriod,
      'targetMuscles': exercise.targetMuscles.join(','),
      'equipment': exercise.equipment,
      'instructions': exercise.instructions.join('|'),
    };
  }

  /// Convert Map to Exercise from database
  Exercise _exerciseFromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      imageUrl: map['imageUrl'] as String,
      videoUrl: map['videoUrl'] as String?,
      categories: (map['categories'] as String)
          .split(',')
          .where((s) => s.isNotEmpty)
          .map((c) => Categories.values.firstWhere((cat) => cat.name == c))
          .toList(),
      plan: Plan.values.firstWhere((p) => p.name == map['plan']),
      bodyTarget: BodyTarget.values.firstWhere(
        (b) => b.name == map['bodyTarget'],
      ),
      sectionType: SectionType.values.firstWhere(
        (s) => s.name == map['sectionType'],
      ),
      baseSets: map['baseSets'] as int,
      baseReps: map['baseReps'] as int,
      baseDuration: map['baseDuration'] as int,
      restPeriod: map['restPeriod'] as int,
      targetMuscles: (map['targetMuscles'] as String)
          .split(',')
          .where((s) => s.isNotEmpty)
          .toList(),
      equipment: map['equipment'] as String,
      instructions: (map['instructions'] as String)
          .split('|')
          .where((s) => s.isNotEmpty)
          .toList(),
    );
  }

  /// Convert ExerciseSession to Map for database
  Map<String, dynamic> _sessionToMap(ExerciseSession session) {
    return {
      'id': session.id,
      'userId': session.userId,
      'exerciseId': session.exerciseId,
      'date': session.date.toIso8601String(),
      'setsCompleted': session.setsCompleted,
      'repsCompleted': session.repsCompleted,
      'durationSeconds': session.durationSeconds,
    };
  }

  /// Convert Map to ExerciseSession from database
  ExerciseSession _sessionFromMap(Map<String, dynamic> map) {
    return ExerciseSession(
      id: map['id'] as String,
      userId: map['userId'] as String,
      exerciseId: map['exerciseId'] as String,
      date: DateTime.parse(map['date'] as String),
      setsCompleted: map['setsCompleted'] as int,
      repsCompleted: map['repsCompleted'] as int,
      durationSeconds: map['durationSeconds'] as int,
    );
  }

  // ===========================================================================
  // SEED DATA
  // ===========================================================================

  List<Exercise> _getSeedExercises() {
    return [
      // ========== WARM-UP EXERCISES ==========
      Exercise(
        name: "Jumping Jacks",
        description: "Full body cardio warm-up exercise",
        imageUrl: "assets/images/jumping_jacks.png",
        videoUrl: null,
        categories: [Categories.cardio, Categories.getFit],
        plan: Plan.home,
        bodyTarget: BodyTarget.fullBody,
        sectionType: SectionType.warmUp,
        baseSets: 3,
        baseReps: 20,
        baseDuration: 0,
        restPeriod: 15,
        targetMuscles: ["Full Body", "Cardiovascular"],
        equipment: "Bodyweight",
        instructions: [
          "Stand with feet together, arms at sides",
          "Jump while spreading legs and raising arms overhead",
          "Jump back to starting position",
          "Repeat in a continuous rhythm",
        ],
      ),
      Exercise(
        name: "Arm Circles",
        description: "Shoulder and arm warm-up",
        imageUrl: "assets/images/arm_circles.png",
        videoUrl: null,
        categories: [Categories.flexibility, Categories.getFit],
        plan: Plan.home,
        bodyTarget: BodyTarget.upperBody,
        sectionType: SectionType.warmUp,
        baseSets: 2,
        baseReps: 15,
        baseDuration: 0,
        restPeriod: 10,
        targetMuscles: ["Shoulders", "Arms"],
        equipment: "Bodyweight",
        instructions: [
          "Stand with arms extended to sides",
          "Make small circles with arms",
          "Gradually increase circle size",
          "Switch direction halfway through",
        ],
      ),
      Exercise(
        name: "High Knees",
        description: "Dynamic cardio warm-up",
        imageUrl: "assets/images/high_knees.png",
        videoUrl: null,
        categories: [Categories.cardio, Categories.getFit],
        plan: Plan.home,
        bodyTarget: BodyTarget.lowerBody,
        sectionType: SectionType.warmUp,
        baseSets: 3,
        baseReps: 30,
        baseDuration: 0,
        restPeriod: 15,
        targetMuscles: ["Legs", "Core", "Cardiovascular"],
        equipment: "Bodyweight",
        instructions: [
          "Stand with feet hip-width apart",
          "Run in place, bringing knees to hip level",
          "Pump arms naturally",
          "Keep core engaged",
        ],
      ),

      // ========== MAIN WORKOUT - STRENGTH (HOME) ==========
      Exercise(
        name: "Push Up",
        description: "Classic upper body strength exercise",
        imageUrl: "assets/images/pushup.png",
        videoUrl: null,
        categories: [Categories.strength, Categories.getFit],
        plan: Plan.home,
        bodyTarget: BodyTarget.upperBody,
        sectionType: SectionType.mainWorkout,
        baseSets: 3,
        baseReps: 12,
        baseDuration: 0,
        restPeriod: 30,
        targetMuscles: ["Chest", "Triceps", "Shoulders"],
        equipment: "Bodyweight",
        instructions: [
          "Start in high plank position with hands shoulder-width",
          "Keep body in straight line from head to heels",
          "Lower chest toward floor by bending elbows",
          "Push back up to starting position",
        ],
      ),
      Exercise(
        name: "Bodyweight Squat",
        description: "Lower body strength builder",
        imageUrl: "assets/images/squat.png",
        videoUrl: null,
        categories: [Categories.strength, Categories.getFit],
        plan: Plan.home,
        bodyTarget: BodyTarget.lowerBody,
        sectionType: SectionType.mainWorkout,
        baseSets: 3,
        baseReps: 15,
        baseDuration: 0,
        restPeriod: 30,
        targetMuscles: ["Quads", "Glutes", "Hamstrings"],
        equipment: "Bodyweight",
        instructions: [
          "Stand with feet shoulder-width apart",
          "Lower hips back and down as if sitting in chair",
          "Keep chest up and knees behind toes",
          "Push through heels to return to standing",
        ],
      ),
      Exercise(
        name: "Plank",
        description: "Core strengthening hold",
        imageUrl: "assets/images/plank.png",
        videoUrl: null,
        categories: [Categories.strength, Categories.getFit],
        plan: Plan.home,
        bodyTarget: BodyTarget.core,
        sectionType: SectionType.mainWorkout,
        baseSets: 3,
        baseReps: 0,
        baseDuration: 30,
        restPeriod: 20,
        targetMuscles: ["Core", "Abs", "Lower Back"],
        equipment: "Bodyweight",
        instructions: [
          "Get into push-up position",
          "Lower down to forearms",
          "Keep body in straight line",
          "Hold position without letting hips sag",
        ],
      ),
      Exercise(
        name: "Lunges",
        description: "Lower body and balance",
        imageUrl: "assets/images/lunges.png",
        videoUrl: null,
        categories: [
          Categories.strength,
          Categories.balance,
          Categories.getFit,
        ],
        plan: Plan.home,
        bodyTarget: BodyTarget.lowerBody,
        sectionType: SectionType.mainWorkout,
        baseSets: 3,
        baseReps: 10,
        baseDuration: 0,
        restPeriod: 30,
        targetMuscles: ["Quads", "Glutes", "Hamstrings"],
        equipment: "Bodyweight",
        instructions: [
          "Stand with feet hip-width apart",
          "Step forward with one leg",
          "Lower hips until both knees bent at 90 degrees",
          "Push back to starting position and alternate legs",
        ],
      ),

      // ========== MAIN WORKOUT - CARDIO ==========
      Exercise(
        name: "Burpees",
        description: "Full body cardio exercise",
        imageUrl: "assets/images/burpees.png",
        videoUrl: null,
        categories: [Categories.cardio, Categories.loseFat, Categories.getFit],
        plan: Plan.home,
        bodyTarget: BodyTarget.fullBody,
        sectionType: SectionType.mainWorkout,
        baseSets: 3,
        baseReps: 10,
        baseDuration: 0,
        restPeriod: 45,
        targetMuscles: ["Full Body", "Cardiovascular"],
        equipment: "Bodyweight",
        instructions: [
          "Start standing, then drop into squat",
          "Place hands on floor and jump feet back to plank",
          "Do a push-up",
          "Jump feet back to hands and explode upward",
        ],
      ),
      Exercise(
        name: "Mountain Climbers",
        description: "Dynamic cardio and core",
        imageUrl: "assets/images/mountain_climbers.png",
        videoUrl: null,
        categories: [Categories.cardio, Categories.strength, Categories.getFit],
        plan: Plan.home,
        bodyTarget: BodyTarget.fullBody,
        sectionType: SectionType.mainWorkout,
        baseSets: 3,
        baseReps: 20,
        baseDuration: 0,
        restPeriod: 30,
        targetMuscles: ["Core", "Shoulders", "Legs"],
        equipment: "Bodyweight",
        instructions: [
          "Start in high plank position",
          "Bring one knee toward chest",
          "Quickly switch legs",
          "Continue alternating in running motion",
        ],
      ),

      // ========== COOL-DOWN EXERCISES ==========
      Exercise(
        name: "Child's Pose",
        description: "Relaxing stretch for back and hips",
        imageUrl: "assets/images/childs_pose.png",
        videoUrl: null,
        categories: [Categories.flexibility, Categories.recovery],
        plan: Plan.home,
        bodyTarget: BodyTarget.fullBody,
        sectionType: SectionType.coolDown,
        baseSets: 1,
        baseReps: 0,
        baseDuration: 60,
        restPeriod: 0,
        targetMuscles: ["Back", "Hips", "Shoulders"],
        equipment: "Bodyweight",
        instructions: [
          "Kneel on floor with knees hip-width apart",
          "Sit back on heels",
          "Reach arms forward and lower chest to thighs",
          "Hold and breathe deeply",
        ],
      ),
      Exercise(
        name: "Standing Quad Stretch",
        description: "Leg flexibility stretch",
        imageUrl: "assets/images/quad_stretch.png",
        videoUrl: null,
        categories: [Categories.flexibility, Categories.recovery],
        plan: Plan.home,
        bodyTarget: BodyTarget.lowerBody,
        sectionType: SectionType.coolDown,
        baseSets: 2,
        baseReps: 0,
        baseDuration: 30,
        restPeriod: 10,
        targetMuscles: ["Quadriceps", "Hip Flexors"],
        equipment: "Bodyweight",
        instructions: [
          "Stand on one leg",
          "Bend other knee and grab ankle",
          "Pull heel toward glutes",
          "Hold for duration, then switch sides",
        ],
      ),
      Exercise(
        name: "Seated Forward Fold",
        description: "Hamstring and back stretch",
        imageUrl: "assets/images/forward_fold.png",
        videoUrl: null,
        categories: [Categories.flexibility, Categories.recovery],
        plan: Plan.home,
        bodyTarget: BodyTarget.lowerBody,
        sectionType: SectionType.coolDown,
        baseSets: 1,
        baseReps: 0,
        baseDuration: 45,
        restPeriod: 0,
        targetMuscles: ["Hamstrings", "Lower Back"],
        equipment: "Bodyweight",
        instructions: [
          "Sit with legs extended straight",
          "Reach arms toward toes",
          "Fold forward from hips",
          "Hold stretch without bouncing",
        ],
      ),

      // ========== GYM EXERCISES ==========
      Exercise(
        name: "Bench Press",
        description: "Classic chest builder with barbell",
        imageUrl: "assets/images/bench_press.png",
        videoUrl: null,
        categories: [Categories.strength, Categories.getFit],
        plan: Plan.gym,
        bodyTarget: BodyTarget.upperBody,
        sectionType: SectionType.mainWorkout,
        baseSets: 4,
        baseReps: 10,
        baseDuration: 0,
        restPeriod: 60,
        targetMuscles: ["Chest", "Triceps", "Shoulders"],
        equipment: "Barbell",
        instructions: [
          "Lie on bench with feet flat on floor",
          "Grip bar slightly wider than shoulders",
          "Lower bar to chest in controlled motion",
          "Press bar back up to starting position",
        ],
      ),
      Exercise(
        name: "Barbell Squat",
        description: "Heavy lower body strength",
        imageUrl: "assets/images/barbell_squat.png",
        videoUrl: null,
        categories: [Categories.strength, Categories.getFit],
        plan: Plan.gym,
        bodyTarget: BodyTarget.lowerBody,
        sectionType: SectionType.mainWorkout,
        baseSets: 4,
        baseReps: 8,
        baseDuration: 0,
        restPeriod: 90,
        targetMuscles: ["Quads", "Glutes", "Hamstrings", "Core"],
        equipment: "Barbell",
        instructions: [
          "Rest barbell on upper back",
          "Stand with feet shoulder-width apart",
          "Lower hips back and down",
          "Drive through heels to stand back up",
        ],
      ),
      Exercise(
        name: "Deadlift",
        description: "Full body compound movement",
        imageUrl: "assets/images/deadlift.png",
        videoUrl: null,
        categories: [Categories.strength, Categories.getFit],
        plan: Plan.gym,
        bodyTarget: BodyTarget.fullBody,
        sectionType: SectionType.mainWorkout,
        baseSets: 4,
        baseReps: 6,
        baseDuration: 0,
        restPeriod: 120,
        targetMuscles: ["Back", "Glutes", "Hamstrings", "Core"],
        equipment: "Barbell",
        instructions: [
          "Stand with feet hip-width, barbell over mid-foot",
          "Hinge at hips and grip bar outside knees",
          "Keep back flat, drive through heels to stand",
          "Lower bar back down with control",
        ],
      ),
      Exercise(
        name: "Lat Pulldown",
        description: "Back width builder",
        imageUrl: "assets/images/lat_pulldown.png",
        videoUrl: null,
        categories: [Categories.strength, Categories.getFit],
        plan: Plan.gym,
        bodyTarget: BodyTarget.upperBody,
        sectionType: SectionType.mainWorkout,
        baseSets: 3,
        baseReps: 12,
        baseDuration: 0,
        restPeriod: 45,
        targetMuscles: ["Lats", "Biceps", "Rear Delts"],
        equipment: "Cable Machine",
        instructions: [
          "Sit at lat pulldown machine",
          "Grip bar wider than shoulder width",
          "Pull bar down to upper chest",
          "Control the weight back up",
        ],
      ),
      Exercise(
        name: "Dumbbell Shoulder Press",
        description: "Shoulder strength and size",
        imageUrl: "assets/images/shoulder_press.png",
        videoUrl: null,
        categories: [Categories.strength, Categories.getFit],
        plan: Plan.gym,
        bodyTarget: BodyTarget.upperBody,
        sectionType: SectionType.mainWorkout,
        baseSets: 3,
        baseReps: 10,
        baseDuration: 0,
        restPeriod: 60,
        targetMuscles: ["Shoulders", "Triceps"],
        equipment: "Dumbbells",
        instructions: [
          "Sit on bench with back support",
          "Hold dumbbells at shoulder height",
          "Press weights overhead until arms straight",
          "Lower back to shoulders with control",
        ],
      ),
      Exercise(
        name: "Treadmill Running",
        description: "Cardio endurance training",
        imageUrl: "assets/images/treadmill.png",
        videoUrl: null,
        categories: [
          Categories.cardio,
          Categories.loseFat,
          Categories.endurance,
        ],
        plan: Plan.gym,
        bodyTarget: BodyTarget.fullBody,
        sectionType: SectionType.mainWorkout,
        baseSets: 1,
        baseReps: 0,
        baseDuration: 1200,
        restPeriod: 0,
        targetMuscles: ["Legs", "Cardiovascular"],
        equipment: "Treadmill",
        instructions: [
          "Start with a 5-minute warm-up walk",
          "Increase speed to jogging pace",
          "Maintain steady pace for duration",
          "Cool down with 5-minute walk",
        ],
      ),
      Exercise(
        name: "Cable Crunches",
        description: "Core strength with resistance",
        imageUrl: "assets/images/cable_crunches.png",
        videoUrl: null,
        categories: [Categories.strength, Categories.getFit],
        plan: Plan.gym,
        bodyTarget: BodyTarget.core,
        sectionType: SectionType.mainWorkout,
        baseSets: 3,
        baseReps: 15,
        baseDuration: 0,
        restPeriod: 30,
        targetMuscles: ["Abs", "Core"],
        equipment: "Cable Machine",
        instructions: [
          "Kneel in front of cable machine",
          "Hold rope attachment behind head",
          "Crunch down, bringing elbows to knees",
          "Return to starting position with control",
        ],
      ),
      Exercise(
        name: "Gym Warm-up: Rowing Machine",
        description: "Full body cardio warm-up",
        imageUrl: "assets/images/rowing.png",
        videoUrl: null,
        categories: [Categories.cardio, Categories.getFit],
        plan: Plan.gym,
        bodyTarget: BodyTarget.fullBody,
        sectionType: SectionType.warmUp,
        baseSets: 1,
        baseReps: 0,
        baseDuration: 300,
        restPeriod: 0,
        targetMuscles: ["Full Body", "Cardiovascular"],
        equipment: "Rowing Machine",
        instructions: [
          "Sit on rower with feet strapped in",
          "Push with legs first, then pull with arms",
          "Reverse the motion to return",
          "Maintain steady, moderate pace",
        ],
      ),
      Exercise(
        name: "Foam Rolling",
        description: "Muscle recovery and flexibility",
        imageUrl: "assets/images/foam_rolling.png",
        videoUrl: null,
        categories: [Categories.recovery, Categories.flexibility],
        plan: Plan.gym,
        bodyTarget: BodyTarget.fullBody,
        sectionType: SectionType.coolDown,
        baseSets: 1,
        baseReps: 0,
        baseDuration: 300,
        restPeriod: 0,
        targetMuscles: ["Full Body"],
        equipment: "Foam Roller",
        instructions: [
          "Place foam roller under target muscle",
          "Roll slowly back and forth",
          "Pause on tender spots for 30 seconds",
          "Cover all major muscle groups",
        ],
      ),
    ];
  }
}
