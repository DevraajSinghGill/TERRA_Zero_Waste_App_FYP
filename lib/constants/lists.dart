import 'package:terra_zero_waste_app/screens/custom_navbar/add_post/add_post_screen.dart';
import 'package:terra_zero_waste_app/screens/custom_navbar/chat/user_chat_list_screen.dart';
import 'package:terra_zero_waste_app/screens/custom_navbar/home/home_screen.dart';
import 'package:terra_zero_waste_app/screens/custom_navbar/profile/profile_screen.dart';
import 'package:terra_zero_waste_app/screens/custom_navbar/search/search_screen.dart';

List screensList = [
  HomeScreen(),
  SearchScreen(),
  AddPostScreen(),
  UserChatListScreen(),
  ProfileScreen(),
];

List<String> profileScreenToggleList = [
  "Posts",
  "Following",
  "Followers",
];
