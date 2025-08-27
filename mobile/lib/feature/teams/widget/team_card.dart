import 'package:flutter/material.dart';

import '../../../product/models/user.dart' show Team, TeamType;

class TeamCard extends StatelessWidget {
  final Team team;
  final bool canManage;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onAddMember;

  const TeamCard({
    super.key,
    required this.team,
    required this.canManage,
    this.onEdit,
    this.onDelete,
    this.onAddMember,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(_iconForTeamType(team.teamType)),
        ),
        title: Text(team.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              team.teamType.displayName,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  team.isActive ? Icons.check_circle : Icons.cancel,
                  size: 16,
                  color: team.isActive ? Colors.green.shade600 : Colors.red.shade600,
                ),
                const SizedBox(width: 4),
                Expanded(
                  flex: 2,
                  child: Text(
                    team.isActive ? 'Aktif' : 'Pasif',
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.group_outlined, size: 16),
                const SizedBox(width: 2),
                Expanded(
                  flex: 3,
                  child: Text(
                    '${team.memberCount} üye',
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
        onTap: canManage ? onEdit : null,
        trailing: canManage
            ? PopupMenuButton<String>(
                onSelected: (v) {
                  if (v == 'edit') onEdit?.call();
                  if (v == 'delete') onDelete?.call();
                  if (v == 'add_member') onAddMember?.call();
                },
                itemBuilder: (ctx) => const [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined),
                        SizedBox(width: 8),
                        Text('Düzenle'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'add_member',
                    child: Row(
                      children: [
                        Icon(Icons.person_add_alt_1_outlined),
                        SizedBox(width: 8),
                        Text('Üye Ekle'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline),
                        SizedBox(width: 8),
                        Text('Sil'),
                      ],
                    ),
                  ),
                ],
              )
            : const Icon(Icons.chevron_right_rounded),
      ),
    );
  }

  IconData _iconForTeamType(TeamType type) {
    switch (type) {
      case TeamType.ekip:
        return Icons.home_repair_service_outlined;
      case TeamType.operator:
        return Icons.support_agent;
      case TeamType.admin:
        return Icons.admin_panel_settings_outlined;
    }
  }
}