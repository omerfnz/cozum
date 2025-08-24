import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mobile/core/extensions/extensions.dart';
import 'package:mobile/core/widgets/widgets.dart';
import 'package:mobile/feature/admin/teams/cubit/teams_cubit.dart';
import 'package:mobile/product/report/model/report_models.dart';

class TeamsView extends StatelessWidget {
  const TeamsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TeamsCubit()..fetchTeams(),
      child: const _TeamsViewBody(),
    );
  }
}

class _TeamsViewBody extends StatelessWidget {
  const _TeamsViewBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<TeamsCubit, TeamsState>(
        listener: (context, state) {
          if (state.hasError) {
            ErrorSnackBar.show(
              context,
              state.error!,
              onAction: () => context.read<TeamsCubit>().clearError(),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading && state.isEmpty) {
            return const GlobalLoadingWidget(message: 'Takımlar yükleniyor...');
          }

          if (state.hasError && state.isEmpty) {
            return GlobalErrorWidget(
              error: state.error!,
              onRetry: () => context.read<TeamsCubit>().fetchTeams(),
            );
          }

          if (state.isEmpty) {
            return const EmptyStateWidget(
              message: 'Henüz takım bulunmuyor',
              icon: Icons.groups_outlined,
            );
          }

          return _TeamsListView(
            teams: state.teams,
            isLoading: state.isLoading,
            onRefresh: () => context.read<TeamsCubit>().refreshTeams(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateTeamDialog(context),
        backgroundColor: context.primaryColor,
        foregroundColor: context.onPrimaryColor,
        child: Icon(
          Icons.add,
          size: context.responsiveIconSize(24),
        ),
      ),
    );
  }

  void _showCreateTeamDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<TeamsCubit>(),
        child: const _CreateTeamDialog(),
      ),
    );
  }
}

class _TeamsListView extends StatelessWidget {
  const _TeamsListView({
    required this.teams,
    required this.isLoading,
    required this.onRefresh,
  });

  final List<TeamDto> teams;
  final bool isLoading;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView.separated(
        padding: EdgeInsets.all(context.isMobile ? 16 : 24),
        itemCount: teams.length,
        separatorBuilder: (_, __) => SizedBox(height: context.isMobile ? 12 : 16),
        itemBuilder: (context, index) {
          final team = teams[index];
          return _TeamCard(
            team: team,
            onEdit: () => _showEditTeamDialog(context, team),
            onDelete: () => _showDeleteConfirmation(context, team),
          );
        },
      ),
    );
  }

  void _showEditTeamDialog(BuildContext context, TeamDto team) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<TeamsCubit>(),
        child: _EditTeamDialog(team: team),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, TeamDto team) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Takımı Sil'),
        content: Text('"${team.name}" takımını silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('İptal'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await context.read<TeamsCubit>().deleteTeam(team.id);
            },
            style: FilledButton.styleFrom(
              backgroundColor: context.errorColor,
            ),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }
}

class _TeamCard extends StatelessWidget {
  const _TeamCard({
    required this.team,
    required this.onEdit,
    required this.onDelete,
  });

  final TeamDto team;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd.MM.yyyy');
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.responsiveBorderRadius),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.isMobile ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        team.name,
                        style: context.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: context.responsiveFontSize(16),
                          color: context.onSurfaceColor,
                        ),
                      ),
                      if (team.description != null && team.description!.isNotEmpty) ...[
                        SizedBox(height: context.isMobile ? 4 : 6),
                        Text(
                          team.description!,
                          style: context.bodyMedium?.copyWith(
                            fontSize: context.responsiveFontSize(14),
                            color: context.onSurfaceColor.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        onEdit();
                        break;
                      case 'delete':
                        onDelete();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit),
                          SizedBox(width: 8),
                          Text('Düzenle'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Sil', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: context.isMobile ? 12 : 16),
            Row(
              children: [
                if (team.teamType != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: context.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      team.teamType!,
                      style: context.bodySmall?.copyWith(
                        color: context.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(width: context.isMobile ? 4 : 6),
                ],
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (team.isActive ?? true)
                         ? Colors.green.withValues(alpha: 0.1)
                         : Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    (team.isActive ?? true) ? 'Aktif' : 'Pasif',
                    style: context.bodySmall?.copyWith(
                      color: (team.isActive ?? true) ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Spacer(),
                if (team.createdAt != null)
                  Text(
                    dateFormat.format(team.createdAt!),
                    style: context.bodySmall?.copyWith(
                      color: context.onSurfaceColor.withValues(alpha: 0.6),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateTeamDialog extends StatefulWidget {
  const _CreateTeamDialog();

  @override
  State<_CreateTeamDialog> createState() => _CreateTeamDialogState();
}

class _CreateTeamDialogState extends State<_CreateTeamDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedTeamType;

  final List<String> _teamTypes = [
    'SAHA',
    'TEKNIK',
    'YONETIM',
    'DESTEK',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Yeni Takım Oluştur'),
      content: SizedBox(
        width: context.isMobile ? double.maxFinite : 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Takım Adı',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Takım adı gereklidir';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Açıklama (Opsiyonel)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedTeamType,
                decoration: const InputDecoration(
                  labelText: 'Takım Türü (Opsiyonel)',
                  border: OutlineInputBorder(),
                ),
                items: _teamTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedTeamType = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('İptal'),
        ),
        BlocBuilder<TeamsCubit, TeamsState>(
          builder: (context, state) {
            return FilledButton(
              onPressed: state.isLoading ? null : _createTeam,
              child: state.isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Oluştur'),
            );
          },
        ),
      ],
    );
  }

  Future<void> _createTeam() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await context.read<TeamsCubit>().createTeam(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          teamType: _selectedTeamType,
        );

    if (success && mounted) {
      Navigator.of(context).pop();
    }
  }
}

class _EditTeamDialog extends StatefulWidget {
  const _EditTeamDialog({required this.team});

  final TeamDto team;

  @override
  State<_EditTeamDialog> createState() => _EditTeamDialogState();
}

class _EditTeamDialogState extends State<_EditTeamDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late String? _selectedTeamType;
  late bool _isActive;

  final List<String> _teamTypes = [
    'SAHA',
    'TEKNIK',
    'YONETIM',
    'DESTEK',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.team.name);
    _descriptionController = TextEditingController(text: widget.team.description ?? '');
    _selectedTeamType = widget.team.teamType;
    _isActive = widget.team.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Takımı Düzenle'),
      content: SizedBox(
        width: context.isMobile ? double.maxFinite : 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Takım Adı',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Takım adı gereklidir';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Açıklama',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedTeamType,
                decoration: const InputDecoration(
                  labelText: 'Takım Türü',
                  border: OutlineInputBorder(),
                ),
                items: _teamTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedTeamType = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Aktif'),
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('İptal'),
        ),
        BlocBuilder<TeamsCubit, TeamsState>(
          builder: (context, state) {
            return FilledButton(
              onPressed: state.isLoading ? null : _updateTeam,
              child: state.isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Güncelle'),
            );
          },
        ),
      ],
    );
  }

  Future<void> _updateTeam() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await context.read<TeamsCubit>().updateTeam(
          id: widget.team.id,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          teamType: _selectedTeamType,
          isActive: _isActive,
        );

    if (success && mounted) {
      Navigator.of(context).pop();
    }
  }
}