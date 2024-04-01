import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zipapp/business/user.dart';
import 'package:zipapp/constants/zip_colors.dart';
import 'package:zipapp/constants/zip_design.dart';

class RatingScreen extends StatefulWidget {
  const RatingScreen({Key? key}) : super(key: key);

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  int _rating = 0;
  bool _submitted = false;
  bool _usingDefaultTip = false;
  double _defaultTipPercentage = 20.0;
  double _tripAmount = 100.0;
  TextEditingController _tipController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserService userService = UserService();
  bool _showCommentsBox = false;

  @override
  void initState() {
    super.initState();
    _tipController.text = '';
    loadDefaultTipPercentage();
  }

  Future<void> loadDefaultTipPercentage() async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userService.userID).get();
      if (userDoc.exists && userDoc.data() != null) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        if (data.containsKey('defaultTip')) {
          setState(() {
            _defaultTipPercentage = data['defaultTip'].toDouble();
          });
        }
      }
    } catch (e) {
      print("Error loading default tip percentage: $e");
    }
  }

  void _submitRating() async {
    var userId = userService.userID; // Get user ID from user service
    var ratingCollection = _firestore.collection('ratings');

    try {
      double tipAmount = (_defaultTipPercentage / 100) * _tripAmount;

      await ratingCollection.add({
        'userId': userId,
        'rating': _rating,
        'tip': tipAmount,
        'timestamp': FieldValue.serverTimestamp(),
      });

      setState(() {
        _submitted = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Rating submitted successfully')));
    } catch (e) {
      print(e); // For debugging purposes
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to submit rating')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              'How was your trip with John?',
              style: ZipDesign.pageTitleText.copyWith(color: Colors.black),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 16),
            Text(
              'John D. • 4.92',
              style: ZipDesign.bodyText.copyWith(color: Colors.black),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 24),
            Text(
              '\nRate your ride',
              style: ZipDesign.bodyText.copyWith(color: Colors.black),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 16),
            Row(
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: index < _rating ? ZipColors.zipYellow : ZipColors.lightGray,
                    size: 40,
                  ),
                  onPressed: !_submitted // Disable if already submitted
                      ? () {
                    setState(() {
                      _rating = index + 1;
                      if (_rating < 5) {
                        _showCommentsBox = true;
                      } else {
                        _showCommentsBox = false;
                      }
                    });
                  }
                      : null,
                );
              }),
            ),
            if (_showCommentsBox)
              Column(
                children: [
                  const SizedBox(height: 24),
                  Text(
                    'Any comments or concerns?',
                    style: ZipDesign.bodyText.copyWith(color: Colors.black),
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Enter your comments here...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: ZipColors.zipYellow, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 24),
            Text(
              '\nAdd a tip',
              style: ZipDesign.bodyText.copyWith(color: Colors.black),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _tipController,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    enabled: !_submitted && !_usingDefaultTip,
                    decoration: InputDecoration(
                      hintText: _usingDefaultTip
                          ? '\$${(_tripAmount * _defaultTipPercentage / 100).toStringAsFixed(2)}'
                          : 'Enter tip amount',
                      prefixText: '\$',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: ZipColors.zipYellow, width: 2),
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        _usingDefaultTip = false;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: !_submitted
                      ? () {
                    setState(() {
                      _usingDefaultTip = true;
                      _tipController.clear();
                    });
                  }
                      : null,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: _usingDefaultTip ? ZipColors.zipYellow : Colors.white,
                      border: Border.all(color: _usingDefaultTip ? ZipColors.zipYellow : ZipColors.lightGray,),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: <Widget>[
                        Text(' Default Tip', style: TextStyle(color: _usingDefaultTip ? Colors.black : Colors.black)),
                        SizedBox(width: 8),
                        Text('$_defaultTipPercentage%', style: TextStyle(color: _usingDefaultTip ? Colors.black : Colors.black)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Trip total (with tip): \$14.67',
              style: ZipDesign.bodyText.copyWith(color: ZipColors.lightGray),
              textAlign: TextAlign.left,
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: !_submitted && _rating > 0 ? _submitRating : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: _submitted ? Colors.grey : ZipColors.zipYellow,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            _submitted ? 'Submitted' : 'Submit',
            style: ZipDesign.bodyText.copyWith(
              color: _submitted ? Colors.black : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

