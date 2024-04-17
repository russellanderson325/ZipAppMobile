import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:zipapp/business/user.dart';
import 'package:zipapp/constants/tailwind_colors.dart';
import 'package:zipapp/constants/zip_colors.dart';
import 'package:zipapp/constants/zip_design.dart';
import 'package:zipapp/ui/widgets/authentication_drawer_widgets.dart';

typedef ClearDataBuilder = void Function(
  BuildContext context,
  void Function() methodFromChild,
);

class RatingDrawer extends StatefulWidget {
  final Function closeDrawer;
  final Function getSubmitted;
  final Function setSubmitted;
  final ClearDataBuilder builder;
  const RatingDrawer(
      {super.key,
      required this.closeDrawer,
      required this.getSubmitted,
      required this.setSubmitted,
      required this.builder});

  @override
  State<RatingDrawer> createState() => _RatingDrawerState();
}

class _RatingDrawerState extends State<RatingDrawer> {
  final UserService userService = UserService();
  final TextEditingController _tipController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  AuthenticationDrawerWidgets adw = AuthenticationDrawerWidgets();

  final double _tripPrice = 12.23;
  final String _driver = 'John D.';
  final String _driverRating = '4.92';
  int _rating = 0;
  bool _showCommentsBox = false;
  bool _dirtyTip = false;
  bool _dirtyRating = false;
  double _defaultTipPercentage = 20.0;

  @override
  void initState() {
    super.initState();
    _tipController.text = '';
    loadDefaultTipPercentage();
  }

  Future<void> loadDefaultTipPercentage() async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userService.userID).get();
      if (userDoc.exists && userDoc.data() != null) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        if (data.containsKey('defaultTip')) {
          setState(() {
            _defaultTipPercentage = data['defaultTip'].toDouble();
          });
        }
      }
    } catch (e) {
      print(
          "Error loading default tip percentage, using local default instead: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    widget.builder.call(context, noSubmissionSoClearDrawerData);
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Container(
      alignment: Alignment.topCenter,
      width: width,
      height: height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: SizedBox(
        width: width - 32,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(height: 16),
                Center(child: adw.draggableIcon()),
                const SizedBox(height: 16),
                Text(
                  'How was your trip with John?',
                  style: ZipDesign.pageTitleText.copyWith(color: Colors.black),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 8),
                Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        '$_driver • ',
                        style: ZipDesign.bodyText
                            .copyWith(color: TailwindColors.gray500),
                        textAlign: TextAlign.left,
                      ),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 2.0),
                        child: Icon(
                          Icons.star,
                          color: TailwindColors.gray500,
                          size: 14,
                          fill: 1,
                        ),
                      ),
                      Text(
                        _driverRating,
                        style: ZipDesign.bodyText
                            .copyWith(color: TailwindColors.gray500),
                        textAlign: TextAlign.left,
                      ),
                    ]),
                const SizedBox(height: 32),
                Text(
                  '\nRate your ride',
                  style: ZipDesign.bodyText.copyWith(color: Colors.black),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 16),
                _ratingRow(),
                if (_showCommentsBox) _commentsBox(),
                const SizedBox(height: 32),
                const Text(
                  '\nAdd a tip',
                  style: ZipDesign.bodyText,
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 16),
                _alternateTipField(),
                const SizedBox(height: 16),
                Text(
                  'Trip total (with tip): \$${_getPriceWithTip()}',
                  style: ZipDesign.bodyText,
                  textAlign: TextAlign.left,
                ),
              ],
            ),
            _submitButton(),
          ],
        ),
      ),
    );
  }

  void noSubmissionSoClearDrawerData() {
    setState(() {
      _dirtyRating = false;
      _dirtyTip = false;
      _rating = 0;
      _tipController.text = '';
      _showCommentsBox = false;
    });
  }

  Widget _ratingRow() {
    return Row(
      children: List.generate(5, (index) {
        return IconButton(
          icon: Icon(
            index < _rating ? Icons.star : Icons.star_border,
            color: index < _rating ? ZipColors.zipYellow : ZipColors.lightGray,
            size: 40,
          ),
          onPressed: widget.getSubmitted()
              ? null
              : () {
                  setState(() {
                    _dirtyRating = true;
                    _rating = index + 1;
                    if (_rating < 5) {
                      _showCommentsBox = true;
                    } else {
                      _showCommentsBox = false;
                    }
                  });
                },
        );
      }),
    );
  }

  Widget _commentsBox() {
    return Column(
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
              borderSide:
                  const BorderSide(color: ZipColors.zipYellow, width: 2),
            ),
          ),
        ),
        Row(
          children: <Widget>[
            const Icon(
              LucideIcons.info,
              color: TailwindColors.gray500,
              size: 16.0,
            ),
            Text(
              'Your driver will be able to see your comments.',
              style: ZipDesign.disabledBodyText.copyWith(fontSize: 14),
            )
          ],
        )
      ],
    );
  }

  String _getPriceWithTip() {
    double price;
    if (_dirtyTip || widget.getSubmitted()) {
      double tip = double.tryParse(_tipController.text) ?? 0.0;
      price = _tripPrice + tip;
    } else {
      price = _tripPrice + ((_defaultTipPercentage / 100) * _tripPrice);
    }
    return price.toStringAsFixed(2);
  }

  Widget _alternateTipField() {
    return Center(
      child: TextField(
        controller: _tipController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        enabled: !widget.getSubmitted(),
        onChanged: (value) {
          if (value.isNotEmpty) {
            setState(() {
              _dirtyTip = true;
            });
          }
        },
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(0),
          hintText:
              '${_getDefaultTipAmount()} (your default $_defaultTipPercentage%)',
          prefixIcon: const Icon(LucideIcons.dollarSign),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: TailwindColors.gray300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: TailwindColors.gray300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: TailwindColors.gray300),
          ),
        ),
      ),
    );
  }

  String _getDefaultTipAmount() {
    double tip = _defaultTipPercentage * _tripPrice / 100;
    return tip.toStringAsFixed(2);
  }

  Widget _submitButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32.0),
      child: TextButton(
        onPressed: !widget.getSubmitted() && _dirty ? _submit : null,
        style: !widget.getSubmitted() && _dirty
            ? ZipDesign.yellowButtonStyle
            : ZipDesign.disabledYellowButtonStyle,
        child: Text(
          'Submit${_dirtyRating ? ' Rating' : ''}${_dirtyRating && _dirtyTip ? ' and' : ''}${_dirtyTip ? ' Tip' : ''}',
          style: !widget.getSubmitted() && _dirty
              ? ZipDesign.bodyText
              : ZipDesign.disabledBodyText,
        ),
      ),
    );
  }

  bool get _dirty => _dirtyTip || _dirtyRating;

  void _submit() async {
    var userId = userService.userID; // Get user ID from user service
    var ratingCollection = _firestore.collection('ratings');

    try {
      double tipAmount = (_defaultTipPercentage / 100) * _tripPrice;

      await ratingCollection.add({
        'userId': userId,
        'rating': _rating,
        'tip': tipAmount,
        'timestamp': FieldValue.serverTimestamp(),
      });

      setState(() {
        widget.setSubmitted(true);
        _dirtyTip = false;
      });
      widget.closeDrawer();
    } catch (e) {
      print(e); // For debugging purposes
    }
  }
}
