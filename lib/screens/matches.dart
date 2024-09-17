// class Fixture {
//   final Fixture fixture;
//   final Team home;
//   final Team away;
//   // final Status status;
//   final Goal goal;
//   final League league;

//   Fixture({
//     required this.fixture,
//     required this.home,
//     required this.away,
//     // required this.status,
//     required this.goal,
//     required this.league,
//   });

//   factory Fixture.fromJson(Map<String, dynamic> json) {
//     return Fixture(
//       fixture: Fixture.fromJson(json['fixture']),
//       home: Team.fromJson(json['teams']['home']),
//       away: Team.fromJson(json['teams']['away']),
//       // status: Status.fromJson(json['status']),
//       goal: Goal.fromJson(json['goals']),
//       league: League.fromJson(json['league']),
//     );
//   }
// }

// class Fixture {
//   final int id;
//   final DateTime date;
//   final Status status;

//   Fixture(this.id, this.date, this.status);

//   factory Fixture.fromJson(Map<String, dynamic> json) {
//     return Fixture(json['id'], DateTime.parse(json['date']).toLocal(), Status.fromJson(json['status']));
//   }
// }

// class Team {
//   final int id;
//   final String name;
//   final String logo;
//   final bool? winner;

//   Team(this.id, this.name,  this.logo, this.winner);

//   factory Team.fromJson(Map<String, dynamic> json) {
//     return Team(json['id'], json['name'], json['logo'], json['winner']);
//   }
// }

// class Status {
//   final String long;
//   final String short;
//   final int? elapsed;

//   Status(this.long, this.short, this.elapsed);

//   factory Status.fromJson(Map<String, dynamic> json) {
//     return Status(
//       json['long'],
//       json['short'],
//       json['elapsed'],
//     );
//   }
// }

// class Goal {
//   final int? home;
//   final int? away;

//   Goal(this.home, this.away);

//   factory Goal.fromJson(Map<String, dynamic> json) {
//     return Goal(
//      json['home'],
//      json['away']
//     );
//   }
// }

// class League {
//   final String round;

//   League(this.round);

//   factory League.fromJson(Map<String, dynamic> json) {
//     return League(json['round']);
//   }
// }

// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:football_app/constants/constants.dart';
import 'package:football_app/models/fixture_model.dart';
import 'package:football_app/models/timer_model.dart';
import 'package:football_app/pages/match_details.dart';
import 'package:football_app/utils/match_tile.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
// import 'package:pull_to_refresh/pull_to_refresh.dart';

class Matches extends StatefulWidget {
  const Matches({Key? key}) : super(key: key);

  @override
  State<Matches> createState() => _MatchesState();
}

class _MatchesState extends State<Matches> {
  // List<String> dates = [];
  Timer? _timer;
  Map<String, List<Fixture>> fixturesByDate = {};
  Map<String, List<String>> leagueFixtureName = {};
  Map<String, List<Fixture>> groupedFixtures = {};
  late bool _isConnected = false;
  var defaultDate = DateTime.parse('2024-09-16');
  late Future<Map<String, List<Fixture>>> fixturesFuture;
  late Future<Map<String, List<Fixture>>>? updatedFixturesFuture;
  late StreamSubscription<ConnectivityResult> connectivitySubscription;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    fixturesFuture = processFixtures(defaultDate);
    // updatedFixturesFuture = updatedFixtures();
    _checkConnectivity();
    connectivitySubscription =
        Connectivity().onConnectivityChanged.listen(_updateConnectionStatus);
    // Schedule a timer to refresh data every minute
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (_isConnected) {
        _triggerRefresh();
      } else {
        _showSnackBar();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    connectivitySubscription.cancel();
    super.dispose();
  }

  void _checkConnectivity() async {
    ConnectivityResult result = await Connectivity().checkConnectivity();
    _updateConnectionStatus(result);

    // updateDates();
  }

  Future<Map<String, List<Fixture>>> _updateConnectionStatus(
      ConnectivityResult result) {
    setState(() {
      _isConnected = result != ConnectivityResult.none;
      if (_isConnected) {
        // fixturesFuture = processFixtures(defaultDate);
      } else {
        _showSnackBar();
      }
    });
    return fixturesFuture;
  }

