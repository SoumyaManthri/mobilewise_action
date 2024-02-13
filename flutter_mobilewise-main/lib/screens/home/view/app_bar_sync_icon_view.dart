import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_mobilewise/shared/model/framework_form.dart';

import '../../../screens/home/view_model/home_view_model.dart';
import '../../../shared/event/app_events.dart';
import '../../../utils/app_state.dart';
import '../../../utils/common_constants.dart' as constants;
import '../../../utils/hex_color.dart';
import '../../../utils/network_util.dart';
import '../../forms/view_model/form_view_model.dart';

class SyncButtonWidget extends StatefulWidget {
  const SyncButtonWidget({Key? key, required this.viewModel, this.style})
      : super(key: key);

  final FormViewModel viewModel;
  final FrameworkFormStyle? style;

  @override
  SyncButtonWidgetState createState() => SyncButtonWidgetState();
}

class SyncButtonWidgetState extends State<SyncButtonWidget>
    with SingleTickerProviderStateMixin {
  AnimationController? syncController;
  StreamSubscription? preSyncEventSubscription;
  StreamSubscription? postSyncEventSubscription;
  StreamSubscription? refreshSyncCountSubscription;
  bool isSyncRunning = false;

  @override
  void initState() {
    super.initState();
    syncController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    preSyncEventSubscription =
        AppState.instance.eventBus.on<PreSyncEvent>().listen((event) {
      syncController!.forward();
      syncController!.repeat();
      isSyncRunning = true;
    });
    postSyncEventSubscription =
        AppState.instance.eventBus.on<PostSyncEvent>().listen((event) {
      syncController!.reset();
      isSyncRunning = false;
    });
    refreshSyncCountSubscription =
        AppState.instance.eventBus.on<RefreshSyncCount>().listen((event) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (syncController != null) {
      syncController!.dispose();
    }
    if (preSyncEventSubscription != null) {
      preSyncEventSubscription!.cancel();
    }
    if (postSyncEventSubscription != null) {
      postSyncEventSubscription!.cancel();
    }
    if (refreshSyncCountSubscription != null) {
      refreshSyncCountSubscription!.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    Color iconColor = widget.style?.color != null
        ? HexColor(widget.style!.color!)
        : Colors.black;
    return Center(
      child: Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[
          GestureDetector(
            child: RotationTransition(
              turns: Tween(begin: 0.0, end: 1.0).animate(syncController!),
              child: IconButton(
                icon: Icon(
                  Icons.sync,
                  color: iconColor,
                ),
                onPressed: () async {
                  /// Check if server available
                  bool isOnline = await networkUtils.hasActiveInternet();
                  if (isOnline) {
                    /// Calling app background sync manually
                    widget.viewModel.callAppBackgroundSync(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text(constants.noNetworkAvailability),
                    ));
                  }
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15.0),
            child: FutureBuilder<int>(
              future: widget.viewModel.getNoOfEntriesNotSyncedYet(),
              builder: (context, AsyncSnapshot<int> snapshot) {
                if (snapshot.data != null && snapshot.data != 0) {
                  return Text(
                    snapshot.data.toString(),
                    style: const TextStyle(color: Colors.black),
                  );
                } else {
                  return const SizedBox();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
