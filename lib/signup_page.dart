import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SignUp extends StatelessWidget {
  SignUp({Key? key}) : super(key: key);

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController dateOfBirthController = TextEditingController();
  final TextEditingController edittextController = TextEditingController();
  final TextEditingController edittextoneController = TextEditingController();
  final TextEditingController edittexttwoController = TextEditingController();
  final TextEditingController edittextthreeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          width: double.maxFinite,
          padding: EdgeInsets.symmetric(horizontal: 41),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 39),
              GestureDetector(
                onTap: () {
                  backToLogin(context);
                },
                child: Image.asset(
                  'assets/images/backArrow.png',
                  height: 32,
                  width: 32,
                ),
              ),
              SizedBox(height: 20),
              Container(
                width: 100,
                margin: EdgeInsets.only(left: 50, right: 53),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Register\n",
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w700,
                          fontSize: 30.0,
                          color: Color.fromRGBO(255, 255, 255, 1)
                        ),
                      ),
                      TextSpan(
                        text: "Enter your personal information",
                        style: TextStyle(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w300,
                        fontSize: 14.0,
                        color: Color.fromRGBO(255, 255, 255, 1),
                        )
                      ),
                    ],
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
              SizedBox(height: 7),
              _buildFullNameSection(context),
              SizedBox(height: 19),
              _buildDateOfBirthSection(context),
              SizedBox(height: 5),
              _buildGenderSection(context),
              SizedBox(height: 14),
              _buildBloodTypeSection(context),
              SizedBox(height: 14),
              _buildAllergiesSection(context),
              SizedBox(height: 12),
              _buildCurrentMedicationSection(context),
              SizedBox(height: 26),
              CustomOutlinedButton(
                width: 17,
                text: 'Sign in',
                alignment: Alignment.center,
              ),
              SizedBox(height: 10),
              Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: 10,
                  child: Divider(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFullNameSection(BuildContext context) {
  return Container(
    margin: EdgeInsets.only(right: 24),
    padding: EdgeInsets.symmetric(horizontal: 1),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 22),
          child: Text(
            "Full Name",
            style: TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w400,
              fontSize: 16.0,
              color: Color.fromRGBO(255, 255, 255, 1),
            ),
          ),
        ),
        SizedBox(height: 6),
        Padding(
          padding: EdgeInsets.only(left: 22),
          child: Container(
            width: 200,
            child: CustomTextFormField(
              controller: fullNameController,
              alignment: Alignment.centerRight,
            ),
          ),
        ),
      ],
    ),
  );
}


  Widget _buildDateOfBirthSection(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 24),
      padding: EdgeInsets.symmetric(horizontal: 1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 22),
            child: Text(
              "Date of Birth",
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          SizedBox(height: 6),
          Padding(
            padding: EdgeInsets.only(left: 22),
            child: CustomTextFormField(
              controller: dateOfBirthController,
              alignment: Alignment.centerRight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderSection(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 24),
      padding: EdgeInsets.symmetric(horizontal: 1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 22),
            child: Text(
              "Gender",
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          SizedBox(height: 6),
          Padding(
            padding: EdgeInsets.only(left: 22),
            child: CustomTextFormField(
              controller: edittextController,
              alignment: Alignment.centerRight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBloodTypeSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 22),
            child: Text(
              "Blood Type",
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          SizedBox(height: 4),
          Padding(
            padding: EdgeInsets.only(left: 22),
            child: CustomTextFormField(
              controller: edittextoneController,
              alignment: Alignment.centerRight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllergiesSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 22),
            child: Text(
              "Allergies",
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          SizedBox(height: 4),
          Padding(
            padding: EdgeInsets.only(left: 22),
            child: CustomTextFormField(
              controller: edittexttwoController,
              alignment: Alignment.centerRight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentMedicationSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 22),
            child: Text(
              "Current Medication",
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          SizedBox(height: 6),
          Padding(
            padding: EdgeInsets.only(left: 22),
            child: CustomTextFormField(
              controller: edittextthreeController,
              textInputAction: TextInputAction.done,
              alignment: Alignment.centerRight,
            ),
          ),
        ],
      ),
    );
  }

  void backToLogin(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.loginPageScreen);
  }
}

class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final TextInputAction textInputAction;
  final Alignment alignment;

  CustomTextFormField({
    required this.controller,
    this.textInputAction = TextInputAction.next,
    this.alignment = Alignment.centerLeft,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textInputAction: textInputAction,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
      ),
    );
  }
}


class CustomOutlinedButton extends StatelessWidget {
  final double width;
  final String text;
  final Alignment alignment;

  CustomOutlinedButton({
    required this.width,
    required this.text,
    required this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: OutlinedButton(
        onPressed: () {},
        child: Text(text),
      ),
    );
  }
}


class AppRoutes {
  static const loginPageScreen = '/login';
}
