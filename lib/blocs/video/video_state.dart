part of 'video_bloc.dart';

abstract class VideoState extends Equatable {
  const VideoState();
}

class VideoInitial extends VideoState {
  @override
  List<Object> get props => [];
}
