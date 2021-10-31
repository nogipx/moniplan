import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

class DashboardLayout extends StatelessWidget {
  const DashboardLayout({
    Key? key,
    this.content,
    this.drawer,
    this.appBar,
    this.floatingActionButton,
  }) : super(key: key);

  final Widget? content;
  final Widget? drawer;
  final PreferredSizeWidget? appBar;
  final FloatingActionButton? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final wrapper = ResponsiveWrapper.of(context);
        if (wrapper.isDesktop) {
          return Scaffold(
            appBar: appBar,
            floatingActionButton: floatingActionButton,
            body: Row(
              children: [
                if (drawer != null)
                  Expanded(
                    flex: 3,
                    child: drawer!,
                  ),
                if (content != null)
                  Expanded(
                    flex: 9,
                    child: content!,
                  )
              ],
            ),
          );
        }
        if (wrapper.isPhone) {}
        return Scaffold(
          body: content,
          appBar: appBar,
          floatingActionButton: floatingActionButton,
          drawer: Drawer(
            child: drawer,
          ),
        );
      },
    );
  }
}
