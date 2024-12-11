
import '../../../../../models/posts/post_model.dart';

abstract class PostDetailsState {}

class PostDetailsInitial extends PostDetailsState {}

class PostDetailsLoading extends PostDetailsState {}

class PostDetailsLoaded extends PostDetailsState {
  final PostModel post;
  PostDetailsLoaded(this.post);
}

class PostDetailsError extends PostDetailsState {
  final String message;
  PostDetailsError(this.message);
}