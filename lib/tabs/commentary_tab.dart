// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:football_app/constants/constants.dart';
import 'package:football_app/models/comment_model.dart';
// import 'package:football_app/models/event_model.dart';
import 'package:http/http.dart' as http;

class CommentaryTab extends StatefulWidget {
  final int fixtureId;
  const CommentaryTab({
    super.key,
    required this.fixtureId,
  });

  @override
  State<CommentaryTab> createState() => _CommentaryTabState();
}

class _CommentaryTabState extends State<CommentaryTab> {
  late Future<Map<String, List<Comments>>> eventFuture;
  String? nullComment;

  int parseMinute(String minuteString, String? extraTime) {
    int mainMinute = int.tryParse(minuteString) ?? 0;
    int additionalMinute = extraTime != null ? int.tryParse(extraTime) ?? 0 : 0;

    return mainMinute * 100 + additionalMinute;
  }

  Future<Map<String, List<Comments>>> processCommentsById(int fixtureId) async {
    try {
      var response = await http.get(
        Uri.parse(
          '${Constants.baseUrl}/commentaries/fixtures/$fixtureId?include=player',
        ),
        headers: {
          'Authorization': Constants.apiToken,
        },
      );
      if (response.statusCode == 200) {
        final responseDecode = jsonDecode(response.body);

        final List<dynamic> commentList = (responseDecode['data'] as List)
            .map((json) => Comments.fromJson(json as Map<String, dynamic>))
            .toList();

        Map<String, List<Comments>> commentMap = {};

        final minuteList = [];

        for (var i = 0; i < 100; i++) {
          minuteList.add(i.toString());
        }

        // Sorting commentary by minute
        for (var comment in commentList) {
          if (!commentMap.containsKey(minuteList)) {
            commentMap[comment.minute.toString()] = [];
          }
          commentMap[comment.minute.toString()]!.add(comment);

          if (comment.minute == null) {
            nullComment = comment.comment;
          }
        }

        for (var eventsList in commentMap.values) {
          eventsList.sort((a, b) {
            int aTotalMinute =
                parseMinute(a.minute.toString(), a.extraMinute.toString());
            int bTotalMinute =
                parseMinute(b.minute.toString(), b.extraMinute.toString());
            return aTotalMinute.compareTo(bTotalMinute);
          });
        }
        print('Comments: $commentMap');
        return commentMap;
      }
    } on SocketException {
      print('No internet!');
      const snackBar = SnackBar(content: Text('No internet Connection!'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } on TimeoutException {
      print('No internet!');
      const snackBar = SnackBar(
          content: Text('No active internet connection to fetch data!'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } catch (e) {
      print('Error: $e');
    }

    return {};
  }

  @override
  void initState() {
    super.initState();
    eventFuture = processCommentsById(widget.fixtureId);
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
          child: FutureBuilder<Map<String, List<Comments>>>(
            future: eventFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Transform.scale(
                    scale: 0.6,
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
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text('No comments available!'),
                );
              } else {
                final comments = snapshot.data!.values
                    .expand((comments) => comments)
                    .toList();
                comments.sort((a, b) {
                  int aTotalMinute = parseMinute(
                      a.minute.toString(), a.extraMinute.toString());
                  int bTotalMinute = parseMinute(
                      b.minute.toString(), b.extraMinute.toString());
                  return aTotalMinute.compareTo(bTotalMinute);
                });

                List<Widget> commentWidget = [];

                for (var i = 0; i < comments.length; i++) {
                  final comment = comments[i];

                  commentWidget.add(
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 9.w),
                          child: Padding(
                            padding: EdgeInsets.only(
                              bottom: 10.h,
                            ),
                            child: Visibility(
                              visible: comment.minute == null ? false : true,
                              child: Container(
                                height: 100.h,
                                width: double.infinity,
                                decoration: const BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Color.fromRGBO(241, 241, 241, 1),
                                    ),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          height: 28,
                                          width: comment.extraMinute == 0
                                              ? 28
                                              : 55,
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 3.w,
                                          ),
                                          decoration: BoxDecoration(
                                            color: comment.isGoal
                                                ? Colors.green.shade500
                                                : comment.isImportant &&
                                                        !comment.comment
                                                            .contains(
                                                                'red card')
                                                    ? Colors.yellow.shade600
                                                    : comment.comment.contains(
                                                            'red card')
                                                        ? Colors.red
                                                        : Colors.black,
                                            borderRadius: BorderRadius.circular(
                                              5,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              comment.extraMinute != 0
                                                  ? '${comment.minute.toString()} + ${comment.extraMinute}\''
                                                  : '${comment.minute.toString()}\'',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10.w,
                                        ),
                                        Visibility(
                                          visible: comment.isGoal ||
                                                  comment.isImportant
                                              ? true
                                              : false,
                                          child: Text(
                                            comment.isGoal
                                                ? 'Goal!'
                                                : comment.comment
                                                        .contains('red card')
                                                    ? 'Red Card!'
                                                    : 'Foul!',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              color: comment.isGoal
                                                  ? Colors.green.shade500
                                                  : comment.comment
                                                          .contains('red card')
                                                      ? Colors.red
                                                      : Colors.yellow.shade700,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                    Text(
                                      comment.comment,
                                      style: const TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Visibility(
                          visible: i == comments.length - 1,
                          child: Container(
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Color.fromRGBO(241, 241, 241, 1),
                                ),
                              ),
                            ),
                            height: 40.h,
                            child: Center(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 9.w,
                                  ),
                                  child: Text(
                                    nullComment!,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: commentWidget.length,
                  physics: const BouncingScrollPhysics(),
                  // reverse: true,
                  itemBuilder: (context, index) {
                    return commentWidget[index];
                  },
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
