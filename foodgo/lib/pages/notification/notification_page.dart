import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data?.docs ?? const [];
          if (docs.isEmpty) {
            return _EmptyState();
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final n = docs[index].data();
              return _NotificationTile(
                id: docs[index].id,
                avatar: n['avatar'] ?? '',
                title: n['title'] ?? '',
                subtitle: n['subtitle'] ?? '',
                isNew: n['isNew'] == true,
              );
            },
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.notifications_none_rounded, size: 96),
            const SizedBox(height: 16),
            Text('Nothing here!!!', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Tap the notification settings button below and check again.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 240,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Notification Settings'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final String id;
  final String avatar;
  final String title;
  final String subtitle;
  final bool isNew;
  const _NotificationTile({
    required this.id,
    required this.avatar,
    required this.title,
    required this.subtitle,
    required this.isNew,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(id),
      background: _ActionBackground(
        alignment: Alignment.centerLeft,
        color: Theme.of(context).colorScheme.errorContainer,
        icon: Icons.close_rounded,
        label: 'Reject',
      ),
      secondaryBackground: _ActionBackground(
        alignment: Alignment.centerRight,
        color: Theme.of(context).colorScheme.primaryContainer,
        icon: Icons.check_rounded,
        label: 'Accept',
      ),
      confirmDismiss: (direction) async {
        // Stub: handle accept/reject actions
        return false; // keep item for demo
      },
      child: ListTile(
        leading: CircleAvatar(backgroundImage: avatar.isNotEmpty ? AssetImage(avatar) as ImageProvider : null),
        title: Row(
          children: [
            Expanded(child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis)),
            if (isNew)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('NEW', style: Theme.of(context).textTheme.labelSmall),
              ),
          ],
        ),
        subtitle: Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
        onTap: () {},
      ),
    );
  }
}

class _ActionBackground extends StatelessWidget {
  final Alignment alignment;
  final Color color;
  final IconData icon;
  final String label;

  const _ActionBackground({
    required this.alignment,
    required this.color,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment,
      color: color,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.onPrimaryContainer),
          const SizedBox(width: 8),
          Text(label, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Theme.of(context).colorScheme.onPrimaryContainer)),
        ],
      ),
    );
  }
}


