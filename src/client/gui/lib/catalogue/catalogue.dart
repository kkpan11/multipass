import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart' hide ImageInfo;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';
import 'image_card.dart';
import 'launch_panel.dart';

final imagesProvider = FutureProvider<List<ImageInfo>>((ref) async {
  return ref.watch(daemonAvailableProvider)
      ? await ref
          .watch(grpcClientProvider)
          .find(blueprints: false)
          .then((r) => sortImages(r.imagesInfo))
      : ref.state.valueOrNull ?? await Completer<List<ImageInfo>>().future;
});

// sorts the images in a more user-friendly way
// the current LTS > other releases sorted by most recent > current devel > core images > appliances
List<ImageInfo> sortImages(List<ImageInfo> images) {
  final ltsIndex = images.indexWhere((image) {
    return image.aliasesInfo.any((a) => a.alias == 'lts');
  });
  final lts = ltsIndex != -1 ? images.removeAt(ltsIndex) : null;

  final develIndex = images.indexWhere((image) {
    return image.aliasesInfo.any((a) => a.alias == 'devel');
  });
  final devel = develIndex != -1 ? images.removeAt(develIndex) : null;

  bool coreFilter(ImageInfo image) {
    return image.aliasesInfo.any((a) => a.alias.contains('core'));
  }

  bool applianceFilter(ImageInfo image) {
    return image.aliasesInfo.any((a) => a.remoteName.contains('appliance'));
  }

  int decreasingReleaseSorter(ImageInfo a, ImageInfo b) {
    return b.release.compareTo(a.release);
  }

  final normalImages = images
      .whereNot(coreFilter)
      .whereNot(applianceFilter)
      .sorted(decreasingReleaseSorter);
  final coreImages = images.where(coreFilter).sorted(decreasingReleaseSorter);
  final applianceImages = images.where(applianceFilter);

  return [
    if (lts != null) lts,
    ...normalImages,
    if (devel != null) devel,
    ...coreImages,
    ...applianceImages,
  ];
}

class CatalogueScreen extends ConsumerWidget {
  static const sidebarKey = 'catalogue';

  const CatalogueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final images = ref.watch(imagesProvider).valueOrNull ?? const [];
    final imageList = SingleChildScrollView(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          child: const Text(
            'Images',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        LayoutBuilder(builder: (_, constraints) {
          const minCardWidth = 285;
          const spacing = 32.0;
          final nCards = constraints.maxWidth ~/ minCardWidth;
          final whiteSpace = spacing * (nCards - 1);
          final cardWidth = (constraints.maxWidth - whiteSpace) / nCards;
          return Wrap(
            runSpacing: spacing,
            spacing: spacing,
            children:
                images.map((image) => ImageCard(image, cardWidth)).toList(),
          );
        }),
        const SizedBox(height: 32),
      ]),
    );

    final welcomeText = Container(
      constraints: const BoxConstraints(maxWidth: 500),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Welcome to Multipass', style: TextStyle(fontSize: 37)),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Get an instant VM or Appliance in seconds. Multipass can launch and run virtual machines and configure them like a public cloud.',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      endDrawer: const LaunchPanel(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 140).copyWith(top: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            welcomeText,
            const Divider(),
            Expanded(child: imageList),
          ],
        ),
      ),
    );
  }
}
