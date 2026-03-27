import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';

class AdminScreen extends ConsumerWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final isAdmin = user?.isAdmin ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Админка'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/admin/settings'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Карточка пользователя
          _buildUserCard(context, user),
          const SizedBox(height: 24),

          // Раздел администратора
          if (isAdmin) ...[
            _buildSectionTitle('Управление'),
            const SizedBox(height: 12),
            _buildAdminCard(
              icon: Icons.people,
              title: 'Команда',
              subtitle: 'Управление участниками и ролями',
              onTap: () => context.push('/admin/team'),
            ),
            const SizedBox(height: 12),
            _buildAdminCard(
              icon: Icons.folder,
              title: 'Проекты',
              subtitle: 'Создание и настройка проектов',
              onTap: () => context.push('/admin/projects'),
            ),
            const SizedBox(height: 12),
            _buildAdminCard(
              icon: Icons.shield,
              title: 'Роли и доступы',
              subtitle: 'Настройка прав пользователей',
              onTap: () => context.push('/admin/roles'),
            ),
            const SizedBox(height: 24),
          ],

          // Общий раздел
          _buildSectionTitle('Настройки'),
          const SizedBox(height: 12),
          _buildSettingCard(
            icon: Icons.person,
            title: 'Профиль',
            subtitle: 'Редактировать данные',
            onTap: () => context.push('/admin/profile'),
          ),
          const SizedBox(height: 12),
          _buildSettingCard(
            icon: Icons.notifications,
            title: 'Уведомления',
            subtitle: 'Настройка уведомлений',
            onTap: () => context.push('/admin/notifications'),
          ),
          const SizedBox(height: 12),
          _buildSettingCard(
            icon: Icons.palette,
            title: 'Внешний вид',
            subtitle: 'Тема и оформление',
            onTap: () => context.push('/admin/appearance'),
          ),
          const SizedBox(height: 12),
          _buildSettingCard(
            icon: Icons.storage,
            title: 'Данные',
            subtitle: 'Экспорт, импорт, очистка',
            onTap: () => context.push('/admin/data'),
          ),
          const SizedBox(height: 24),

          // AI раздел
          _buildSectionTitle('AI Настройки'),
          const SizedBox(height: 12),
          _buildSettingCard(
            icon: Icons.auto_awesome,
            title: 'DeepSeek API',
            subtitle: 'Настройка AI сервиса',
            onTap: () => context.push('/admin/ai'),
          ),
          const SizedBox(height: 12),
          _buildSettingCard(
            icon: Icons.analytics,
            title: 'AI Лимиты',
            subtitle: 'Статистика использования',
            onTap: () => context.push('/admin/ai-stats'),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, UserModel? user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage:
                  user?.photoUrl != null ? NetworkImage(user!.photoUrl!) : null,
              child: user?.photoUrl == null
                  ? const Icon(Icons.person, size: 40)
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              user?.displayName ?? 'Пользователь',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              user?.email ?? '',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            if (user?.isAdmin ?? false)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.purple),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.shield, size: 16, color: Colors.purple),
                    const SizedBox(width: 4),
                    const Text(
                      'Администратор',
                      style: TextStyle(
                          color: Colors.purple, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildAdminCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.purple.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.purple),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
