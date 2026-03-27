import 'package:flutter/material.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Календарь'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () {
              // Синхронизация с Google Calendar
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCalendarHeader(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 5,
              itemBuilder: (context, index) {
                return _CalendarEventCard(index: index);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCalendarHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {},
          ),
          const Text(
            'Март 2026',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class _CalendarEventCard extends StatelessWidget {
  final int index;

  const _CalendarEventCard({required this.index});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 4,
          height: 40,
          decoration: BoxDecoration(
            color: _getEventColor(index),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        title: Text('Событие #${index + 1}'),
        subtitle: Text('10:00 - 11:00'),
        trailing: const Icon(Icons.more_vert),
      ),
    );
  }

  Color _getEventColor(int index) {
    final colors = [Colors.blue, Colors.green, Colors.orange, Colors.purple];
    return colors[index % colors.length];
  }
}
