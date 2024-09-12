// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:football_app/constants/constants.dart';
import 'package:football_app/models/info_model.dart';
import 'package:http/http.dart' as http;

class MatchInfoTab extends StatefulWidget {
  final int fixtureId;
  const MatchInfoTab({
    super.key,
    required this.fixtureId,
  });

  @override
  State<MatchInfoTab> createState() => _MatchInfoTabState();
}

class _MatchInfoTabState extends State<MatchInfoTab> {
  late Future<Map<String, List<RefereeInfo>>> matchInfoFuture;
  late Future<Map<String, List<RefereeInfo>>> refFuture;
  String imagePath = '';
  String name = '';
  String city = '';
  int capacity = 0;
  int mainRefId = 0;

  Future<Map<String, List<RefereeInfo>>> processEventInfoById(
      int fixtureId) async {
    try {
      var response = await http.get(
        Uri.parse(
          '${Constants.baseUrl}/fixtures/$fixtureId?include=venue;referees',
        ),
        headers: {
          'Authorization': Constants.apiToken,
        },
      );

      if (response.statusCode == 200) {
        final venueJson = jsonDecode(response.body);

        // print(venueJson);

        final image = venueJson['data']['venue']['image_path'];
        final venueName = venueJson['data']['venue']['name'];
        final cityName = venueJson['data']['venue']['city_name'];
        final venueCapacity = venueJson['data']['venue']['capacity'];

        setState(() {
          imagePath = image;
          name = venueName;
          capacity = venueCapacity;
          city = cityName;
        });

        final List<dynamic> refereeList = (venueJson['data']['referees']
                as List)
            .map((json) => RefereeInfo.fromJson(json as Map<String, dynamic>))
            .toList();

        for (var referee in refereeList) {
          int refTypeId = referee.typeId;
          if (refTypeId == 6) {
            setState(() {
              mainRefId = referee.refereeId;
            });
          }
        }
      }
    } catch (e) {}

    return {};
  }

  Future<Map<String, List<RefereeInfo>>> getReferees(int refereeId) async {
    try {
      var response = await http.get(
        Uri.parse(
          'https://api.sportmonks.com/v3/football/referees/$refereeId',
        ),
        headers: {
          'Authorization': Constants.apiToken,
        },
      );

      if (response.statusCode == 200) {
        final refereeJson = jsonDecode(response.body);

        print('Ref: $refereeJson');

        // final List<dynamic> venueList = (venueJson['data'] as List)
        //     .map((json) => MatchInfo.fromJson(json as Map<String, dynamic>))
        //     .toList();

        // print('VenueList : $venueList');
      }
    } catch (e) {}

    return {};
  }

  @override
  void initState() {
    super.initState();
    matchInfoFuture = processEventInfoById(widget.fixtureId);
    refFuture = getReferees(mainRefId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 7.w,
          vertical: 5.h,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 150.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8.r),
                    topRight: Radius.circular(8.r),
                  ),
                  color: Colors.grey.shade200,
                  image: DecorationImage(
                    image: NetworkImage(
                      imagePath,
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(
                height: 10.h,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 15.w,
                ),
                child: Row(
                  children: [
                    Text(
                      '$name,',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      width: 4.w,
                    ),
                    Text(
                      city,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 8.h,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 15.w,
                ),
                child: Text(
                  'Capacity: ${capacity.toString()}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
