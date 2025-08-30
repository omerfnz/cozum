import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../product/constants/api_endpoints.dart';
import '../../../product/models/user.dart' show Team; // sadece gerekli tipler
import '../../../product/service/network/network_service.dart';
import '../../../product/service/auth/auth_service.dart';
import '../../../product/widgets/enhanced_form_validation.dart';
import '../../../product/widgets/enhanced_shimmer.dart';
import '../widget/team_form_sheet.dart';
import '../widget/team_card.dart';

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
    if (team.id == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ekip ID eksik, silme işlemi yapılamıyor.')),
      );
      return;
    }
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
    if (team.id == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ekip ID eksik, üye ekleme işlemi yapılamıyor.')),
      );
      return;
    }

    final userId = await showDialog<int>(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController();
        final formKey = GlobalKey<FormState>();
        return AlertDialog(
          title: const Text('Ekip Üyesi Ekle'),
          content: Form(
            key: formKey,
            child: EnhancedTextFormField(
              controller: controller,
              labelText: 'Kullanıcı ID',
              prefixIcon: const Icon(Icons.person_outline),
              keyboardType: TextInputType.number,
              validator: FormValidators.validateNumeric,
              showRealTimeValidation: true,
              maxLength: 10,
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
    final result = await showModalBottomSheet<Team>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => TeamFormSheet(
        initialTeam: initial,
        onTeamSaved: () {
          if (initial != null) {
            // Edit case - refresh to get updated data
            _fetch();
          }
        },
      ),
    );

    if (result != null && initial == null) {
      // New team created
      setState(() {
        _items.insert(0, result);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const TeamsShimmer();
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
              return TeamCard(
                team: t,
                canManage: _canManage,
                onEdit: () => _openEdit(t),
                onDelete: () => _deleteTeam(t),
                onAddMember: () => _addMember(t),
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

}