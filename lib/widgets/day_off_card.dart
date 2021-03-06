import 'package:flutter/material.dart';
import 'package:flutter_nord_theme/flutter_nord_theme.dart';
import 'package:intl/intl.dart';
import 'package:sloth_day/models/day_off.dart';
import 'package:sloth_day/models/pool.dart';
import 'package:sloth_day/pages/create_or_edit_day_off.dart';
import 'package:sloth_day/utils/widget_utils.dart';
import 'package:sloth_day/widgets/dialog_confirm_cancel.dart';

import 'edit_delete_menu_item.dart';

class DayOffCardWidget extends StatefulWidget {

  final DayOff dayOff;
  final VoidCallback callback;
  final Pool pool;

  const DayOffCardWidget({
    Key? key,
    required this.dayOff, required this.pool, required this.callback
  }) : super(key: key);


  @override
  State<DayOffCardWidget> createState() => _DayOffCardWidgetState();
}

class _DayOffCardWidgetState extends State<DayOffCardWidget> {

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        color: NordColors.$3.withOpacity(0.6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              title: Text(widget.dayOff.name, style: TextStyle(color: widget.pool.color, fontWeight: FontWeight.bold)),
              leading: CircleAvatar(
                  radius: 20,
                  backgroundColor: widget.pool.color,
                  child: Text(removeDecimalZeroFormat(widget.dayOff.getTotalTakenDays()),
                      style: const TextStyle(color: Colors.white))),
              subtitle: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.dayOff.isHalfDay)
                  const Text('Half days', style: TextStyle(fontSize: 12)),
                  Padding(
                      padding: const EdgeInsets.all(5),
                      child:RichText(
                        text: TextSpan(
                          children: [
                            const WidgetSpan(
                              child: Icon(Icons.calendar_today, size: 15, color: Colors.white),
                            ),
                            TextSpan(
                              text: " " + DateFormat('dd MMMM yyyy').format(widget.dayOff.dateStart),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      )),
                  if (widget.dayOff.getTotalTakenDays() > 1)
                  const Padding(
                      padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
                      child: Icon(Icons.arrow_drop_down, size: 15, color: Colors.white)
                  ),
                  if (widget.dayOff.getTotalTakenDays() > 1)
                  Padding(
                      padding: const EdgeInsets.all(5),
                      child:RichText(
                        text: TextSpan(
                          children: [
                            const WidgetSpan(
                              child: Icon(Icons.calendar_today, size: 15, color: Colors.white),
                            ),
                            TextSpan(
                              text: " " + DateFormat('dd MMMM yyyy').format(widget.dayOff.dateEnd),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ))
                ],
              ),
              trailing: PopupMenuButton(
                  onSelected: (value) {
                    _onMenuItemSelected(value as Options);
                  },
                  icon: const Icon(Icons.more_vert),
                  itemBuilder: (context) => popupMenuItemEditDelete()
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onMenuItemSelected(Options value) async {
    if (value == Options.edit) {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => CreateOrEditDayOffPage(isEdit: true, pool: widget.pool, dayOff: widget.dayOff))
      ).then((_) => setState(() { widget.callback();}));
    }
    if (value == Options.delete) {
      final action = await ConfirmCancelDialogs.yesAbortDialog(context, "Delete day off '${widget.dayOff.name}'?", 'Confirm');
      if (action == DialogAction.confirmed) {
        widget.dayOff.delete();
        widget.callback();
      }
    }
  }

}
