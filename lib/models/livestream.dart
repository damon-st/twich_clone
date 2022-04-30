class LiveStream {
  final String title, image, uid, username;
  final startedAt;
  final int viewers;
  final String channelId;

  LiveStream({
    required this.title,
    required this.image,
    required this.uid,
    required this.username,
    required this.startedAt,
    required this.viewers,
    required this.channelId,
  });

  factory LiveStream.fromMap(Map<String, dynamic> map) {
    return LiveStream(
        title: map["title"],
        image: map["image"],
        uid: map["uid"],
        username: map["username"],
        startedAt: map["startedAt"],
        viewers: map["viewers"],
        channelId: map["channelId"]);
  }

  Map<String, dynamic> toMap() {
    return {
      "title": title,
      "image": image,
      "uid": uid,
      "username": username,
      "startedAt": startedAt,
      "viewers": viewers,
      "channelId": channelId,
    };
  }
}
