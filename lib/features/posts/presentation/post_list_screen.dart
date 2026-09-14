import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/error/app_exception.dart';
import '../domain/post.dart';
import '../presentation/post_providers.dart';

class PostListScreen extends ConsumerStatefulWidget {
  const PostListScreen({super.key});

  @override
  ConsumerState<PostListScreen> createState() => _PostListScreenState();
}

class _PostListScreenState extends ConsumerState<PostListScreen> {
  bool _showingCached = false;

  @override
  Widget build(BuildContext context) {
    final postsAsync = ref.watch(postListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Articles'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(postListProvider.notifier).refreshPosts();
            },
          ),
        ],
      ),
      body: postsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) {
          String message;
          if (err is AppException) {
            message = err.message;
            _showingCached = false;
          } else {
            message = 'Une erreur inattendue est survenue.';
          }
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.wifi_off, size: 64, color: Colors.orange),
                  const SizedBox(height: 16),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () =>
                        ref.read(postListProvider.notifier).refreshPosts(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Réessayer'),
                  ),
                ],
              ),
            ),
          );
        },
        data: (posts) {
          if (_showingCached) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Données affichées depuis le cache local (hors-ligne)'),
                    backgroundColor: Colors.orange,
                    duration: Duration(seconds: 3),
                  ),
                );
                _showingCached = false;
              }
            });
          }
          if (posts.isEmpty) {
            return const Center(child: Text('Aucun article disponible.'));
          }
          return RefreshIndicator(
            onRefresh: () =>
                ref.read(postListProvider.notifier).refreshPosts(),
            child: ListView.separated(
              itemCount: posts.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final post = posts[index];
                return ListTile(
                  title: Text(
                    post.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    post.body,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PostDetailScreen(postId: post.id),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreatePostScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
