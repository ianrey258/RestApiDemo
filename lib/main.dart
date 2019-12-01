import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:http/http.dart' as http;
import 'package:restapidemo/Data.dart';

Future<List<Data>> fetchdata() async {
  final response = await http.get('https://ianrey.000webhostapp.com/');
  if (response.statusCode == 200) {
    List parseJson = jsonDecode(response.body);
    return (parseJson)
      .map((p) => Data.fromJson(p))
      .toList();
  } else {
    throw Exception('Failed to load post');
  }
}

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
   String id,datetxt;
   List<Data> request;

  TextEditingController eventTitle = TextEditingController();
  TextEditingController activity = TextEditingController();
  TextEditingController date = TextEditingController();
  ScrollController _sc = ScrollController();

  Widget build(context){
    return Scaffold(
      appBar: AppBar(title: Text("RestAPI_Sample")),
      body:RefreshIndicator(
        onRefresh: refresh,
        child: ListView(
          controller: _sc,
        children: <Widget>[
          Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.all(3),
                      child: TextField(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Title Event',
                        fillColor: Colors.grey[300],
                        filled: true,
                      ),
                      controller: eventTitle,
                    ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.all(3),
                      child: TextField(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Activity',
                        fillColor: Colors.grey[300],
                        filled: true,
                      ),
                      controller: activity,
                    ),
                    ),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      child: TextField(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'YYYY-MM-DD',
                        fillColor: Colors.grey[300],
                        filled: true,
                      ),
                      controller: date,
                    ),
                    ),
                  ),
                  Expanded(
                    child: calendar(),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.all(3),
                      child: FlatButton(
                        color: Colors.green,
                        onPressed: clearController,
                        child: Text("Clear"),
                      ),
                    )
                  ),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.all(3),
                      child: FlatButton(
                        color: Colors.blue,
                        onPressed: createData,
                        child: Text("Submit"),
                      ),
                    )
                  ),
                ],
              ),
              Container(
                  child: ListView(
                    controller: _sc,
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  padding: EdgeInsets.all(8.0),
                  children: <Widget>[
                    FutureBuilder<List<Data>>(
                      future: fetchdata(),
                      builder: (context ,snapshot){
                        request = snapshot.data;
                        //Future<Data> data;
                        if(snapshot.hasData){
                           return Container(
                            child: Column(
                              children: request.map((data) => Container(
                                alignment: Alignment.centerLeft,
                                margin: EdgeInsets.all(5),
                                child: Column(
                                  children: <Widget>[
                                  buildItem(data),
                                ],
                                ),
                              )).toList()
                          )
                          );
                        }
                        else if(snapshot.hasError){
                          return Text("Cant load Data due to Internet Connection\n ${snapshot.error}");
                        }
                        return Center(child: CircularProgressIndicator());
                      },
                    ),
                  ],
                ),
                )
        ],
      ),
      )
    );
  }
Future<Null> refresh() async{
  setState(() {
    fetchdata();
    request = List();
  });
  return Future.value();
}
void createData() async {
    await http.post('https://ianrey.000webhostapp.com/',
        body: {'title': eventTitle.text,
                'activity': activity.text,
                'datetime': date.text});
    
    clearController();
  }

  void updateData(String id) async {
      await http.post('https://ianrey.000webhostapp.com/',
          body: {'id': id, 
                  'title': eventTitle.text,
                  'activity': activity.text,
                  'datetime': date.text});
    
    
    clearController();
  }

  void deleteData(String id) async {
      print( id);
      await http.post('https://ianrey.000webhostapp.com/Todolist/deleteData',
          body: {'id': id});
    fetchdata();
    clearController();
  }
  void clearController(){
    setState(() {
      eventTitle.text ="";
      activity.text ="";
      date.text ="";
      datetxt="";
    });
  }

Card buildItem(Data doc) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Id: ${doc.id}',
              style: TextStyle(fontSize: 24),
            ),
            Text(
              'Title: ${doc.title}',
              style: TextStyle(fontSize: 24),
            ),
            Text(
              'Activity: ${doc.activity}',
              style: TextStyle(fontSize : 15),
            ),
            Text(
              'Date: ${doc.datetime}',
              style: TextStyle(fontSize : 20),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                FlatButton(
                  onPressed: () => updateData(doc.id),
                  child: Text('Update',
                      style: TextStyle(color: Colors.white)),
                  color: Colors.green,
                ),
                SizedBox(width: 8),
                FlatButton(
                  color: Colors.red,  
                  onPressed: () => deleteData(doc.id),
                  child: Text('Delete'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
  Widget calendar(){
    return Container(
      padding: EdgeInsets.only(right: 130),
      child: IconButton(
        icon: Icon(Icons.calendar_today),
        onPressed: (){setState(() {
          String yr;String m;String d;
          DatePicker.showDatePicker(context,showTitleActions: true,minTime: DateTime(2017, 1, 1),maxTime: DateTime(2023, 12, 1), 
          onConfirm: (cdate) {
            yr = cdate.year.toString();m = cdate.month.toString();d = cdate.day.toString();
            date.text="$yr-$m-$d";
            datetxt = "$m-$d-$yr";
          },
          currentTime: DateTime.now(), 
          locale: LocaleType.en);
        });},
      ),
    );
  }
}
