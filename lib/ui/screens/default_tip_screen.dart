import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zipapp/business/user.dart';
import 'package:zipapp/business/validator.dart';
import 'package:zipapp/constants/tailwind_colors.dart';
import 'package:zipapp/constants/zip_colors.dart';
import 'package:zipapp/constants/zip_design.dart';

class DefaultTipScreen extends StatefulWidget {
  const DefaultTipScreen({Key? key}) : super(key: key);

  @override
  State<DefaultTipScreen> createState() => DefaultTipScreenState();
}

class DefaultTipScreenState extends State<DefaultTipScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserService userService = UserService();
  double oldTipAmount = 20.0;
  double? newTipAmount;
  late bool hasChanged;
  final TextEditingController customTipController = TextEditingController();

  @override
  void initState() {
    super.initState();
    hasChanged = false;
    loadSavedTipAmount();
  }

  Future<void> loadSavedTipAmount() async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userService.userID).get();
      if (userDoc.exists && userDoc.data() != null) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        if (data.containsKey('defaultTip')) {
          setState(() {
            oldTipAmount = data['defaultTip'].toDouble();
          });
        }
      }
    } catch (e) {
      print("Error loading saved tip amount: $e");
    }
  }

  void updateDefaultTip(double newTip) {
    if (newTip != oldTipAmount && Validator.validateTipAmount(newTip)) {
      setState(() {
        newTipAmount = newTip;
        hasChanged = true;
      });
    } else {
      setState(() {
        hasChanged = false;
      });
    }
  }

  Future<void> saveChanges() async {
    if (hasChanged) {
      try {
        await _firestore.collection('users').doc(userService.userID).update({
          'defaultTip': newTipAmount,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Changes saved successfully')),
        );
        setState(() {
          hasChanged = false;
        });
      } catch (e) {
        print("Error saving changes: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save changes')),
        );
      }
    }
  }

  Widget percentageButton(double percentage) {
    bool isSelected =
        hasChanged ? newTipAmount == percentage : oldTipAmount == percentage;
    return ElevatedButton(
      onPressed: () {
        if (percentage == oldTipAmount) {
          setState(() {
            hasChanged = false;
          });
        }
        updateDefaultTip(percentage);
        customTipController.clear();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? ZipColors.zipYellow : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 20),
      ),
      child: Text(
        '$percentage%',
        style: ZipDesign.bodyText.copyWith(color: Colors.black, fontSize: 18),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Default Tip',
            style: ZipDesign.pageTitleText.copyWith(color: Colors.black)),
        backgroundColor: ZipColors.primaryBackground,
        titleSpacing: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          padding: const EdgeInsets.all(0),
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: ZipColors.primaryBackground,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current',
                style:
                    ZipDesign.sectionTitleText.copyWith(color: Colors.black)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${oldTipAmount.toStringAsFixed(2)}%',
                    style: ZipDesign.bodyText.copyWith(
                        color: TailwindColors
                            .gray500)), // Display tipAmount in dollars or percentage
                Text('Your average tip: \$3.40',
                    style: ZipDesign.bodyText
                        .copyWith(color: TailwindColors.gray500)),
              ],
            ),
            const SizedBox(height: 20),
            Text('\nSelect Percentage\n',
                style:
                    ZipDesign.sectionTitleText.copyWith(color: Colors.black)),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              childAspectRatio: 1.5 / 1.1,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              children: [5.0, 10.0, 15.0, 20.0, 25.0, 30.0]
                  .map((percentage) => percentageButton(percentage))
                  .toList(),
            ),
            const SizedBox(height: 20),
            Text('\nSelect Custom Amount',
                style:
                    ZipDesign.sectionTitleText.copyWith(color: Colors.black)),
            TextField(
              controller: customTipController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              onChanged: (value) {
                if (value.isNotEmpty &&
                    double.tryParse(value) != null &&
                    Validator.validateTipAmount(double.parse(value))) {
                  updateDefaultTip(double.parse(value));
                } else {
                  setState(() {
                    hasChanged = false;
                  });
                }
              },
              onSubmitted: (value) {
                if (!Validator.validateTipAmount(double.tryParse(value))) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Invalid tip percentage'),
                        content: const Text(
                          'Please enter a tip percentage between 0 and 100.',
                          style: ZipDesign.bodyText,
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('Ok'),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'Enter percentage...',
                hintStyle: ZipDesign.labelText.copyWith(color: Colors.black),
                suffixText: '%',
                enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: ZipColors.zipYellow)),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        height: 68,
        color: ZipColors.primaryBackground,
        surfaceTintColor: Colors.transparent,
        child: TextButton(
          onPressed: hasChanged
              ? () {
                  saveChanges();
                  Navigator.pop(context);
                }
              : null,
          style: hasChanged
              ? ZipDesign.yellowButtonStyle
              : ZipDesign.yellowButtonStyle.copyWith(
                  backgroundColor:
                      MaterialStateProperty.all(TailwindColors.gray300),
                ),
          child: Text(
            'Save Changes',
            style: hasChanged ? ZipDesign.bodyText : ZipDesign.disabledBodyText,
          ),
        ),
        // child: SafeArea(
        //   child: TextButton(
        //     style: TextButton.styleFrom(
        //       backgroundColor:
        //           hasChanged && Validator.validateTipAmount(newTipAmount)
        //               ? ZipColors.zipYellow
        //               : TailwindColors.gray300,
        //       minimumSize: const Size(double.infinity, 50),
        //       padding: const EdgeInsets.symmetric(vertical: 15),
        //     ),
        //     child: Text(
        //       'Save changes',
        //       style: TextStyle(
        //         color: hasChanged ? Colors.black : TailwindColors.gray500,
        //         fontSize: 18,
        //       ),
        //     ),
        //   ),
        // ),
      ),
    );
  }
}
