import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';

class TeamManagementScreen extends ConsumerStatefulWidget {
  const TeamManagementScreen({super.key});

  @override
  ConsumerState<TeamManagementScreen> createState() =>
      _TeamManagementScreenState();
}

class _TeamManagementScreenState extends ConsumerState<TeamManagementScreen> {
  final _teamNameController = TextEditingController();
  bool _isCreating = false;

  @override
  void dispose() {
    _teamNameController.dispose();
    super.dispose();
  }

  Future<void> _createTeam() async {
    if (_teamNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите название команды')),
      );
      return;
    }

    setState(() {
      _isCreating = true;
    });

    try {
      final user = ref.read(currentUserProvider);
      if (user == null) throw Exception('Пользователь не авторизован');

      final teamRef = FirebaseFirestore.instance.collection('teams').doc();
      await teamRef.set({
        'name': _teamNameController.text,
        'ownerId': user.id,
        'memberIds': [user.id],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'description': '',
        'settings': {},
      });

      // Добавляем teamId пользователю
      await FirebaseFirestore.instance.collection('users').doc(user.id).update({
        'teamIds': FieldValue.arrayUnion([teamRef.id]),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Команда создана'),
            backgroundColor: Colors.green,
          ),
        );
        _teamNameController.clear();
        setState(() {
          _isCreating = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Ошибка: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isCreating = false;
        });
      }
    }
  }

  Future<void> _changeUserRole(
      String userId, String teamId, UserRole newRole) async {
    try {
      await FirebaseFirestore.instance
          .collection('teams')
          .doc(teamId)
          .collection('members')
          .doc(userId)
          .update({'role': newRole.name});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Роль изменена')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Ошибка: $e')),
      );
    }
  }

  Future<void> _removeMember(String userId, String teamId) async {
    try {
      await FirebaseFirestore.instance.collection('teams').doc(teamId).update({
        'memberIds': FieldValue.arrayRemove([userId]),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Участник удалён')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Ошибка: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final isAdmin = user?.isAdmin ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Команда'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Создание команды
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Создать новую команду',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _teamNameController,
                    decoration: const InputDecoration(
                      labelText: 'Название команды',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.people),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isCreating ? null : _createTeam,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isCreating
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Создать команду'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Список команд
          const Text(
            'Ваши команды',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('teams')
                .where('memberIds', arrayContains: user?.id)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text('Ошибка: ${snapshot.error}');
              }

              if (!snapshot.hasData) {
                return const CircularProgressIndicator();
              }

              final teams = snapshot.data!.docs;

              if (teams.isEmpty) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Column(
                        children: [
                          const Icon(Icons.people_outline,
                              size: 48, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text(
                            'Нет команд',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: teams.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final team = teams[index].data() as Map<String, dynamic>;
                  final teamId = teams[index].id;
                  final isOwner = team['ownerId'] == user?.id;

                  return _TeamCard(
                    teamId: teamId,
                    name: team['name'] ?? 'Без названия',
                    memberCount: (team['memberIds'] as List?)?.length ?? 0,
                    isOwner: isOwner,
                    onRemove:
                        isOwner ? null : () => _removeMember(user!.id, teamId),
                  );
                },
              );
            },
          ),

          if (isAdmin) ...[
            const SizedBox(height: 24),
            const Text(
              'Все пользователи',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildUsersList(),
          ],
        ],
      ),
    );
  }

  Widget _buildUsersList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Ошибка: ${snapshot.error}');
        }

        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        final users = snapshot.data!.docs;

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: users.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final userData = users[index].data() as Map<String, dynamic>;
            final userId = users[index].id;
            final user = UserModel.fromFirestore(users[index]);

            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: user.photoUrl != null
                      ? NetworkImage(user.photoUrl!)
                      : null,
                  child:
                      user.photoUrl == null ? const Icon(Icons.person) : null,
                ),
                title: Text(user.displayName ?? 'Без имени'),
                subtitle: Text(user.email),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: user.isAdmin
                            ? Colors.purple.withOpacity(0.2)
                            : Colors.blue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        user.isAdmin ? 'Админ' : 'Участник',
                        style: TextStyle(
                          color: user.isAdmin ? Colors.purple : Colors.blue,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _TeamCard extends StatelessWidget {
  final String teamId;
  final String name;
  final int memberCount;
  final bool isOwner;
  final VoidCallback? onRemove;

  const _TeamCard({
    required this.teamId,
    required this.name,
    required this.memberCount,
    required this.isOwner,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.people, color: Colors.blue),
        ),
        title: Text(name),
        subtitle: Text('Участников: $memberCount'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isOwner)
              const Chip(
                label: Text('Владелец', style: TextStyle(fontSize: 12)),
                backgroundColor: Colors.purple,
                labelStyle: TextStyle(color: Colors.white, fontSize: 12),
              ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () => context.push('/admin/team/$teamId'),
            ),
          ],
        ),
      ),
    );
  }
}
