
import '../../../../../models/posts/post_model.dart';

abstract class PostEvent {}

class FetchPosts extends PostEvent {}

class MarkAsRead extends PostEvent {
  final int postId;
  MarkAsRead({required this.postId});
}

class StartTimer extends PostEvent {
  final PostModel post;
  StartTimer(this.post);
}

class PauseTimer extends PostEvent {
  final PostModel post;
  PauseTimer(this.post);
}

class UpdateTimer extends PostEvent {
  final int postId;
  final int remainingTime;
  UpdateTimer(this.postId, this.remainingTime);
}
