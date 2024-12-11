import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../controllers/controllers/bloc/posts/post_list/post_bloc.dart';
import '../../controllers/controllers/bloc/posts/post_list/post_event.dart';
import '../../controllers/controllers/bloc/posts/post_list/post_state.dart';
import '../posts/post_details_screen.dart';

class PostListScreen extends StatelessWidget {
  const PostListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts'),
      ),
      body: FutureBuilder<SharedPreferences>(
        future: SharedPreferences.getInstance(),
        builder: (context, prefsSnapshot) {
          if (!prefsSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return BlocProvider(
            create: (_) =>
            PostBloc(prefs: prefsSnapshot.data!)..add(FetchPosts()),
            child: BlocBuilder<PostBloc, PostState>(
              builder: (context, state) {
                if (state is PostLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is PostLoaded) {
                  final posts = state.posts;
                  final remainingTimes = state.remainingTimes;

                  return RefreshIndicator(
                    onRefresh: () async {
                      // Trigger a refresh event
                      context.read<PostBloc>().add(FetchPosts());
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        final post = posts[index];
                        final remainingTime =
                            remainingTimes[post.id] ?? post.estimatedReadTime ?? 20;

                        return Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          margin: const EdgeInsets.only(bottom: 16),
                          child: VisibilityDetector(
                            key: Key('post-${post.id}'),
                            onVisibilityChanged: (info) {
                              if (info.visibleFraction > 0.5) {
                                context.read<PostBloc>().add(StartTimer(post));
                              } else {
                                context.read<PostBloc>().add(PauseTimer(post));
                              }
                            },
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              tileColor: post.isRead
                                  ? Colors.white
                                  : Colors.yellow.shade100,
                              title: Text(
                                post.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  '$remainingTime seconds remaining',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              trailing: Icon(
                                post.isRead ? Icons.check_circle : Icons.timer,
                                color: post.isRead ? Colors.green : Colors.grey,
                              ),
                              onTap: () {
                                // Pause timer and mark post as read
                                context.read<PostBloc>().add(PauseTimer(post));
                                context.read<PostBloc>().add(MarkAsRead(postId: post.id));
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        PostDetailScreen(post: post),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  );
                } else if (state is PostError) {
                  return Center(
                    child: Text(
                      state.message,
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          );
        },
      ),
    );
  }
}
