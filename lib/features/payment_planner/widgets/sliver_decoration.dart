// import "package:flutter/material.dart" show Colors;
// import "package:flutter/widgets.dart";
// import "package:flutter_sticky_header/flutter_sticky_header.dart";
//
//
// class SliverDecoration extends StatelessWidget {
//   final Widget sliver;
//   final int index;
//   final bool stickyHeader;
//
//   const SliverDecoration({
//     required this.sliver,
//     required this.index,
//     this.stickyHeader = false,
//   });
//
//   // Color get _color => _colors[index % _colors.length];
//
//   @override
//   Widget build(BuildContext context) {
//     return SliverStickyHeader(
//       header: stickyHeader
//
//       sliver: DecoratedSliver(
//         decoration: BoxDecoration(
//           border: Border(
//             left: BorderSide(
//               color: _color.withOpacity(0.1),
//               width: 8,
//             ),
//           ),
//         ),
//         sliver: SliverPadding(
//           padding: const EdgeInsets.all(12),
//           sliver: sliver,
//         ),
//       ),
//     );
//   }
// }
