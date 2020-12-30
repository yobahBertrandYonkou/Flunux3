import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class CodeCards extends StatefulWidget {
  Map<String, dynamic> data;
  String date;

  CodeCards(Map<String, dynamic> data) {
    this.data = data;

    DateTime dateTime = data['date-time'].toDate();
    List<String> months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December"
    ];
    date =
        "${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year} at ${DateFormat.jms().format(dateTime)} UTC+5:30";
  }
  @override
  _CodeCardsState createState() => _CodeCardsState(data, date);
}

class _CodeCardsState extends State<CodeCards> {
  Map<String, dynamic> data;
  String exDate;
  _CodeCardsState(Map<String, dynamic> data, String exDate) {
    this.data = data;
    this.exDate = exDate;
  }
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: const Color(0xffce6262),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(5),
                  topRight: Radius.circular(5),
                ),
                border: Border.all(
                  color: Colors.redAccent,
                ),
              ),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Date      | $exDate",
                    style: TextStyle(
                      fontFamily: "courier new",
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Exit Code | ${data['command']['exit-code']}",
                    style: TextStyle(
                      fontFamily: "courier new",
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "UserID    | ${data['user-id']}",
                    style: TextStyle(
                      fontFamily: "courier new",
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              //height: 100,
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(5),
                  bottomRight: Radius.circular(5),
                ),
                border: Border.all(),
              ),
              child: Text(
                "\$ ${data['command']['cmd']}\n\n${data['command']['output']}",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: "courier new",
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
