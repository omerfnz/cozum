import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shimmer/shimmer.dart';

import '../../../product/constants/api_endpoints.dart';
import '../../../product/models/report.dart';
import '../../../product/service/network/network_service.dart';
import '../../../product/service/auth/auth_service.dart';

class CategoriesView extends StatefulWidget {
  const CategoriesView({super.key});

  @override
  State<CategoriesView> createState() => _CategoriesViewState();
}

class _CategoriesViewState extends State<CategoriesView> {
  final _net = GetIt.I<INetworkService>();
  bool _loading = true;
  String? _error;
  List<Category> _items = [];

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

    final res = await _net.request<List<Category>>(
      path: ApiEndpoints.categories,
      type: RequestType.get,
      parser: (json) {
        if (json is List) {
          return json
              .map((e) => Category.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        if (json is Map && json['results'] is List) {
          return (json['results'] as List)
              .map((e) => Category.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return <Category>[];
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
        _error = res.error ?? 'Kategoriler yüklenemedi';
        _loading = false;
      });
    }
  }

  void _openCreate() {
    _openCategoryForm();
  }

  void _openEdit(Category category) {
    _openCategoryForm(initial: category);
  }

  Future<void> _deleteCategory(Category category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Kategoriyi sil'),
          content: Text('"${category.name}" kategorisini silmek istediğinize emin misiniz?'),
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
      path: ApiEndpoints.categoryById(category.id!),
      type: RequestType.delete,
    );

    if (!mounted) return;

    if (res.isSuccess) {
      setState(() {
        _items.removeWhere((c) => c.id == category.id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kategori silindi.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res.error ?? 'Silme işlemi başarısız.')),
      );
    }
  }

  Future<void> _openCategoryForm({Category? initial}) async {
    final formKey = GlobalKey<FormState>();
    String name = initial?.name ?? '';
    String? description = initial?.description;
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
                Text(initial == null ? 'Yeni Kategori' : 'Kategoriyi Düzenle', style: Theme.of(sheetContext).textTheme.titleLarge),
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
                        // setState kullanmadan local state değişimi yeterli (Form alanları bağımsız)
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
                          'is_active': isActive,
                        };

                        final isEdit = (initial?.id) != null;
                        final categoryId = initial?.id;
                        final path = categoryId != null
                            ? ApiEndpoints.categoryById(categoryId)
                            : ApiEndpoints.categories;
                        final reqType = isEdit ? RequestType.patch : RequestType.post;

                        final res = await _net.request<Category>(
                          path: path,
                          type: reqType,
                          data: body,
                          parser: (json) => Category.fromJson(json as Map<String, dynamic>),
                        );

                        if (!mounted) return;
                        if (!sheetContext.mounted) return;

                        if (res.isSuccess) {
                          final updated = res.data;
                          setState(() {
                            if (isEdit) {
                              final idx = _items.indexWhere((c) => c.id == categoryId);
                              if (idx != -1 && updated != null) {
                                _items[idx] = updated;
                              }
                            } else {
                              if (updated != null) {
                                _items.insert(0, updated);
                              } else {
                                // fallback: baştan yükle
                                _fetch();
                              }
                            }
                          });
                          ScaffoldMessenger.of(sheetContext).showSnackBar(
                            SnackBar(content: Text(isEdit ? 'Kategori güncellendi.' : 'Kategori oluşturuldu.')),
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
      return const _CategoriesShimmer();
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
            const Text('Henüz kategori bulunmuyor.'),
            if (_canManage) ...[
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _openCreate,
                icon: const Icon(Icons.add),
                label: const Text('Yeni Kategori'),
              ),
            ]
          ],
        ),
      );
    }

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _fetch,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final c = _items[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(c.name.isNotEmpty ? c.name.characters.first : '?'),
                  ),
                  title: Text(c.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (c.description != null && c.description!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            c.description!,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            c.isActive ? Icons.check_circle : Icons.cancel,
                            size: 16,
                            color: c.isActive
                                ? Colors.green.shade600
                                : Colors.red.shade600,
                          ),
                          const SizedBox(width: 6),
                          Text(c.isActive ? 'Aktif' : 'Pasif',
                              style: Theme.of(context).textTheme.bodySmall),
                        ],
                      )
                    ],
                  ),
                  onTap: _canManage ? () => _openEdit(c) : null,
                  trailing: _canManage
                      ? PopupMenuButton<String>(
                          onSelected: (v) {
                            if (v == 'edit') _openEdit(c);
                            if (v == 'delete') _deleteCategory(c);
                          },
                          itemBuilder: (ctx) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit_outlined),
                                  SizedBox(width: 8),
                                  Text('Düzenle'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
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
                      : null,
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
              label: const Text('Yeni Kategori'),
            ),
          ),
      ],
    );
  }
}

class _CategoriesShimmer extends StatelessWidget {
  const _CategoriesShimmer();

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
                      width: 200,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          height: 10,
                          width: 60,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          height: 10,
                          width: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}