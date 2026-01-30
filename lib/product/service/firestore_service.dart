import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gym_track/product/model/exercise_model.dart';
import 'package:gym_track/product/model/workout_model.dart';
import 'package:gym_track/product/service/auth_service.dart';

/// Service for managing Firestore operations
class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  static FirestoreService get instance => _instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirestoreService._internal();

  /// Get reference to exercises collection
  CollectionReference get exercisesCollection =>
      _firestore.collection('exercises');

  /// Fetch all exercises from Firestore
  Future<List<ExerciseModel>> getExercises() async {
    try {
      print('Get exercises from Firestore');
      final QuerySnapshot snapshot = await exercisesCollection.get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        // Add document ID to the data
        data['id'] = doc.id;
        return ExerciseModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch exercises from Firestore: $e');
    }
  }

  Future<void> saveWorkout(WorkoutModel workout) async {
    try {
      final user = await AuthService.instance.getCurrentUser();

      if (user == null) return;

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('workouts')
          .doc()
          .set(workout.toFirestore())
          .then(
        (value) {
          print('Workout saved successfully');
        },
        onError: (e) {
          print('Failed to save workout: $e');
        },
      );
    } catch (e) {
      throw Exception('Failed to save workout: $e');
    }
  }

  Future<void> getWorkouts() async {
    try {
      final user = await AuthService.instance.getCurrentUser();

      if (user == null) return;

      final QuerySnapshot snapshot = await _firestore.collection('users').get();

      snapshot.docs.map(
        (e) {},
      );
    } catch (e) {
      throw Exception('Failed to fetch workouts from Firestore: $e');
    }
  }

  /// Get exercises stream for real-time updates
  Stream<List<ExerciseModel>> getExercisesStream() {
    return exercisesCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return ExerciseModel.fromJson(data);
      }).toList();
    });
  }

  /// Add a new exercise to Firestore
  Future<void> addExercise(ExerciseModel exercise) async {
    try {
      await exercisesCollection.add(exercise.toFirestore());
    } catch (e) {
      throw Exception('Failed to add exercise: $e');
    }
  }

  /// Update an existing exercise
  Future<void> updateExercise(String id, ExerciseModel exercise) async {
    try {
      await exercisesCollection.doc(id).update(exercise.toFirestore());
    } catch (e) {
      throw Exception('Failed to update exercise: $e');
    }
  }

  /// Delete an exercise
  Future<void> deleteExercise(String id) async {
    try {
      await exercisesCollection.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete exercise: $e');
    }
  }

  /// Get a single exercise by ID
  Future<ExerciseModel?> getExerciseById(String id) async {
    try {
      final DocumentSnapshot doc = await exercisesCollection.doc(id).get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return ExerciseModel.fromJson(data);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch exercise: $e');
    }
  }
}
