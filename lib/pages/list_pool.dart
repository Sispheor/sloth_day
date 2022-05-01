import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:reuteuteu/hive_boxes.dart';
import 'package:reuteuteu/models/bucket.dart';
import 'package:reuteuteu/models/pool.dart';
import 'package:reuteuteu/widgets/consumption_gauge.dart';
import 'package:reuteuteu/widgets/pool_card.dart';



class ListPool extends StatefulWidget{

  final Bucket bucket;

  const ListPool({Key? key, required this.bucket }) : super(key: key);

  @override
  _ListPoolState createState() => _ListPoolState();

}

class _ListPoolState extends State<ListPool>{

  late Bucket bucket;

  callback(){
    setState(() {
      bucket = Boxes.getBuckets().get(widget.bucket.key)!;
      // log("Number of pool in the bucket: ${widget.bucket.pools?.length}");
    });
  }

  @override
  void initState() {
    bucket = Boxes.getBuckets().get(widget.bucket.key)!;
    log("Number of pool in the bucket: ${bucket.pools?.length}");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return  Column(
      children: [
        if (bucket.pools!.isNotEmpty)
          Card(
              child: SizedBox(
                  height: 150,
                  child: ConsumptionGauge(max: bucket.getPoolMaxDays(), available: bucket.getAvailable())
              )
          ),
        Expanded(
          child: ValueListenableBuilder<Box<Pool>>(
            valueListenable: Boxes.getPools().listenable(),
            builder: (context, box, _) {
              final pools = box.values.where((element) => bucket.pools!.contains(element));
              if (pools.isEmpty) {
                return const Center(
                  child: Text(
                    'No pool yet',
                    style: TextStyle(fontSize: 24),
                  ),
                );
              }else{
                return  ListView(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  children: pools.cast<Pool>().map((pool) => PoolCardWidget(bucket: bucket, pool: pool, callback: callback)).toList(),
                );
              }
            },
          ),
        )
      ],
    );
  }
}
