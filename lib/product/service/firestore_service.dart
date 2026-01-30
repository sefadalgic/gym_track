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

  /// Get reference to user's workouts collection
  Future<CollectionReference?> _getUserWorkoutsCollection() async {
    final user = await AuthService.instance.getCurrentUser();
    if (user == null) return null;
    return _firestore.collection('users').doc(user.uid).collection('workouts');
  }

  /// Create a new workout
  Future<String> createWorkout(WorkoutModel workout) async {
    try {
      final collection = await _getUserWorkoutsCollection();
      if (collection == null) {
        throw Exception('User not authenticated');
      }

      // If this workout is active, deactivate all other workouts
      if (workout.isActive == true) {
        await _deactivateAllWorkouts();
      }

      final docRef = await collection.add(workout.toFirestore());
      print('Workout created successfully with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create workout: $e');
    }
  }

  /// Get all workouts for current user
  Future<List<WorkoutModel>> getWorkouts() async {
    try {
      final collection = await _getUserWorkoutsCollection();
      if (collection == null) return [];

      final QuerySnapshot snapshot = await collection.get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return WorkoutModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch workouts: $e');
    }
  }

  /// Get the currently active workout
  Future<WorkoutModel?> getActiveWorkout() async {
    try {
      final collection = await _getUserWorkoutsCollection();
      if (collection == null) return null;

      final QuerySnapshot snapshot =
          await collection.where('isActive', isEqualTo: true).limit(1).get();

      if (snapshot.docs.isEmpty) return null;

      final doc = snapshot.docs.first;
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return WorkoutModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to fetch active workout: $e');
    }
  }

  /// Update an existing workout
  Future<void> updateWorkout(String id, WorkoutModel workout) async {
    try {
      final collection = await _getUserWorkoutsCollection();
      if (collection == null) {
        throw Exception('User not authenticated');
      }

      // If this workout is being set to active, deactivate all others
      if (workout.isActive == true) {
        await _deactivateAllWorkouts();
      }

      await collection.doc(id).update(workout.toFirestore());
      print('Workout updated successfully');
    } catch (e) {
      throw Exception('Failed to update workout: $e');
    }
  }

  /// Set a workout as active (deactivates all others)
  Future<void> setWorkoutActive(String id) async {
    try {
      final collection = await _getUserWorkoutsCollection();
      if (collection == null) {
        throw Exception('User not authenticated');
      }

      // Deactivate all workouts first
      await _deactivateAllWorkouts();

      // Activate the specified workout
      await collection.doc(id).update({'isActive': true});
      print('Workout set as active');
    } catch (e) {
      throw Exception('Failed to set workout active: $e');
    }
  }

  /// Delete a workout
  Future<void> deleteWorkout(String id) async {
    try {
      final collection = await _getUserWorkoutsCollection();
      if (collection == null) {
        throw Exception('User not authenticated');
      }

      await collection.doc(id).delete();
      print('Workout deleted successfully');
    } catch (e) {
      throw Exception('Failed to delete workout: $e');
    }
  }

  /// Deactivate all workouts for current user
  Future<void> _deactivateAllWorkouts() async {
    try {
      final collection = await _getUserWorkoutsCollection();
      if (collection == null) return;

      final QuerySnapshot snapshot =
          await collection.where('isActive', isEqualTo: true).get();

      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {'isActive': false});
      }
      await batch.commit();
    } catch (e) {
      print('Failed to deactivate workouts: $e');
    }
  }

  /// Get workouts stream for real-time updates
  Stream<List<WorkoutModel>> getWorkoutsStream() async* {
    final collection = await _getUserWorkoutsCollection();
    if (collection == null) {
      yield [];
      return;
    }

    yield* collection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return WorkoutModel.fromJson(data);
      }).toList();
    });
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
