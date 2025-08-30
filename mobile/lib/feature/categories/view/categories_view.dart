import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../product/constants/api_endpoints.dart';
import '../../../product/models/report.dart';
import '../../../product/service/network/network_service.dart';
import '../../../product/service/auth/auth_service.dart';
import '../../../product/widgets/enhanced_shimmer.dart';
import '../widget/category_form_sheet.dart';
import '../widget/category_card.dart';
import '../widget/categories_error_view.dart';
import '../widget/categories_empty_view.dart';

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
    // ID null ise güvenli şekilde çık
    if (category.id == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kategori ID eksik, silme işlemi yapılamıyor.')),
      );
      return;
    }

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

  void _openCategoryForm({Category? initial}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return CategoryFormSheet(
          initial: initial,
          onSuccess: () {
            setState(() {
              _fetch();
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const CategoriesShimmer();
    }

    if (_error != null) {
      return CategoriesErrorView(
        error: _error!,
        onRetry: _fetch,
      );
    }

    if (_items.isEmpty) {
      return CategoriesEmptyView(
        canManage: _canManage,
        onCreateNew: _openCreate,
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
              return CategoryCard(
                category: c,
                canManage: _canManage,
                onEdit: () => _openEdit(c),
                onDelete: () => _deleteCategory(c),
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