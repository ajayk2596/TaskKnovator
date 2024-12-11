import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../controllers/controllers/bloc/posts/post_details/post_details_bloc.dart';
import '../../controllers/controllers/bloc/posts/post_details/post_details_event.dart';
import '../../controllers/controllers/bloc/posts/post_details/post_details_state.dart';
import '../../models/posts/post_model.dart';

class PostDetailScreen extends StatelessWidget {
  final PostModel post;
  const PostDetailScreen({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PostDetailsBloc()..add(FetchPostDetails(post.id)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Post Details'),
        ),
        body: BlocBuilder<PostDetailsBloc, PostDetailsState>(
          builder: (context, state) {
            if (state is PostDetailsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is PostDetailsLoaded) {
              final postDetails = state.post;
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          postDetails.title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          postDetails.body,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            "Post ID: ${postDetails.id}",
                            style: const TextStyle(
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            } else if (state is PostDetailsError) {
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
      ),
    );
  }
}
