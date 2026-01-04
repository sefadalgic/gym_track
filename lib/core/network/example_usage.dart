import 'package:gym_track/core/base/base_model.dart';
import 'package:gym_track/core/network/network_manager.dart';

/// Example User model
class User extends BaseModel {
  final int id;
  final String name;
  final String email;

  User({
    required this.id,
    required this.name,
    required this.email,
  });

  /// Factory constructor for creating User from JSON
  static User fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }
}

/// Example usage of the network layer
void main() async {
  // Initialize NetworkManager with your API base URL (optional, can use default)
  NetworkManager.initialize(
    baseUrl: 'https://jsonplaceholder.typicode.com',
  );

  // Get the network service instance
  final networkService = NetworkManager.instance.networkService;

  // Example 1: GET request with parser
  print('Example 1: GET request with parser');
  final getUserResponse = await networkService.get<User>(
    path: '/users/1',
    parser: User.fromJson,
  );

  if (getUserResponse.isSuccess) {
    print('User name: ${getUserResponse.data?.name}');
    print('User email: ${getUserResponse.data?.email}');
  } else {
    print('Error: ${getUserResponse.error?.message}');
  }

  // Example 2: GET request for list
  print('\nExample 2: GET request for list');
  final getUsersResponse = await networkService.get<List<User>>(
    path: '/users',
    parser: (json) {
      // Handle list response
      final list = json as List;
      return list
          .map((item) => User.fromJson(item as Map<String, dynamic>))
          .toList();
    },
  );

  if (getUsersResponse.isSuccess) {
    print('Total users: ${getUsersResponse.data?.length}');
  }

  // Example 3: POST request
  print('\nExample 3: POST request');
  final newUser = User(
    id: 0,
    name: 'John Doe',
    email: 'john@example.com',
  );

  final createUserResponse = await networkService.post<User>(
    path: '/users',
    data: newUser.toJson(),
    parser: User.fromJson,
  );

  if (createUserResponse.isSuccess) {
    print('Created user: ${createUserResponse.data?.name}');
  } else {
    print('Error: ${createUserResponse.error?.message}');
    print('Status code: ${createUserResponse.error?.statusCode}');
  }

  // Example 4: PUT request
  print('\nExample 4: PUT request');
  final updatedUser = User(
    id: 1,
    name: 'Jane Doe',
    email: 'jane@example.com',
  );

  final updateUserResponse = await networkService.put<User>(
    path: '/users/1',
    data: updatedUser.toJson(),
    parser: User.fromJson,
  );

  if (updateUserResponse.isSuccess) {
    print('Updated user: ${updateUserResponse.data?.name}');
  }

  // Example 5: DELETE request
  print('\nExample 5: DELETE request');
  final deleteUserResponse = await networkService.delete<void>(
    path: '/users/1',
  );

  if (deleteUserResponse.isSuccess) {
    print('User deleted successfully');
  }

  // Example 6: Request without parser (raw data)
  print('\nExample 6: Request without parser');
  final rawResponse = await networkService.get<Map<String, dynamic>>(
    path: '/users/1',
  );

  if (rawResponse.isSuccess) {
    print('Raw data: ${rawResponse.data}');
  }

  // Example 7: Error handling
  print('\nExample 7: Error handling');
  final errorResponse = await networkService.get<User>(
    path: '/invalid-endpoint',
    parser: User.fromJson,
  );

  if (errorResponse.hasError) {
    print('Error message: ${errorResponse.error?.message}');
    print('Status code: ${errorResponse.error?.statusCode}');
    print('Error code: ${errorResponse.error?.errorCode}');
    print('Details: ${errorResponse.error?.details}');
  }
}
