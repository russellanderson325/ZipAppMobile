import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zipapp/business/user.dart';
import 'package:zipapp/constants/zip_colors.dart';
import 'package:zipapp/constants/zip_design.dart';

class DefaultTipScreen extends StatefulWidget {
  const DefaultTipScreen({Key? key}) : super(key: key);

  @override
  _DefaultTipScreenState createState() => _DefaultTipScreenState();
}

class _DefaultTipScreenState extends State<DefaultTipScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  UserService userService = UserService();
  double tipAmount = 20.0; // Default value for demonstration
  bool hasChanged = false; // Tracks if a new percentage was selected

  @override
  void initState() {
    super.initState();
  }

  void updateDefaultTip(double newTip) {
    if (newTip != tipAmount && !hasChanged) {
      setState(() {
        hasChanged = true;
      });
    } else if (newTip == tipAmount && hasChanged) {
      setState(() {
        hasChanged = false;
      });
    }
    setState(() {
      tipAmount = newTip;
    });
    print("Updating default tip to: $tipAmount");
  }

  void showCustomTipDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController _customTipController = TextEditingController();
        return AlertDialog(
          title: const Text('Enter Custom Tip'),
          content: TextField(
            controller: _customTipController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: 'Custom Tip Percentage',
              prefixText: '% ',
              border: OutlineInputBorder(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                double? customTip = double.tryParse(_customTipController.text);
                if (customTip != null) {
                  updateDefaultTip(customTip);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget percentageButton(String percentage, {bool isCustom = false}) {
    bool isSelected = isCustom ? false : (tipAmount == double.parse(percentage));
    return ElevatedButton(
      onPressed: () {
        if (isCustom) {
          showCustomTipDialog();
        } else {
          updateDefaultTip(double.parse(percentage));
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? ZipColors.zipYellow : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: EdgeInsets.symmetric(vertical: 15),
      ),
      child: Text(
        isCustom ? '     %\nCustom' : '$percentage%',
        style: ZipDesign.bodyText.copyWith(color: isSelected ? Colors.black : Colors.grey, fontSize: 18),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Default Tip', style: ZipDesign.pageTitleText.copyWith(color: Colors.black)),
        backgroundColor: ZipColors.primaryBackground,
        elevation: 0,
      ),
      backgroundColor: ZipColors.primaryBackground,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current', style: ZipDesign.sectionTitleText.copyWith(color: Colors.black)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${tipAmount.toStringAsFixed(0)}%', style: ZipDesign.bodyText.copyWith(color: ZipColors.lightGray)),
                Text('Your average tip: \$3.40', style: ZipDesign.bodyText.copyWith(color: ZipColors.lightGray)),
              ],
            ),
            const SizedBox(height: 20),
            Text('\nSelect Percentage', style: ZipDesign.sectionTitleText.copyWith(color: Colors.black)),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              childAspectRatio: 1.5 / 1,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              children: ['10', '15', '20', '25', '30'].map((percentage) {
                return percentageButton(percentage);
              }).toList()..add(percentageButton('Custom', isCustom: true)),
            ),
            const SizedBox(height: 20),
            Text('\nSelect Custom Amount', style: ZipDesign.sectionTitleText.copyWith(color: Colors.black)),
            TextField(
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  updateDefaultTip(double.parse(value));
                }
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: '\$ Enter amount...',
                hintStyle: ZipDesign.labelText.copyWith(color: Colors.black),
                prefix: const Text('\$ ', style: TextStyle(color: Colors.black)),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: ZipColors.zipYellow)),
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
              backgroundColor: hasChanged ? ZipColors.zipYellow : Colors.grey, // Dynamically change the button color
              minimumSize: const Size(double.infinity, 50),
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
            onPressed: hasChanged ? () {

            } : null, // Disables the button if no change has occurred
            child: const Text('Save changes', style: TextStyle(color: Colors.white)),
          ),
        ),
      ),
    );
  }
}