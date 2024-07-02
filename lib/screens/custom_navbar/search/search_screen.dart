import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:terra_zero_waste_app/constants/app_assets.dart';
import 'package:terra_zero_waste_app/constants/app_text_styles.dart';
import 'package:terra_zero_waste_app/controllers/user_controller.dart';
import 'package:terra_zero_waste_app/models/user_model.dart';
import 'package:terra_zero_waste_app/screens/custom_navbar/search/widgets/user_search_card.dart';
import 'package:terra_zero_waste_app/widgets/text_inputs.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final userController = Provider.of<UserController>(context);
    return Scaffold(
      backgroundColor: Colors.white, // Set the background color to white
      resizeToAvoidBottomInset: true,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Column(
          children: [
            SizedBox(height: 20.h), // Adjust the height as needed
            SearchTextInput(
              controller: _searchController,
              onChange: (v) {
                setState(() {});
              },
            ),
            Expanded(
              child: _searchController.text.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 150.h,
                            child: Image.asset('lib/assets/gif_icons/search_icon.gif'),
                          ),
                          SizedBox(height: 20.h),
                          Text(
                            "Search User",
                            style: AppTextStyles.nunitoBold.copyWith(fontSize: 18), // Make text smaller
                          ),
                          SizedBox(height: 10.h), // Add space between the text and the description
                          Text(
                            "Use the search bar above to find users by their username.",
                            style: AppTextStyles.nunitoRegular.copyWith(fontSize: 14), // Make text smaller
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: userController.allUserList.length,
                      itemBuilder: (context, index) {
                        UserModel userModel = userController.allUserList[index];
                        if (userModel.username.toLowerCase().contains(_searchController.text.toLowerCase())) {
                          return UserSearchCard(userModel: userModel);
                        } else {
                          return SizedBox();
                        }
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
