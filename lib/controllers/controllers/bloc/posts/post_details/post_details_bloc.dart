import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:task_knovator/controllers/controllers/apis/rest_api/posts/post_api_controller.dart';
import 'post_details_event.dart';
import 'post_details_state.dart';

class PostDetailsBloc extends Bloc<PostDetailsEvent, PostDetailsState> {
  PostDetailsBloc() : super(PostDetailsInitial()) {
    on<FetchPostDetails>(_onFetchPostDetails);
  }

  final PostApiController postApiController = PostApiController();

  Future<void> _onFetchPostDetails(
      FetchPostDetails event,
      Emitter<PostDetailsState> emit,
      ) async {
    if (event.postId == null) {
      emit(PostDetailsError('Invalid Post ID'));
      return;
    }

    emit(PostDetailsLoading());

    try {
      final post = await postApiController.fetchPostDetails(event.postId!);
      if (post != null) {
        emit(PostDetailsLoaded(post));
      } else {
        emit(PostDetailsError('Failed to load post details'));
      }
    } catch (e) {
      emit(PostDetailsError('Failed to load post details: ${e.toString()}'));
    }
  }
}
