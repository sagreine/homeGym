/*
part of 'video_bloc.dart';

abstract class VideoState extends Equatable {
  const VideoState();
}

class VideoInitial extends VideoState {
  const VideoInitial();
  @override
  List<Object> get props => [];
}

class VideoRecordingInProgress extends VideoState {
  final Video video;
  const VideoRecordingInProgress([this.video = const Video()]);
  @override
  List<Object> get props => [video];
}

class VideoRecordComplete extends VideoState {
  final Video video;

  const VideoRecordComplete([this.video = const Video()]);

  @override
  List<Object> get props => [video];

  @override
  String toString() => "VideoLoadSuccess {video: $video}";
}

class VideoRecordFailure extends VideoState {
  final Video video;
  const VideoRecordFailure([this.video = const Video()]);
  @override
  List<Object> get props => [video];
}

class VideoRecordCancel extends VideoState {
  final Video video;
  const VideoRecordCancel([this.video = const Video()]);
  @override
  List<Object> get props => [video];
}
*/
