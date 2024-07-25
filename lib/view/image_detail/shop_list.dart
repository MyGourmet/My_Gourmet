import 'package:flutter/material.dart';

import '../../core/themes.dart';
import '../widgets/custom_elevated_button.dart';

Future<dynamic> showShopListDialog (
  BuildContext context, { required onApproved,}) 
  
  async { 
    await showDialog<dynamic>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          insetPadding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: Container(
            width: MediaQuery.of(context).size.width - 10.0,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children:[
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    highlightColor: Colors.red,     
                    onPressed: () {
                      Navigator.of(context).pop();
                    },    
                    icon: const Icon(Icons.close),
                  ),
                ), 
                const SizedBox(height: 24),
                const Text ('写真を撮った店舗を選んでください'),
                const SizedBox(height:20),
                Container(
                  padding: const EdgeInsets.only(
                    top: 40,
                    bottom: 100,
                  ),
                  margin: const EdgeInsets.only(
                    left: 10,
                    right:10,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height:15),
              Container(
                padding: const EdgeInsets.only(
                  top: 40,
                  bottom: 100,
                ),
                margin: const EdgeInsets.only(
                  left: 10,
                  right:10,
                ),   
                decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height:15),
              Container(
                padding: const EdgeInsets.only(
                  top: 40,
                  bottom: 100,
                ),
                margin: const EdgeInsets.only(
                  left: 10,
                  right:10,
                ),
                decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 15),

              const Align(
                alignment: Alignment.centerRight,
                child: Text('次の３店鋪'),
              ),
             
              const SizedBox(height: 15),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.05,
                ),
                child: SizedBox(
                  height: 60,
                  child: CustomElevatedButton(
                    //onPressed: onApproved,
                    onPressed: () {},
                    text: '決定',
                  ),
                ),
              ),
              const SizedBox(height: 15,),
              ],
            ),
          ),
        );
      },
    );
  }












