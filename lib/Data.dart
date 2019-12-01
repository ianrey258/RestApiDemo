
class Data{
  final String id;
  final String title;
  final String activity;
  final String datetime;
  Data({this.id,this.title,this.activity,this.datetime});

  factory Data.fromJson(Map<String, dynamic> json) {
    return new Data(
      id: json['id'],
      title: json['title'],
      activity: json['activity'],
      datetime: json['datetime'],
    );
  }
}