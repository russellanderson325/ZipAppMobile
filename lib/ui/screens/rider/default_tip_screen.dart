import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zipapp/business/user.dart';
import 'package:zipapp/constants/zip_colors.dart';
import 'package:zipapp/constants/zip_design.dart';

class DefaultTipScreen extends StatefulWidget {
  const DefaultTipScreen({Key? key}) : super(key: key);

  @override
  State<DefaultTipScreen> createState() => _DefaultTipScreenState();
}

class _DefaultTipScreenState extends State<DefaultTipScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  UserService userService = UserService();
  double tipAmount = 20.0;
  bool hasChanged = false;
  bool isCustomAmountSelected = false;

  @override
  void initState() {
    super.initState();
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
            // Determine whether the stored tip amount is a percentage or a dollar amount
            isCustomAmountSelected = tipAmount >= 1.0;
          });
        }
      }
    } catch (e) {
      print("Error loading saved tip amount: $e");
    }
  }

  void updateDefaultTip(double newTip) {
    if (newTip != tipAmount) {
      setState(() {
        tipAmount = newTip;
        hasChanged = true;
        isCustomAmountSelected =
            true; // Set custom amount selected to true when updating tip amount
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

  void showCustomTipDialog() {
    TextEditingController customTipController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Custom Tip Percentage'),
          content: TextField(
            controller: customTipController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
                hintText: 'Tip percentage', prefixText: '% '),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                double? customTip = double.tryParse(customTipController.text);
                if (customTip != null) {
                  updateDefaultTip(customTip);
                  Navigator.of(context).pop(); // Close the dialog
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget percentageButton(String percentage, {bool isCustom = false}) {
    bool isSelected = isCustom
        ? tipAmount != 20.0 &&
            tipAmount != 10.0 &&
            tipAmount != 15.0 &&
            tipAmount != 25.0 &&
            tipAmount != 30.0
        : tipAmount == double.tryParse(percentage);
    return ElevatedButton(
      onPressed: () {
        if (isCustom) {
          showCustomTipDialog();
        } else {
          updateDefaultTip(double.parse(percentage));
          setState(() {
            isCustomAmountSelected =
                false; // Set custom amount selected to false when selecting a percentage
          });
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? ZipColors.zipYellow : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 20),
      ),
      child: Text(
        isCustom ? '     %\nCustom' : '$percentage%',
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
                Text(
                    isCustomAmountSelected
                        ? '${tipAmount.toStringAsFixed(2)}%'
                        : '${tipAmount.toStringAsFixed(0)}%',
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
              children: ['10', '15', '20', '25', '30']
                  .map((percentage) => percentageButton(percentage))
                  .toList()
                ..add(percentageButton('% Custom', isCustom: true)),
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
                  setState(() {
                    isCustomAmountSelected = true;
                  });
                } else {
                  setState(() {
                    isCustomAmountSelected = false;
                  });
                }
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: '\$ Enter amount...',
                hintStyle: ZipDesign.labelText.copyWith(color: Colors.black),
                prefixText: '\$ ',
                enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: ZipColors.zipYellow)),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: ZipColors.primaryBackground,
        child: SafeArea(
          child: TextButton(
            style: TextButton.styleFrom(
              backgroundColor: hasChanged ? ZipColors.zipYellow : Colors.grey,
              minimumSize: const Size(double.infinity, 50),
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
            onPressed: hasChanged ? () => saveChanges() : null,
            child: const Text('Save changes',
                style: TextStyle(color: Colors.white)),
          ),
        ),
      ),
    );
  }
}
