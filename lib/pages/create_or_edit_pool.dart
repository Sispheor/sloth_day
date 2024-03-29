import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_nord_theme/flutter_nord_theme.dart';
import 'package:hive/hive.dart';
import 'package:sloth_day/hive_boxes.dart';
import 'package:sloth_day/models/bucket.dart';
import 'package:sloth_day/models/pool.dart';

class CreateOrEditPoolPage extends StatefulWidget {

  final bool isEdit;
  final Bucket bucket;
  final Pool? pool;

  const CreateOrEditPoolPage({
    Key? key,
    required this.isEdit, required this.bucket, this.pool
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _CreateOrEditPoolPage();
  }

}

class _CreateOrEditPoolPage extends State<CreateOrEditPoolPage> {

  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final maxDayController = TextEditingController();
  Color currentColor = const Color(0xff7f4934);
  bool firstPageLoad = false;

  @override
  Widget build(BuildContext context) {
    String title = "Create a pool of day off";
    Color pickerColor = const Color(0xff7f4934);

    void changeColor(Color color) {
      setState(() => pickerColor = color);
    }

    if (widget.isEdit && !firstPageLoad){
      title = "Edit pool '${widget.pool!.name}'";
      nameController.text = widget.pool!.name;
      maxDayController.text = widget.pool!.maxDays.toStringAsFixed(0);
      currentColor = widget.pool!.color;
      firstPageLoad = true;
    }

    return Scaffold(
        appBar: AppBar(
          backgroundColor: NordColors.polarNight.darkest,
          title: Text(title),
        ),
        body: Container(
            constraints: const BoxConstraints.expand(),
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/sloth2.png"),
                fit: BoxFit.fitWidth,
                alignment: Alignment.bottomCenter,),
            ),
            padding: const EdgeInsets.all(40.0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Form(key: _formKey,
                      child: Column(
                          children: [
                            TextFormField(
                              decoration: const InputDecoration(
                                  border: UnderlineInputBorder(),
                                  labelText: 'Name'
                              ),
                              controller: nameController,
                              // The validator receives the text that the user has entered.
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a name';
                                }
                                if (!widget.isEdit && _isPoolNameExist(value)){
                                  return 'Bucket name exist already';
                                }
                                return null;
                              },
                            ),
                            TextFormField(
                                controller: maxDayController,
                                decoration: const InputDecoration(labelText: "Number of day"),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                inputFormatters:  [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?[5]{0,1}'))],
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a value';
                                  }
                                  return null;
                                }
                            ),
                            const Divider(),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                                icon: const Icon(Icons.brush),
                                style: ElevatedButton.styleFrom(
                                    primary: currentColor
                                ),
                                label: const Text("Color"),
                                onPressed: (){
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Select a color'),
                                        titlePadding: const EdgeInsets.all(10),
                                        contentPadding: const EdgeInsets.all(2),
                                        content: SingleChildScrollView(
                                          child: BlockPicker(
                                            pickerColor: pickerColor,
                                            onColorChanged: changeColor,
                                          ),
                                        ),
                                        actions: <Widget>[
                                          ElevatedButton(
                                            child: const Text('Ok'),
                                            onPressed: () {
                                              setState(() {
                                                currentColor = pickerColor;
                                              });
                                              Navigator.of(context).pop();
                                            },
                                            style: ElevatedButton.styleFrom(
                                                primary: Colors.green
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }
                            ),
                          ]
                      )
                  )
                ]
            )
        ),
        floatingActionButton: FloatingActionButton(
          // When the user presses the button, show an alert dialog containing
          // the text that the user has entered into the text field.
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              if (widget.isEdit){
                await _updatePool(widget.pool!);
              }else{
                await _persistPool();
              }
              Navigator.pop(context);  // return to previous screen (main)
            }
          },
          child: const Icon(Icons.done),
          backgroundColor: Colors.green,
        )
    );
  }

  Future<void> _persistPool() async {

    Pool newPool = Pool(
        nameController.text,
        double.parse(maxDayController.text),
        color: currentColor);
    final box = Boxes.getPools();
    box.add(newPool);
    widget.bucket.pools!.add(newPool);
    widget.bucket.save();
    // create empty dayOff list
    final dayOffBox = Boxes.getDayOffs();
    newPool.dayOffList = HiveList(dayOffBox);
    newPool.save();
  }

  bool _isPoolNameExist(String value) {
    final box = Boxes.getPools().values.where((element) => widget.bucket.pools!.contains(element));
    for (Pool existingPool in box.toList().cast<Pool>()){
      if (value == existingPool.name){
        return true;
      }
    }
    return false;
  }

  _updatePool(Pool poolToUpdate) {
    poolToUpdate.name = nameController.text;
    poolToUpdate.maxDays = double.parse(maxDayController.text);
    poolToUpdate.color = currentColor;
    poolToUpdate.save();
  }

}
