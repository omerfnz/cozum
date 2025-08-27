import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shimmer/shimmer.dart';

import '../../../product/constants/api_endpoints.dart';
import '../../../product/models/user.dart' show Team, TeamType; // sadece gerekli tipler
import '../../../product/service/network/network_service.dart';
import '../../../product/service/auth/auth_service.dart';

@RoutePage()
class TeamsView extends StatefulWidget {
  const TeamsView({super.key});

  @override
  State<TeamsView> createState() => _TeamsViewState();
}

class _TeamsViewState extends State<TeamsView> {
  final _net = GetIt.I<INetworkService>();

  bool _loading = true;
  String? _error;
  List<Team> _items = [];

  String _role = 'VATANDAS';
  bool get _canManage => _role == 'OPERATOR' || _role == 'ADMIN';

  @override
  void initState() {
    super.initState();
    _fetch();
    _loadRole();
  }

  Future<void> _loadRole() async {
    try {
      final me = await GetIt.I<IAuthService>().getCurrentUser();
      if (!mounted) return;
      setState(() {
        _role = me.data?.role ?? 'VATANDAS';
      });
    } catch (_) {
      // ignore
    }
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final res = await _net.request<List<Team>>(
      path: ApiEndpoints.teams,
      type: RequestType.get,
      parser: (json) {
        if (json is List) {
          return json.map((e) => Team.fromJson(e as Map<String, dynamic>)).toList();
        }
        if (json is Map && json['results'] is List) {
          return (json['results'] as List)
              .map((e) => Team.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return <Team>[];
      },
    );

    if (!mounted) return;

    if (res.isSuccess) {
      setState(() {
        _items = res.data ?? [];
        _loading = false;
      });
    } else {
      setState(() {
        _error = res.error ?? 'Ekipler yüklenemedi';
        _loading = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    await _fetch();
  }

  void _openCreate() {
    _openTeamForm();
  }

  void _openEdit(Team team) {
    _openTeamForm(initial: team);
  }

  Future<void> _deleteTeam(Team team) async {
    if (team.id == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Ekibi sil'),
          content: Text('"${team.name}" ekibini silmek istediğinize emin misiniz?'),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Vazgeç')),
            FilledButton.icon(
              onPressed: () => Navigator.of(ctx).pop(true),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Sil'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    final res = await _net.request<dynamic>(
      path: ApiEndpoints.teamById(team.id!),
      type: RequestType.delete,
    );

    if (!mounted) return;

    if (res.isSuccess) {
      setState(() {
        _items.removeWhere((t) => t.id == team.id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ekip silindi.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res.error ?? 'Silme işlemi başarısız.')),
      );
    }
  }

  Future<void> _addMember(Team team) async {
    if (team.id == null) return;

    final userId = await showDialog<int>(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController();
        final formKey = GlobalKey<FormState>();
        return AlertDialog(
          title: const Text('Ekip Üyesi Ekle'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Kullanıcı ID',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Kullanıcı ID giriniz';
                final parsed = int.tryParse(v.trim());
                if (parsed == null) return 'Geçerli bir sayı giriniz';
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Vazgeç'),
            ),
            FilledButton.icon(
              onPressed: () {
                final st = formKey.currentState;
                if (st == null) return;
                if (!st.validate()) return;
                final parsed = int.parse(controller.text.trim());
                Navigator.of(ctx).pop(parsed);
              },
              icon: const Icon(Icons.person_add_alt_1_outlined),
              label: const Text('Ekle'),
            ),
          ],
        );
      },
    );

    if (userId == null) return;

    if (!mounted) return;
    // BuildContext sonrası kullanım uyarısından kaçınmak için Messenger'ı önceden alalım
    final messenger = ScaffoldMessenger.of(context);

    final res = await _net.request<dynamic>(
      path: ApiEndpoints.userSetTeam(userId),
      type: RequestType.post,
      data: {
        'team_id': team.id,
      },
    );

    if (!mounted) return;

    if (res.isSuccess) {
      messenger.showSnackBar(const SnackBar(content: Text('Üye eklendi.')));
      // Güncel listeyi çek (üye sayısı vs.)
      _fetch();
    } else {
      messenger.showSnackBar(
        SnackBar(content: Text(res.error ?? 'Üye eklenemedi.')),
      );
    }
  }

  Future<void> _openTeamForm({Team? initial}) async {
    final formKey = GlobalKey<FormState>();
    String name = initial?.name ?? '';
    String? description = initial?.description;
    TeamType teamType = initial?.teamType ?? TeamType.ekip;
    bool isActive = initial?.isActive ?? true;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(initial == null ? 'Yeni Ekip' : 'Ekibi Düzenle',
                    style: Theme.of(sheetContext).textTheme.titleLarge),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: name,
                  decoration: const InputDecoration(
                    labelText: 'Ad',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Ad zorunludur';
                    return null;
                  },
                  onSaved: (v) => name = v!.trim(),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<TeamType>(
                  value: teamType,
                  decoration: const InputDecoration(
                    labelText: 'Ekip Türü',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: TeamType.values
                      .map((t) => DropdownMenuItem(
                            value: t,
                            child: Text(t.displayName),
                          ))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) teamType = val;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: description,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Açıklama (opsiyonel)',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onSaved: (v) => description = (v?.trim().isEmpty ?? true) ? null : v?.trim(),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Switch(
                      value: isActive,
                      onChanged: (val) {
                        isActive = val;
                      },
                    ),
                    const SizedBox(width: 8),
                    const Text('Aktif')
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      child: const Text('Kapat'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: () async {
                        final currentState = formKey.currentState;
                        if (currentState == null || !currentState.validate()) return;
                        currentState.save();

                        final body = <String, dynamic>{
                          'name': name,
                          if (description != null) 'description': description,
                          'team_type': teamType.value,
                          'is_active': isActive,
                        };

                        final isEdit = (initial?.id) != null;
                        final teamId = initial?.id;
                        final path = teamId != null
                            ? ApiEndpoints.teamById(teamId)
                            : ApiEndpoints.teams;
                        final reqType = isEdit ? RequestType.patch : RequestType.post;

                        final res = await _net.request<Team>(
                          path: path,
                          type: reqType,
                          data: body,
                          parser: (json) => Team.fromJson(json as Map<String, dynamic>),
                        );

                        if (!mounted) return;
                        if (!sheetContext.mounted) return;

                        if (res.isSuccess) {
                          final updated = res.data;
                          setState(() {
                            if (isEdit) {
                              final idx = _items.indexWhere((t) => t.id == teamId);
                              if (idx != -1 && updated != null) {
                                _items[idx] = updated;
                              }
                            } else {
                              if (updated != null) {
                                _items.insert(0, updated);
                              } else {
                                _fetch();
                              }
                            }
                          });
                          ScaffoldMessenger.of(sheetContext).showSnackBar(
                            SnackBar(content: Text(isEdit ? 'Ekip güncellendi.' : 'Ekip oluşturuldu.')),
                          );
                          Navigator.of(sheetContext).pop();
                        } else {
                          if (!sheetContext.mounted) return;
                          ScaffoldMessenger.of(sheetContext).showSnackBar(
                            SnackBar(content: Text(res.error ?? 'İşlem başarısız.')),
                          );
                        }
                      },
                      icon: const Icon(Icons.save_outlined),
                      label: Text(initial == null ? 'Oluştur' : 'Kaydet'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const _TeamsShimmer();
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 36),
            const SizedBox(height: 8),
            Text(_error!),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _fetch,
              icon: const Icon(Icons.refresh),
              label: const Text('Tekrar dene'),
            ),
          ],
        ),
      );
    }

    if (_items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Henüz ekip bulunmuyor.'),
            if (_canManage) ...[
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _openCreate,
                icon: const Icon(Icons.add),
                label: const Text('Yeni Ekip'),
              ),
            ]
          ],
        ),
      );
    }

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _onRefresh,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final t = _items[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Icon(_iconForTeamType(t.teamType)),
                  ),
                  title: Text(t.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.teamType.displayName,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            t.isActive ? Icons.check_circle : Icons.cancel,
                            size: 16,
                            color: t.isActive ? Colors.green.shade600 : Colors.red.shade600,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            flex: 2,
                            child: Text(
                              t.isActive ? 'Aktif' : 'Pasif',
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
                              '${t.memberCount} üye',
                              style: Theme.of(context).textTheme.bodySmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  onTap: _canManage ? () => _openEdit(t) : null,
                  trailing: _canManage
                      ? PopupMenuButton<String>(
                          onSelected: (v) {
                            if (v == 'edit') _openEdit(t);
                            if (v == 'delete') _deleteTeam(t);
                            if (v == 'add_member') _addMember(t);
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
            },
          ),
        ),
        if (_canManage)
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton.extended(
              onPressed: _openCreate,
              icon: const Icon(Icons.add),
              label: const Text('Yeni Ekip'),
            ),
          ),
      ],
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

class _TeamsShimmer extends StatelessWidget {
  const _TeamsShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Card(
            child: ListTile(
              leading: const CircleAvatar(backgroundColor: Colors.white),
              title: Container(
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 12,
                      width: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Container(
                            height: 10,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          flex: 2,
                          child: Container(
                            height: 10,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          flex: 1,
                          child: Container(
                            height: 10,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white),
            ),
          ),
        );
      },
    );
  }
}