import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exceptions.dart';
import '../models/task_model.dart';
import '../models/task_stats_model.dart';

class TaskService {
  final ApiClient _client = ApiClient();

  Future<List<TaskModel>> getTasks({
    String? status,
    String? category,
    String? priority,
    String? search,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      // Request the maximum page size the API allows (server hard-caps at 100)
      // so all of a student's tasks appear in a single view.
      final queryParams = <String, dynamic>{'limit': 100};
      if (status != null && status != 'all') queryParams['status'] = status;
      if (category != null) queryParams['category'] = category;
      if (priority != null) queryParams['priority'] = priority;
      if (search != null && search.trim().isNotEmpty) queryParams['search'] = search.trim();
      if (sortBy != null) queryParams['sortBy'] = sortBy;
      if (sortOrder != null) queryParams['sortOrder'] = sortOrder;

      final response = await _client.dio.get(
        ApiConstants.tasksEndpoint,
        queryParameters: queryParams,
      );

      final list = (response.data['data'] as List<dynamic>? ?? [])
          .map((item) => TaskModel.fromJson(item as Map<String, dynamic>))
          .toList();

      return list;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Failed to load tasks: $e');
    }
  }

  Future<TaskStatsModel> getStats() async {
    try {
      final response = await _client.dio.get(ApiConstants.taskStatsEndpoint);
      final data = response.data['data'] as Map<String, dynamic>;
      return TaskStatsModel.fromJson(data);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Failed to load statistics: $e');
    }
  }

  Future<TaskModel> getTaskById(String id) async {
    try {
      final response = await _client.dio.get('${ApiConstants.tasksEndpoint}/$id');
      final data = response.data['data'] as Map<String, dynamic>;
      return TaskModel.fromJson(data);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Failed to get task: $e');
    }
  }

  Future<TaskModel> createTask({
    required String title,
    String? description,
    required TaskCategory category,
    required TaskPriority priority,
    required DateTime dueDate,
  }) async {
    try {
      final response = await _client.dio.post(
        ApiConstants.tasksEndpoint,
        data: {
          'title': title.trim(),
          if (description != null && description.trim().isNotEmpty)
            'description': description.trim(),
          'category': category.toApiString(),
          'priority': priority.toApiString(),
          'dueDate': dueDate.toIso8601String(),
        },
      );

      final data = response.data['data'] as Map<String, dynamic>;
      return TaskModel.fromJson(data);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Failed to create task: $e');
    }
  }

  Future<TaskModel> updateTask({
    required String id,
    String? title,
    String? description,
    TaskCategory? category,
    TaskPriority? priority,
    DateTime? dueDate,
    bool? completed,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (title != null) updateData['title'] = title.trim();
      if (description != null) updateData['description'] = description.trim();
      if (category != null) updateData['category'] = category.toApiString();
      if (priority != null) updateData['priority'] = priority.toApiString();
      if (dueDate != null) updateData['dueDate'] = dueDate.toIso8601String();
      if (completed != null) updateData['completed'] = completed;

      final response = await _client.dio.put(
        '${ApiConstants.tasksEndpoint}/$id',
        data: updateData,
      );

      final data = response.data['data'] as Map<String, dynamic>;
      return TaskModel.fromJson(data);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Failed to update task: $e');
    }
  }

  Future<TaskModel> toggleComplete(String id) async {
    try {
      final response = await _client.dio.patch(
        '${ApiConstants.tasksEndpoint}/$id/complete',
      );

      final data = response.data['data'] as Map<String, dynamic>;
      return TaskModel.fromJson(data);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Failed to toggle task status: $e');
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      await _client.dio.delete('${ApiConstants.tasksEndpoint}/$id');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Failed to delete task: $e');
    }
  }
}
