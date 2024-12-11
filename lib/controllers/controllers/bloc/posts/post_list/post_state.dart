
import '../../../../../models/posts/post_model.dart';

abstract class PostState {}

class PostLoading extends PostState {}

class PostLoaded extends PostState {
  final List<PostModel> posts;
  final Map<int, int> remainingTimes;
  PostLoaded(this.posts, this.remainingTimes);
}

class PostError extends PostState {
  final String message;
  PostError(this.message);
}
