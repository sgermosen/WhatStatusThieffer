import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:status_saver/models/app_model.dart';

class RewardedMinCounter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<AppModel>(builder: (context, child, model) {
      if (model.rewardedCounter == 0) return Container(width: 0, height: 0);
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Icon(Icons.timer),
              SizedBox(width: 3),
              Text('${model.rewardedCounter} min',
                  style: TextStyle(fontSize: 18)),
            ],
          ),
        ),
      );
    });
  }
}
