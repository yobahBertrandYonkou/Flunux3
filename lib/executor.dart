import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flunux3/builder.dart';
import 'package:http/http.dart' as http;

class Executor extends StatefulWidget {
  @override
  _ExecutorState createState() => _ExecutorState();
}

class _ExecutorState extends State<Executor> {
  TextEditingController _controller = TextEditingController();
  TextEditingController _urlController = TextEditingController();
  var fsconnect = FirebaseFirestore.instance;
  var consoleOutput;
  bool isThere = false;
  var cmdText;
  var currentUserId;
  int statusCode;
  double height = 0.79;
  dataSender(dynamic data, String cmd, String userId) {
    DateTime now = new DateTime.now();
    var finalData = {
      "command": {
        "cmd": cmd,
        "output": data["output"],
        "exit-code": data["status"]
      },
      "date-time": new DateTime(now.year, now.month, now.day, now.hour,
          now.minute, now.second, now.millisecond),
      "user-id": userId,
    };

    try {
      fsconnect.collection("flunux-$userId").add(finalData);
      print("Successfully pushed");
      setState(() {
        currentUserId = userId;
      });
    } catch (e) {
      print("\n\n#####################\n $e \n###################\n\n");
    }
  }

  apiGuru(var cmd) async {
    setState(() {
      if (cmd.indexOf("sudo") == -1) {
        cmdText = cmd = ("sudo " + cmd).trim().toLowerCase();
      }
    });

    var url = "http://65.0.113.228/cgi-bin/?cmd=${cmd}";
    print(url);
    var response;
    var userId;
    var decoded;
    if (cmd != "sudo refresh") {
      response = await http.get(url);
      userId = "1941146";
      decoded = jsonDecode(response.body);
      dataSender(decoded[0], cmd, userId);
    } else {
      userId = "1941146";
      dataSender(
          {"status": 0, "output": "Successfully Refreshed page"}, cmd, userId);
    }

    await fsconnect
        .collection("flunux-1941146")
        .orderBy("date-time")
        .get()
        .then((value) => {
              setState(() {
                consoleOutput =
                    value.docs[value.size - 1].data()["command"]["output"];
                isThere = true;
              })
            })
        .catchError((onError) => print("This is the error received: $onError"));
  }

  @override
  Widget build(BuildContext context) {
    final mediaquery = MediaQuery.of(context);
    if (mediaquery.orientation == Orientation.landscape) {
      setState(() {
        height = 0.7;
      });
    } else if (mediaquery.orientation == Orientation.portrait) {
      setState(() {
        height = 0.79;
      });
    }

    Widget body = Container(
      height: MediaQuery.of(context).size.height * height,
      width: MediaQuery.of(context).size.width * 0.95,
      child: SingleChildScrollView(
        reverse: true,
        child: Column(
          children: <Widget>[
            Text(
              "COMMAND OUTPUT - DETAILS",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: "courier new",
                  fontSize: 18,
                  color: Colors.white),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              child: !isThere
                  ? Text("Here")
                  : StreamBuilder<QuerySnapshot>(
                      builder: (context, snapshots) {
                        var data = snapshots.data.docs;
                        List<Widget> cards = [];
                        for (var i in data) {
                          cards.add(CodeCards(i.data()));
                        }

                        return SingleChildScrollView(
                          child: Column(
                            children: cards,
                          ),
                        );
                      },
                      stream: fsconnect
                          .collection("flunux-$currentUserId")
                          .orderBy("date-time", descending: false)
                          .snapshots(),
                    ),
            ),
          ],
        ),
      ),
    );
    return Scaffold(
      resizeToAvoidBottomInset: false,
      resizeToAvoidBottomPadding: false,
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xffce6262),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              if (cmdText.isNotEmpty) {
                apiGuru(cmdText);
              }
            },
            child: Text(
              "RUN",
              style: TextStyle(color: Colors.white),
            ),
            splashColor: Colors.white,
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => apiGuru("refresh"),
          ),
        ],
        title: Text(
          "B.M.B CE",
          style: TextStyle(
            fontFamily: "courier new",
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 10,
            ),
            Container(
              decoration: BoxDecoration(color: Colors.black, boxShadow: [
                BoxShadow(
                  color: const Color(0xffce6262),
                  blurRadius: 5,
                  spreadRadius: 1,
                  offset: Offset(1, 1),
                )
              ]),
              width: MediaQuery.of(context).size.width * 0.95,
              child: TextField(
                style: TextStyle(
                  fontFamily: "courier new",
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
                controller: _controller,
                autocorrect: false,
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: Colors.white,
                    ),
                    onPressed: () => _controller.clear(),
                  ),
                  prefixIcon: Icon(
                    Icons.code,
                    color: Colors.white,
                  ),
                  hintText: "Enter your commands here!",
                  hintStyle: TextStyle(
                    fontFamily: "courier new",
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => cmdText = value,
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    apiGuru(value);
                  }
                },
              ),
            ),
            SizedBox(
              height: 10,
            ),
            isThere
                ? body
                : Container(
                    alignment: Alignment.center,
                    height: MediaQuery.of(context).size.height * 0.79,
                    child: Text(
                      "Please, refresh terminal or execute a command...",
                      style: TextStyle(
                        fontFamily: "courier new",
                        color: const Color(0xffce6262),
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
