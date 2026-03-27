import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/mind_map_model.dart';
import '../models/task_model.dart';
import '../core/firestore_service.dart';
import '../core/local_storage_service.dart';
import '../core/deepseek_service.dart';

// Provider для mind-карты проекта
final mindMapProvider = StateNotifierProvider.family<MindMapNotifier, AsyncValue<MindMapData>, String>((ref, projectId) {
  return MindMapNotifier(projectId);
});

// Данные mind-карты
class MindMapData {
  final List<MindMapNode> nodes;
  final Map<String, List<String>> childrenMap; // parentId -> [childIds]
  final String? rootNodeId;

  MindMapData({
    required this.nodes,
    required this.childrenMap,
    this.rootNodeId,
  });

  // Получить дочерние узлы
  List<MindMapNode> getChildren(String parentId) {
    final childIds = childrenMap[parentId] ?? [];
    return nodes.where((n) => childIds.contains(n.id)).toList();
  }

  // Получить родительский узел
  MindMapNode? getParent(String nodeId) {
    final node = nodes.firstWhere((n) => n.id == nodeId, orElse: () => throw Exception('Node not found'));
    if (node.parentId == null) return null;
    return nodes.firstWhere((n) => n.id == node.parentId, orElse: () => throw Exception('Parent not found'));
  }
}

class MindMapNotifier extends StateNotifier<AsyncValue<MindMapData>> {
  final String projectId;

  MindMapNotifier(this.projectId) : super(const AsyncValue.loading()) {
    _loadMindMap();
  }

