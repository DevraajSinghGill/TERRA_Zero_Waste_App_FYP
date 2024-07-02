import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../constants/app_colors.dart';
import '../../../../constants/app_text_styles.dart';
import '../../../../models/comment_model.dart';

class CommentCard extends StatefulWidget {
  final CommentModel commentModel;
  final String commentId;
  const CommentCard({super.key, required this.commentModel, required this.commentId});

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  final TextEditingController commentController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        widget.commentModel.userId == FirebaseAuth.instance.currentUser!.uid
            ? Slidable(
                key: const ValueKey(0),
                startActionPane: ActionPane(
                  motion: const ScrollMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (v) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Delete'),
                              content: const Text('Are you sure you want to delete?'),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text('Cancel'),
                                  onPressed: () {
                                    Get.back();
                                  },
                                ),
                                TextButton(
                                  child: const Text('Delete'),
                                  onPressed: () async {
                                    await FirebaseFirestore.instance
                                        .collection('posts')
                                        .doc(widget.commentModel.postId)
                                        .collection('comments')
                                        .doc(widget.commentId)
                                        .delete()
                                        .then((v) {
                                      Get.back();
                                    });
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      backgroundColor: const Color(0xFFFE4A49),
                      foregroundColor: Colors.white,
                      icon: Icons.delete,
                      label: 'Delete',
                    ),
                    SlidableAction(
                      onPressed: (v) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Update'),
                              content: TextField(
                                controller: commentController,
                                decoration: InputDecoration(hintText: widget.commentModel.comment),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text('Cancel'),
                                  onPressed: () {
                                    Get.back();
                                  },
                                ),
                                TextButton(
                                  child: const Text('Update'),
                                  onPressed: () async {
                                    await FirebaseFirestore.instance
                                        .collection('posts')
                                        .doc(widget.commentModel.postId)
                                        .collection('comments')
                                        .doc(widget.commentId)
                                        .update({"comment": commentController.text}).then((v) {
                                      Get.back();
                                    });
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      backgroundColor: const Color(0xFF21B7CA),
                      foregroundColor: Colors.white,
                      icon: Icons.edit,
                      label: 'Edit',
                    ),
                  ],
                ),
                child: ListTile(
                  leading: widget.commentModel.userImage == ""
                      ? CircleAvatar(
                          radius: 22.r,
                          backgroundColor: AppColors.primaryBlack,
                          child: Text(widget.commentModel.username[0].toUpperCase()),
                        )
                      : CircleAvatar(
                          radius: 22.r,
                          backgroundImage: NetworkImage(widget.commentModel.userImage),
                        ),
                  title: Text(widget.commentModel.username, style: AppTextStyles.nunitoBold.copyWith(fontSize: 14)),
                  subtitle: Text(widget.commentModel.comment, style: AppTextStyles.nunitoSemiBod.copyWith(fontSize: 12)),
                  trailing: Text(
                    timeago.format(widget.commentModel.commentTime),
                    style: const TextStyle(
                      fontSize: 10,
                    ),
                  ),
                ),
              )
            : ListTile(
                leading: widget.commentModel.userImage == ""
                    ? CircleAvatar(
                        radius: 22.r,
                        backgroundColor: AppColors.primaryBlack,
                        child: Text(widget.commentModel.username[0].toUpperCase()),
                      )
                    : CircleAvatar(
                        radius: 22.r,
                        backgroundImage: NetworkImage(widget.commentModel.userImage),
                      ),
                title: Text(widget.commentModel.username, style: AppTextStyles.nunitoBold.copyWith(fontSize: 14)),
                subtitle: Text(widget.commentModel.comment, style: AppTextStyles.nunitoSemiBod.copyWith(fontSize: 12)),
                trailing: Text(
                  timeago.format(widget.commentModel.commentTime),
                  style: const TextStyle(
                    fontSize: 10,
                  ),
                ),
              ),
        const Divider(thickness: 0.5, height: 0.2),
      ],
    );
  }
}
