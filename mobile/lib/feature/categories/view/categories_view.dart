import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../product/constants/api_endpoints.dart';
import '../../../product/models/report.dart';
import '../../../product/service/network/network_service.dart';

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

  @override
  void initState() {
    super.initState();
    _fetch();
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

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
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
      return const Center(child: Text('Henüz kategori bulunmuyor.'));
    }

    return RefreshIndicator(
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
              onTap: () {},
            ),
          );
        },
      ),
    );
  }
}