  // Загрузка mind-карты
  Future<void> _loadMindMap() async {
    try {
      // Загружаем из локального хранилища
      final localNodes = localStorageService.getMindMapNodes();
      final projectNodes = localNodes.where((n) => n.projectId == projectId).toList();
      
      state = AsyncValue.data(_createMindMapData(projectNodes));

      // TODO: Загрузить из Firestore и синхронизировать
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // Создание структуры данных
  MindMapData _createMindMapData(List<MindMapNode> nodes) {
    final childrenMap = <String, List<String>>{};
    String? rootNodeId;

    for (final node in nodes) {
      if (node.parentId == null) {
        rootNodeId = node.id;
      } else {
        childrenMap.putIfAbsent(node.parentId!, () => []).add(node.id);
      }
    }

    return MindMapData(
      nodes: nodes,
      childrenMap: childrenMap,
      rootNodeId: rootNodeId,
    );
  }

  // Добавление узла
  Future<MindMapNode> addNode({
    required String title,
    String? parentId,
    String? taskId,
    double x = 0,
    double y = 0,
    String color = '#2196F3',
    String icon = 'folder',
  }) async {
    try {
      final parentNode = parentId != null 
          ? state.value?.nodes.firstWhere((n) => n.id == parentId)
          : null;

      final node = MindMapNode(
        id: const Uuid().v4(),
        projectId: projectId,
        parentId: parentId,
        level: parentId != null ? (parentNode?.level ?? 0) + 1 : 0,
        title: title,
        taskId: taskId,
        x: x,
        y: y,
        color: color,
        icon: icon,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Сохраняем локально
      await localStorageService.saveMindMapNodes([node]);

      // Сохраняем в Firestore
      try {
        await firestoreService.createMindMapNode(node);
      } catch (e) {
        print('Firestore save failed: $e');
      }

      // Обновляем состояние
      final currentData = state.value;
      if (currentData != null) {
        final updatedNodes = [...currentData.nodes, node];
        
        if (parentId != null) {
          currentData.childrenMap.putIfAbsent(parentId, () => []).add(node.id);
        }
        
        state = AsyncValue.data(MindMapData(
          nodes: updatedNodes,
          childrenMap: currentData.childrenMap,
          rootNodeId: parentId == null ? node.id : currentData.rootNodeId,
        ));
      }

      return node;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  // Обновление узла
  Future<void> updateNode(String nodeId, {
    String? title,
    String? color,
    String? icon,
    double? x,
    double? y,
  }) async {
    try {
      final currentData = state.value;
      if (currentData == null) throw Exception('No data');

      final nodeIndex = currentData.nodes.indexWhere((n) => n.id == nodeId);
      if (nodeIndex == -1) throw Exception('Node not found');

      final oldNode = currentData.nodes[nodeIndex];
      final updatedNode = oldNode.copyWith(
        title: title ?? oldNode.title,
        color: color ?? oldNode.color,
        icon: icon ?? oldNode.icon,
        x: x ?? oldNode.x,
        y: y ?? oldNode.y,
        updatedAt: DateTime.now(),
      );

      // Сохраняем локально
      await localStorageService.saveMindMapNodes([updatedNode]);

      // Сохраняем в Firestore
      try {
        await firestoreService.updateMindMapNode(updatedNode);
      } catch (e) {
        print('Firestore update failed: $e');
      }

      // Обновляем состояние
      final updatedNodes = List<MindMapNode>.from(currentData.nodes);
      updatedNodes[nodeIndex] = updatedNode;

      state = AsyncValue.data(MindMapData(
        nodes: updatedNodes,
        childrenMap: currentData.childrenMap,
        rootNodeId: currentData.rootNodeId,
      ));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  // Удаление узла (и всех дочерних)
  Future<void> deleteNode(String nodeId) async {
    try {
      final currentData = state.value;
      if (currentData == null) return;

      // Находим все дочерние узлы (рекурсивно)
      final nodesToDelete = <String>{nodeId};
      _collectChildNodes(nodeId, currentData, nodesToDelete);

      // Сохраняем для удаления
      final nodes = currentData.nodes.where((n) => !nodesToDelete.contains(n.id)).toList();

      // Сохраняем локально (удаляем)
      for (final id in nodesToDelete) {
        // TODO: localStorageService.deleteMindMapNode(id);
      }

      // Обновляем состояние
      final newChildrenMap = <String, List<String>>{};
      String? newRootNodeId;

      for (final node in nodes) {
        if (node.parentId == null) {
          newRootNodeId = node.id;
        } else if (!nodesToDelete.contains(node.parentId)) {
          newChildrenMap.putIfAbsent(node.parentId!, () => []).add(node.id);
        }
      }

      state = AsyncValue.data(MindMapData(
        nodes: nodes,
        childrenMap: newChildrenMap,
        rootNodeId: newRootNodeId,
      ));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  // Рекурсивный сбор дочерних узлов
  void _collectChildNodes(String parentId, MindMapData data, Set<String> result) {
    final childIds = data.childrenMap[parentId] ?? [];
    for (final childId in childIds) {
      result.add(childId);
      _collectChildNodes(childId, data, result);
    }
  }

  // AI: Генерация mind-карты проекта
  Future<List<MindMapNode>> generateMindMapWithAI({
    required String projectName,
    required String description,
  }) async {
    try {
      final nodesData = await deepSeekService.generateMindMap(
        projectName: projectName,
        description: description,
      );

      final nodes = <MindMapNode>[];
      MindMapNode? rootNode;

      for (var i = 0; i < nodesData.length; i++) {
        final nodeData = nodesData[i];
        final level = nodeData['level'] as int;
        final parentId = nodeData['parentId'] as int?;
        
        String? actualParentId;
        if (parentId != null && parentId < nodes.length) {
          actualParentId = nodes[parentId].id;
        }

        final node = await addNode(
          title: nodeData['title'] as String,
          parentId: actualParentId,
          x: (level * 200).toDouble(), // Автоматическое позиционирование
          y: (i * 50).toDouble(),
        );
        
        nodes.add(node);
        
        if (level == 0) {
          rootNode = node;
        }
      }

      return nodes;
    } catch (e, st) {
      rethrow;
    }
  }

  // Связь узла с задачей
  Future<void> linkTask(String nodeId, String taskId) async {
    await updateNode(nodeId);
    // TODO: Обновить taskId в узле
  }

  // Экспорт в JSON
  Map<String, dynamic> exportToJson() {
    final data = state.value;
    if (data == null) return {};

    return {
      'projectId': projectId,
      'rootNodeId': data.rootNodeId,
      'nodes': data.nodes.map((n) => {
        'id': n.id,
        'parentId': n.parentId,
        'level': n.level,
        'title': n.title,
        'x': n.x,
        'y': n.y,
        'color': n.color,
        'icon': n.icon,
      }).toList(),
    };
  }

  // Импорт из JSON
  Future<void> importFromJson(Map<String, dynamic> json) async {
    // TODO: Реализовать импорт
  }
}
