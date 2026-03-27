import 'package:flutter/material.dart';

class AlarmsScreen extends StatelessWidget {
  const AlarmsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Будильники'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (context, index) {
          return _AlarmCard(index: index);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('Новый будильник'),
      ),
    );
  }
}

class _AlarmCard extends StatelessWidget {
  final int index;

  const _AlarmCard({required this.index});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: index % 2 == 0 ? Colors.blue : Colors.grey,
          child: const Icon(Icons.alarm, color: Colors.white),
        ),
        title: Text('Будильник #${index + 1}'),
        subtitle: Text('${8 + index}:00'),
        trailing: Switch(
          value: index % 2 == 0,
          onChanged: (value) {},
        ),
      ),
    );
  }
}
