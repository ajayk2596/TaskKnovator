import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../models/posts/post_model.dart';
import '../../../apis/rest_api/posts/post_api_controller.dart';
import 'post_event.dart';
import 'post_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final SharedPreferences prefs;
  final Map<int, Timer> _timers = {};
  final Map<int, int> _remainingTimes = {};

  List<PostModel> _posts = [];

  PostBloc({required this.prefs}) : super(PostLoading()) {
    on<FetchPosts>(_onFetchPosts);
    on<MarkAsRead>(_onMarkAsRead);
    on<StartTimer>(_onStartTimer);
    on<PauseTimer>(_onPauseTimer);
    on<UpdateTimer>(_onUpdateTimer);
  }

  final PostApiController postApiController = PostApiController();

  Future<void> _onFetchPosts(FetchPosts event, Emitter<PostState> emit) async {
    try {
      emit(PostLoading());

      final cachedPosts = _getCachedPosts();
      if (cachedPosts.isNotEmpty) {
        _posts = cachedPosts;
        emit(PostLoaded(_posts, Map.from(_remainingTimes)));
      }

      final List<PostModel> apiPosts = await postApiController.fetchAllPosts();

      if (apiPosts.isNotEmpty) {
        _posts = apiPosts;
        _cachePosts(_posts);
        emit(PostLoaded(_posts, Map.from(_remainingTimes)));
      } else {
        emit(PostError('No posts found.'));
      }
    } catch (e) {
      emit(PostError('Failed to fetch posts: ${e.toString()}'));
    }
  }

  void _onMarkAsRead(MarkAsRead event, Emitter<PostState> emit) {
    if (state is PostLoaded) {
      final currentState = state as PostLoaded;
      final updatedPosts = currentState.posts.map((post) {
        if (post.id == event.postId) {
          return post.copyWith(isRead: true);
        }
        return post;
      }).toList();

      _cachePosts(updatedPosts);
      emit(PostLoaded(updatedPosts, currentState.remainingTimes));
    }
  }

  void _onStartTimer(StartTimer event, Emitter<PostState> emit) {
    final postId = event.post.id;
    if (_timers[postId] == null) {
      _remainingTimes[postId] = event.post.estimatedReadTime ?? 20;
      _timers[postId] = Timer.periodic(const Duration(seconds: 1), (timer) {
        final remainingTime = (_remainingTimes[postId] ?? 0) - 1;
        if (remainingTime <= 0) {
          timer.cancel();
          _timers.remove(postId);
        }
        add(UpdateTimer(postId, remainingTime));
      });
    }
  }



  void _onPauseTimer(PauseTimer event, Emitter<PostState> emit) {
    final postId = event.post.id;
    _timers[postId]?.cancel();
    _timers.remove(postId);
  }


  void _onUpdateTimer(UpdateTimer event, Emitter<PostState> emit) {
    if (state is PostLoaded) {
      final currentState = state as PostLoaded;
      _remainingTimes[event.postId] = event.remainingTime;
      emit(PostLoaded(currentState.posts, Map.from(_remainingTimes)));
    }
  }

  List<PostModel> _getCachedPosts() {
    final postsJson = prefs.getStringList('cached_posts') ?? [];
    return postsJson
        .map((jsonStr) => PostModel.fromJson(json.decode(jsonStr)))
        .toList();
  }

  void _cachePosts(List<PostModel> posts) {
    final postsJson = posts.map((post) => json.encode(post.toJson())).toList();
    prefs.setStringList('cached_posts', postsJson);
  }

  @override
  Future<void> close() {
    for (var timer in _timers.values) {
      timer.cancel();
    }
    return super.close();
  }


}
