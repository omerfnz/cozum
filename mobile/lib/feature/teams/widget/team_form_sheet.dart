import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../product/constants/api_endpoints.dart';
import '../../../product/models/user.dart' show Team, TeamType;
import '../../../product/service/network/network_service.dart';
import '../../../product/widgets/enhanced_form_validation.dart';

class TeamFormSheet extends StatefulWidget {
  final Team? initialTeam;
  final VoidCallback? onTeamSaved;

  const TeamFormSheet({
    super.key,
    this.initialTeam,
    this.onTeamSaved,
  });

  @override
  State<TeamFormSheet> createState() => _TeamFormSheetState();
}

class _TeamFormSheetState extends State<TeamFormSheet> {
  final _net = GetIt.I<INetworkService>();
  final _formKey = GlobalKey<FormState>();
  
  late String _name;
  String? _description;
  late TeamType _teamType;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _name = widget.initialTeam?.name ?? '';
    _description = widget.initialTeam?.description;
    _teamType = widget.initialTeam?.teamType ?? TeamType.ekip;
    _isActive = widget.initialTeam?.isActive ?? true;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.initialTeam == null ? 'Yeni Ekip' : 'Ekibi Düzenle',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            EnhancedTextFormField(
              controller: TextEditingController(text: _name),
              labelText: 'Ad',
              prefixIcon: const Icon(Icons.group_rounded),
              validator: (value) => FormValidators.validateRequired(value, 'Ad'),
              showRealTimeValidation: true,
              maxLength: 50,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<TeamType>(
              value: _teamType,
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
                if (val != null) {
                  setState(() {
                    _teamType = val;
                  });
                }
              },
            ),
            const SizedBox(height: 12),
            EnhancedTextFormField(
              controller: TextEditingController(text: _description ?? ''),
              labelText: 'Açıklama (opsiyonel)',
              prefixIcon: const Icon(Icons.description_rounded),
              maxLines: 4,
              showRealTimeValidation: true,
              maxLength: 200,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Switch(
                  value: _isActive,
                  onChanged: (val) {
                    setState(() {
                      _isActive = val;
                    });
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
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Kapat'),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: _saveTeam,
                  icon: const Icon(Icons.save_outlined),
                  label: Text(widget.initialTeam == null ? 'Oluştur' : 'Kaydet'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveTeam() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final body = <String, dynamic>{
      'name': _name,
      if (_description != null) 'description': _description,
      'team_type': _teamType.value,
      'is_active': _isActive,
    };

    final isEdit = widget.initialTeam?.id != null;
    final teamId = widget.initialTeam?.id;
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

    if (res.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isEdit ? 'Ekip güncellendi.' : 'Ekip oluşturuldu.')),
      );
      Navigator.of(context).pop(res.data);
      widget.onTeamSaved?.call();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res.error ?? 'İşlem başarısız.')),
      );
    }
  }
}