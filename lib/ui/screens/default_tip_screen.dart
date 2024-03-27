import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zipapp/business/user.dart';
import 'package:zipapp/business/validator.dart';
import 'package:zipapp/constants/zip_colors.dart';
import 'package:zipapp/constants/zip_design.dart';

class DefaultTipScreen extends StatefulWidget {
  const DefaultTipScreen({Key? key}) : super(key: key);

  @override
  State<DefaultTipScreen> createState() => DefaultTipScreenState();
}

class DefaultTipScreenState extends State<DefaultTipScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  UserService userService = UserService();
  late double tipAmount;
  bool hasChanged = false;

  @override
  void initState() {
    super.initState();
    tipAmount = 20.0;
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
            tipAmount = data['defaultTip'].toDouble();
          });
        }
      }
    } catch (e) {
      print("Error loading saved tip amount: $e");
    }
  }

  void updateDefaultTip(double newTip) {
    if (newTip != tipAmount && Validator.validateTipAmount(newTip)) {
      setState(() {
        tipAmount = newTip;
        hasChanged = true;
      });
    }
  }

  Future<void> saveChanges() async {
    if (hasChanged) {
      try {
        await _firestore.collection('users').doc(userService.userID).update({
          'defaultTip': tipAmount,
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

  Widget percentageButton(String percentage) {
    bool isSelected = tipAmount == double.tryParse(percentage);
    return ElevatedButton(
      onPressed: () => updateDefaultTip(double.parse(percentage)),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? ZipColors.zipYellow : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 20),
      ),
      child: Text(
        '$percentage%',
        style: ZipDesign.bodyText.copyWith(
            color: isSelected ? Colors.black : Colors.grey, fontSize: 18),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () => Navigator.pop(context)),
        title: Text('Default Tip',
            style: ZipDesign.pageTitleText.copyWith(color: Colors.black)),
        backgroundColor: ZipColors.primaryBackground,
        elevation: 0,
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
                Text('${tipAmount.toStringAsFixed(2)}%',
                    style: ZipDesign.bodyText.copyWith(
                        color: ZipColors
                            .lightGray)), // Display tipAmount in dollars or percentage
                Text('Your average tip: \$3.40',
                    style: ZipDesign.bodyText
                        .copyWith(color: ZipColors.lightGray)),
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
              children: ['5', '10', '15', '20', '25', '30']
                  .map((percentage) => percentageButton(percentage))
                  .toList(),
            ),
            const SizedBox(height: 20),
            Text('\nSelect Custom Amount',
                style:
                    ZipDesign.sectionTitleText.copyWith(color: Colors.black)),
            TextField(
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  updateDefaultTip(double.parse(value));
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
        color: ZipColors.primaryBackground,
        surfaceTintColor: Colors.transparent,
        child: SafeArea(
          child: TextButton(
            style: TextButton.styleFrom(
              backgroundColor: hasChanged ? ZipColors.zipYellow : Colors.grey,
              minimumSize: const Size(double.infinity, 50),
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
            onPressed: hasChanged
                ? () {
                    saveChanges();
                    Navigator.pop(context);
                  }
                : null,
            child: Text(
              'Save changes',
              style: TextStyle(
                color: hasChanged ? Colors.black : Colors.white,
                fontSize: 18,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
