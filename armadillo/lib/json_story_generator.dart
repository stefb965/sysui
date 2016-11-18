// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert' as convert;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'story_builder.dart';
import 'story_cluster.dart';
import 'story_generator.dart';

const String _kJsonUrl = 'packages/armadillo/res/stories.json';

class JsonStoryGenerator extends StoryGenerator {
  final Set<VoidCallback> _listeners = new Set<VoidCallback>();
  List<StoryCluster> _storyClusters = <StoryCluster>[];

  @override
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  @override
  List<StoryCluster> get storyClusters => _storyClusters;

  void load(AssetBundle assetBundle) {
    assetBundle.loadString(_kJsonUrl).then((String json) {
      final decodedJson = convert.JSON.decode(json);

      // Load stories
      _storyClusters = decodedJson["stories"]
          .map((Map<String, Object> story) => new StoryCluster(stories: [
                storyBuilder(story),
              ]))
          .toList();
      _notifyListeners();
    });
  }

  void _notifyListeners() {
    _listeners.toList().forEach((VoidCallback listener) => listener());
  }
}