import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/error/app_exception.dart';
import '../presentation/post_providers.dart';

class PostDetailScreen extends ConsumerWidget {
  final int postId;
  const PostDetailScreen({super.key, required this.postId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postAsync = ref.watch(postDetailProvider(postId));

    return Scaffold(
      appBar: AppBar(title: const Text('Détail de l\'article')),
      body: postAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) {
          String message;
          if (err is AppException) {
            message = err.message;
          } else {
            message = 'Impossible de charger l\'article.';
          }
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(message, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => ref.invalidate(postDetailProvider(postId)),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Réessayer'),
                  ),
                ],
              ),
            ),
          );
        },
        data: (post) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.title,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Chip(
                        label: Text('Article #${post.id}'),
                        backgroundColor:
                            Theme.of(context).colorScheme.secondaryContainer,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    post.body,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Auteur'),
                  subtitle: Text('Utilisateur #${post.userId}'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