  void _showSnackBar() {
    const snackBar = SnackBar(
      content: Text('Please check your internet connection and try again!'),
      duration: Duration(seconds: 3),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> _triggerRefresh() async {
    if (_refreshIndicatorKey.currentState != null) {
      _refreshIndicatorKey.currentState!.show();
      // updatedFixturesFuture = updatedFixtures();
    }
  }

  Future<void> _handleRefresh() async {
    if (_isConnected) {
      setState(() {
        // updatedFixturesFuture = updatedFixtures();
      });
    } else {
      _showSnackBar();
    }
  }

  Future<Map<String, List<Fixture>>> processFixtures(DateTime date) async {
    // await Future.delayed(const Duration(seconds: 2));
    try {
      var response = await http.get(
        Uri.parse(
            '${Constants.baseUrl}/fixtures/date/${DateFormat('yyyy-MM-dd').format(date)}?include=league;participants;scores.participant'),
        headers: {
          'Authorization': Constants.apiToken,
        },
      );
      if (response.statusCode == 200) {
        final responseDecode = jsonDecode(response.body);
        log(responseDecode.toString());
        final List<dynamic> fixtures = responseDecode['data']
            .map((fixture) => Fixture.fromJson(fixture as Map<String, dynamic>))
            .toList();

        for (var fixture in fixtures) {
          defaultDate = DateTime.parse(fixture.startingAt);
          final fixtureDate = defaultDate.toString().split(' ').first;
          if (!fixturesByDate.containsKey(fixtureDate)) {
            fixturesByDate[fixtureDate] = [];
          }
          setState(() {
            fixturesByDate[fixtureDate]!.add(fixture);
          });
          print(fixturesByDate[fixtureDate]);
        }

        //   for (var fixture in allFixtures) {
        //     final fixtureDate = dateGotten.toString().split(' ').first;
        //     if (!fixturesByDate.containsKey(fixtureDate)) {
        //       fixturesByDate[fixtureDate] = [];
        //     }
        //     fixturesByDate[fixtureDate]!.add(fixture);
        //   }
      }
    } on SocketException {
      // final snackBar = SnackBar(content: Text('No internet'));
      // ScaffoldMessenger.of(context).showSnackBar(snackBar);
      print('No internet!');
    } catch (e) {
      print('error: $e');
    }
    return fixturesByDate;
  }

  Future<Map<String, List<Fixture>>> updatedFixtures() async {
    // await Future.delayed(const Duration(seconds: 2));
    try {
      var response = await http.get(
        Uri.parse('${Constants.baseUrl}/fixtures/latest'),
        headers: {
          'Authorization': Constants.apiToken,
        },
      );
      if (response.statusCode == 200) {
        final responseDecode = jsonDecode(response.body);
        print(responseDecode);
        // final List<dynamic> fixtures = responseDecode['data']
        //     .map((fixture) => Fixture.fromJson(fixture as Map<String, dynamic>))
        //     .toList();

        // for (var fixture in fixtures) {
        //   defaultDate = DateTime.parse(fixture.startingAt);
        //   final fixtureDate = defaultDate.toString().split(' ').first;
        //   if (!fixturesByDate.containsKey(fixtureDate)) {
        //     fixturesByDate[fixtureDate] = [];
        //   }
        //   setState(() {
        //     fixturesByDate[fixtureDate]!.add(fixture);
        //   });
        //   print(fixturesByDate[fixtureDate]);
        // }

        //   for (var fixture in allFixtures) {
        //     final fixtureDate = dateGotten.toString().split(' ').first;
        //     if (!fixturesByDate.containsKey(fixtureDate)) {
        //       fixturesByDate[fixtureDate] = [];
        //     }
        //     fixturesByDate[fixtureDate]!.add(fixture);
        //   }
      }
    } on SocketException {
      // final snackBar = SnackBar(content: Text('No internet'));
      // ScaffoldMessenger.of(context).showSnackBar(snackBar);
      print('No internet!');
    } catch (e) {
      print('error: $e');
    }
    return fixturesByDate;
  }

  // void updateDates() {
  //   DateTime now = DateTime.now();
  //   for (var i = 0; i < 5; i++) {
  //     dates.add(now.add(Duration(days: i)));
  //   }
  //   if (_isConnected) {
  //     fetchFixturesForDates(dates);
  //   }
  // }

  // void fetchFixturesForDates(List<DateTime> dates) async {
  //   for (var date in dates) {
  //     // String formattedDate = DateFormat('yyyy-MM-dd').format(date);
  //     try {
  //       var response = await http.get(
  //         Uri.parse(
  //             '${Constants.baseUrl}/fixtures/date/2024-05-15?include=league;participants;scores'),
  //         headers: {
  //           'Authorization': Constants.apiToken,
  //         },
  //       );
  //       print('Response: ${response.body}');

  //       if (response.statusCode == 200) {
  //         final responseBody = jsonDecode(response.body);
  //         final fixtureData = responseBody['data'] as List<dynamic>;
  //         if (fixtureData.isEmpty) return null;
  //         for (var fixtureMap in fixtureData) {
  //           final leagueMap = fixtureMap['league'] as Map<String, dynamic>;
  //           if (leagueMap.isNotEmpty) {
  //             setState(() {
  //               leagueNames.add(leagueMap['name'] as String);
  //             });
  //           }
  //         }
  //       } else {
  //         print('Not Connecting!');
  //       }
  //     } catch (e) {
  //       print('error');
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final dates = fixturesByDate.keys.toList();
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: _isConnected ? Colors.white : Colors.grey.shade100,
        toolbarHeight: 0,
      ),
      body: SafeArea(
        child: DefaultTabController(
          length: dates.length,
          child: Column(
            children: [
              Container(
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 8.h,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // text
                      const Text(
                        'JustFootball!',
                        style: TextStyle(
                          fontFamily: 'SpaceGrotesk',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Iconsax.calendar_1,
                            size: 20,
                          ),
                          SizedBox(
                            width: 20.w,
                          ),
                          const Icon(
                            Iconsax.setting_2,
                            size: 20,
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                color: Colors.white,
                height: 50.h,
                child: TabBar(
                  indicatorColor: Colors.black,
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey.shade700,
                  labelStyle: const TextStyle(
                    color: Colors.black,
                    fontFamily: 'UberMove',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  unselectedLabelStyle: TextStyle(
                    color: Colors.grey.shade700,
                    fontFamily: 'UberMove',
                    fontWeight: FontWeight.normal,
                  ),
                  tabAlignment: TabAlignment.start,
                  isScrollable: true,
                  tabs: dates.map((date) {
                    return Container(
                      width: 70.w, // Set a fixed width for each tab
                      alignment: Alignment.center,
                      child: Text(
                        toDate(DateTime.parse(date)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                ),
              ),
              Expanded(
                child: FutureBuilder<Map<String, List<Fixture>>>(
                  future: fixturesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: Transform.scale(
                          scale: 0.8,
                          child: CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 2.5.w,
                          ),
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    } else if (snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text('No fixtures'),
                      );
                    } else if (snapshot.hasData) {
                      final fixturesByDate = snapshot.data!;
                      final dates = fixturesByDate.keys.toList();
                      return TabBarView(
                        children: dates.map((date) {
                          // final league = entry.key;
                          final fixtures = fixturesByDate[date] ?? [];
                          for (var fixture in fixtures) {
                            if (groupedFixtures
                                .containsKey(fixture.league.name)) {
                              groupedFixtures[fixture.league.name]!
                                  .add(fixture);
                            } else {
                              groupedFixtures[fixture.league.name] = [fixture];
                            }
                          }
                          return Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20.w, vertical: 10.h),
                            child: RefreshIndicator(
                              key: _refreshIndicatorKey,
                              onRefresh: _handleRefresh,
                              child: ListView.builder(
                                physics: const ClampingScrollPhysics(),
                                itemCount: groupedFixtures.keys.length,
                                itemBuilder: (context, index) {
                                  final leagueName =
                                      groupedFixtures.keys.elementAt(index);
                                  Set<Fixture> fixtures =
                                      groupedFixtures[leagueName]!.toSet();

                                  var list = <Fixture>{};

                                  Set<Fixture> uniqueList = fixtures
                                      .where((fixture) => list.add(fixture))
                                      .toList()
                                      .toSet();
                                  String leagueImagePath =
                                      fixtures.first.league.imagePath;
                                  String leagueCode =
                                      fixtures.first.league.shortCode;
                                  // final participants =
                                  //     teamDetails[leagueName]!;
                                  // final fixtureNames =
                                  //     leagueFixtureName[leagueName]!;
                                  // final leagueImage =
                                  //     leagueImages[leagueName]!;
                                  // final leagueCode =
                                  //     leagueCodes[leagueName]!;
                                  // return MatchTile(image: leagueImage);
                                  return Padding(
                                    padding: EdgeInsets.only(bottom: 10.h),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(10.r),
                                        // boxShadow: [
                                        //   BoxShadow(
                                        //     spreadRadius: 1,
                                        //     offset: Offset(0, 1),
                                        //     blurStyle: BlurStyle.normal,
                                        //     color: Colors.black87,
                                        //   )
                                        // ],
                                      ),
                                      child: Theme(
                                        data: Theme.of(context).copyWith(
                                          dividerColor: Colors.transparent,
                                        ),
                                        child: Consumer<TimerModel>(
                                          builder: (context, model, child) =>
                                              ExpansionTile(
                                            backgroundColor: Colors.white,
                                            collapsedShape:
                                                RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.r),
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.r),
                                            ),
                                            leading: Image.network(
                                              leagueImagePath,
                                              height: 20,
                                              width: 25,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return const Icon(
                                                  Icons.circle_rounded,
                                                );
                                              },
                                            ),
                                            title: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      leagueName,
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    Text(
                                                      leagueCode,
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors
                                                            .grey.shade700,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                // Text('Live')
                                              ],
                                            ),
                                            children: uniqueList
                                                .map((fixture) {
                                                  Participants? homeTeam;
                                                  Participants? awayTeam;

                                                  // Get fixture starting time
                                                  DateTime fixtureStartingAt =
                                                      DateTime.parse(fixture
                                                              .startingAt)
                                                          .toLocal();
                                                  final DateTime now =
                                                      DateTime.now();
                                                  final Duration elapsed =
                                                      now.difference(
                                                          fixtureStartingAt);
                                                  final int elapsedMinutes =
                                                      elapsed.inMinutes;
                                                  String length;

                                                  // Check if match is full-time, halftime, or running
                                                  if (elapsedMinutes >= 90) {
                                                    length = "FT";
                                                    Provider.of<TimerModel>(
                                                            context,
                                                            listen: false)
                                                        .stopTimer(fixture.id
                                                            .toString());
                                                  } else if (elapsedMinutes >=
                                                          45 &&
                                                      elapsedMinutes < 60) {
                                                    length = "HT"; // Halftime
                                                  } else if (elapsedMinutes <
                                                      45) {
                                                    length =
                                                        "$elapsedMinutes'"; // First half
                                                    Provider.of<TimerModel>(
                                                            context,
                                                            listen: false)
                                                        .startRealTimeTimer(
                                                            fixture);
                                                  } else if (elapsedMinutes >=
                                                          60 &&
                                                      elapsedMinutes < 90) {
                                                    length =
                                                        "${elapsedMinutes - 15}'"; // Second half accounting for halftime break
                                                    Provider.of<TimerModel>(
                                                            context,
                                                            listen: false)
                                                        .resumeTimer(fixture.id
                                                            .toString());
                                                  } else if (elapsedMinutes >
                                                      90) {
                                                    final int extraTimeMinutes =
                                                        elapsedMinutes - 90;
                                                    length =
                                                        "90+${extraTimeMinutes}'"; // Extra time
                                                  } else {
                                                    length = 'N/A';
                                                  }

                                                  // Handle Halftime (HT) if already set
                                                  if (model.isHalfTime[fixture
                                                          .id
                                                          .toString()] ??
                                                      false) {
                                                    length = 'HT';
                                                  }

                                                  final splitName =
                                                      fixture.name.split('vs');
                                                  for (var participant
                                                      in fixture.participants) {
                                                    if (participant
                                                            .meta.location ==
                                                        'home') {
                                                      homeTeam = participant;
                                                    } else {
                                                      awayTeam = participant;
                                                    }
                                                  }
                                                  // final homeTeam = fixture
                                                  //     .participants[0];
                                                  // final awayTeam = fixture
                                                  //     .participants[1];

                                                  String?
                                                      getParticipantImagePath(
                                                          String teamName,
                                                          List<Participants>
                                                              participants) {
                                                    for (var participant
                                                        in participants) {
                                                      if (participant.name
                                                          .toLowerCase()
                                                          .contains(teamName
                                                              .toLowerCase())) {
                                                        return participant
                                                                .imagePath
                                                                .isNotEmpty
                                                            ? participant
                                                                .imagePath
                                                            : 'https://www.istockphoto.com/photo/white-paper-background-gm1296466196-389873536';
                                                      }
                                                    }
                                                    return 'https://www.istockphoto.com/photo/white-paper-background-gm1296466196-389873536';
                                                  }

                                                  int getGoalsScored(
                                                      int participantId,
                                                      List<Scores> scores) {
                                                    for (var score in scores) {
                                                      if (score.participantId ==
                                                              participantId &&
                                                          (score.description ==
                                                              'CURRENT')) {
                                                        return score.goals;
                                                      }
                                                    }
                                                    return 0;
                                                  }

                                                  final homeTeamName =
                                                      splitName[0].trim();
                                                  final awayTeamName =
                                                      splitName[1].trim();

                                                  return MatchTile(
                                                    dateTime: DateTime.now(),
                                                    fixtureTime: DateTime.parse(
                                                        fixture.startingAt),
                                                    length: length,
                                                    // color: Colors.grey,
                                                    homeTeamLogo:
                                                        getParticipantImagePath(
                                                                homeTeamName,
                                                                fixture
                                                                    .participants) ??
                                                            '',
                                                    homeTeamName: homeTeamName,
                                                    awayTeamLogo:
                                                        getParticipantImagePath(
                                                                awayTeamName,
                                                                fixture
                                                                    .participants) ??
                                                            '',
                                                    awayTeamName: awayTeamName,
                                                    homeTeamScore:
                                                        getGoalsScored(
                                                            homeTeam!.id,
                                                            fixture.scores),
                                                    awayTeamScore:
                                                        getGoalsScored(
                                                            awayTeam!.id,
                                                            fixture.scores),
                                                    onTap: () {
                                                      Navigator.push(
                                                          context,
                                                          PageRouteBuilder(
                                                            transitionDuration:
                                                                const Duration(
                                                                    milliseconds:
                                                                        500),
                                                            transitionsBuilder:
                                                                (context,
                                                                    animation,
                                                                    secondaryAnimation,
                                                                    child) {
                                                              return SlideTransition(
                                                                position: Tween<
                                                                    Offset>(
                                                                  begin:
                                                                      const Offset(
                                                                          1, 0),
                                                                  end: Offset
                                                                      .zero,
                                                                ).animate(
                                                                  CurvedAnimation(
                                                                    parent:
                                                                        animation,
                                                                    curve: Curves
                                                                        .easeInOut,
                                                                  ),
                                                                ),
                                                                child: child,
                                                              );
                                                            },
                                                            pageBuilder: (context,
                                                                animation,
                                                                secondaryAnimation) {
                                                              return MatchDetails(
                                                                homeTeamLogo: getParticipantImagePath(
                                                                        homeTeamName,
                                                                        fixture
                                                                            .participants) ??
                                                                    '',
                                                                homeScore:
                                                                    getGoalsScored(
                                                                        homeTeam!
                                                                            .id,
                                                                        fixture
                                                                            .scores),
                                                                awayTeamLogo: getParticipantImagePath(
                                                                        awayTeamName,
                                                                        fixture
                                                                            .participants) ??
                                                                    '',
                                                                awayScore:
                                                                    getGoalsScored(
                                                                        awayTeam!
                                                                            .id,
                                                                        fixture
                                                                            .scores),
                                                                homeTeamName:
                                                                    homeTeamName,
                                                                awayTeamName:
                                                                    awayTeamName,
                                                                fixtureId:
                                                                    fixture.id,
                                                                homeTeamId:
                                                                    homeTeam.id,
                                                                awayTeamId:
                                                                    awayTeam.id,
                                                              );
                                                            },
                                                          ));
                                                    },
                                                  );
                                                })
                                                .toSet()
                                                .toList(),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    } else {
                      return const Center(
                        child: Text('No data available!'),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String toDate(DateTime dateTime) {
    return DateFormat('E, MMM d').format(dateTime);
  }

  String toTime(DateTime dateTime) {
    DateTime oneHourAhead = dateTime.add(const Duration(hours: 1));
    return DateFormat('hh:mm a').format(oneHourAhead.toLocal());
  }
}
