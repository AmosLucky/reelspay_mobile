import 'package:flutter/material.dart';

import '../models.dart';

const String _vFlower = 'assets/videos/flower.mp4';
const String _vBbb = 'assets/videos/bbb-10s.mp4';
const String _vJelly = 'assets/videos/jellyfish-10s.mp4';
const String _vSintel = 'assets/videos/sintel-10s.mp4';
const String _v300 = 'assets/videos/movie-300.mp4';

const List<String> _episodeTitles = [
  'The Beginning',
  'A Dangerous Deal',
  'Family Meeting',
  'The Betrayal',
  'Cold Eyes',
  'Second Life',
  'The Reveal',
  'Under Pressure',
  'Sweet Trap',
  'The Counterattack',
  'Broken Vow',
  'Final Move',
];

const List<Drama> dramas = [
  Drama(
    id: 'crimson-night-kiss',
    title: 'Crimson Night Kiss',
    desc: "Fifteen years ago, Nora's family was slaughtered by werewolf nobles. The lone survivor hid her identity... until the Alpha King caught her scent.",
    tags: ['Werewolf', 'Romance', 'Revenge'],
    episodes: 49,
    poster: 'assets/posters/crimson-night-kiss.png',
    clips: [_vSintel, _v300],
    badge: 'hot',
    categories: ['Top', 'Popular', 'Romance', 'Fantasy'],
    likes: 128400,
    comments: 9600,
  ),
  Drama(
    id: 'wrath-of-olympus',
    title: 'Wrath of Olympus',
    desc: 'Stripped of his godhood, the fallen god of war must survive the mortal world — and the woman fated to destroy him.',
    tags: ['Fantasy', 'Action', 'Myth'],
    episodes: 62,
    poster: 'assets/posters/wrath-of-olympus.png',
    clips: [_v300, _vBbb],
    badge: 'hot',
    categories: ['Top', 'Popular', 'Fantasy'],
    likes: 96200,
    comments: 7100,
  ),
  Drama(
    id: 'mermaids-broken-vow',
    title: "Mermaid's Broken Vow",
    desc: 'She traded her voice for legs to save the man she loved. He woke up married to someone else.',
    tags: ['Fantasy', 'Romance', 'Tragedy'],
    episodes: 38,
    poster: 'assets/posters/mermaids-broken-vow.png',
    clips: [_vJelly, _vFlower],
    badge: 'hot',
    categories: ['Popular', 'Romance', 'Fantasy'],
    likes: 87100,
    comments: 6400,
  ),
  Drama(
    id: 'shadow-scorpion-hunt',
    title: 'Shadow Scorpion Hunt',
    desc: "The desert's deadliest assassin has one last contract — the prince she was sworn to protect.",
    tags: ['Action', 'Thriller', 'Assassin'],
    episodes: 45,
    poster: 'assets/posters/shadow-scorpion-hunt.png',
    clips: [_v300, _vFlower],
    badge: 'hot',
    categories: ['Top', 'Action'],
    likes: 74800,
    comments: 5200,
  ),
  Drama(
    id: 'betrayed-by-my-alpha',
    title: 'Betrayed by My Alpha, Claimed by Fate',
    desc: 'Rejected by her fated mate on her 18th birthday, Luna Kia runs — straight into the arms of the Lycan King.',
    tags: ['Werewolf', 'Romance', 'Drama'],
    episodes: 51,
    poster: 'assets/posters/betrayed-by-my-alpha.png',
    clips: [_vSintel, _vJelly],
    categories: ['Popular', 'Romance', 'Fantasy'],
    likes: 65300,
    comments: 4800,
  ),
  Drama(
    id: 'marrying-the-ceo',
    title: 'Marrying the Mysterious CEO',
    desc: 'A contract marriage. A cold CEO. A hidden identity worth ten billion.',
    tags: ['CEO', 'Romance', 'Sweet'],
    episodes: 66,
    poster: 'assets/posters/marrying-the-ceo.png',
    clips: [_v300, _vSintel],
    badge: 'new',
    categories: ['CEO', 'Popular', 'Wealthy'],
    likes: 52900,
    comments: 3900,
  ),
  Drama(
    id: 'smile-my-cold-husband',
    title: 'Smile, My Cold Husband',
    desc: 'Everyone fears President Chen. Only his forgettable wife knows why he never smiles.',
    tags: ['CEO', 'Romance', 'Healing'],
    episodes: 42,
    poster: 'assets/posters/smile-my-cold-husband.png',
    clips: [_vFlower, _vBbb],
    categories: ['CEO', 'Romance'],
    likes: 48700,
    comments: 3500,
  ),
  Drama(
    id: 'heiress-comeback',
    title: "The Heiress' Comeback",
    desc: 'Cheated, broke, disowned. Three years later she returns as the majority shareholder.',
    tags: ['Revenge', 'Comeback', 'Wealthy'],
    episodes: 55,
    poster: 'assets/posters/heiress-comeback.png',
    clips: [_vFlower, _vJelly],
    badge: 'new',
    categories: ['Comeback', 'Revenge', 'Wealthy'],
    likes: 61200,
    comments: 4400,
  ),
  Drama(
    id: 'lunas-second-chance',
    title: "Luna's Second Chance",
    desc: 'Killed on her wedding night, she wakes ten years in the past with one goal: save her pack.',
    tags: ['Werewolf', 'Revenge', 'Fantasy'],
    episodes: 47,
    poster: 'assets/posters/lunas-second-chance.png',
    clips: [_vSintel, _vFlower],
    categories: ['Fantasy', 'Revenge'],
    likes: 39800,
    comments: 2900,
  ),
  Drama(
    id: 'billionaire-bodyguard',
    title: 'Secret Billionaire Bodyguard',
    desc: 'He guards her by day and owns the city by night. She must never find out.',
    tags: ['Action', 'CEO', 'Romance'],
    episodes: 58,
    poster: 'assets/posters/billionaire-bodyguard.png',
    clips: [_vBbb, _v300],
    categories: ['CEO', 'Wealthy', 'Action'],
    likes: 44600,
    comments: 3100,
  ),
];

const List<String> categories = [
  'Top', 'Popular', 'CEO', 'Comeback', 'Romance', 'Wealthy', 'Fantasy', 'Revenge',
];

final List<Drama> featured = [dramas[0], dramas[1], dramas[5], dramas[7]];

/// All episodes of one drama as a vertical feed (EP1 .. EPn).
List<FeedItem> buildDramaFeed(Drama drama) {
  return List.generate(drama.episodes, (i) {
    final ep = i + 1;
    return FeedItem(
      key: '${drama.id}#$ep',
      drama: drama,
      ep: ep,
      title: 'Episode $ep · ${_episodeTitles[(ep - 1) % _episodeTitles.length]}',
      clip: drama.clips[i % drama.clips.length],
    );
  });
}

/// Mixed "For You" feed: EP1 of every drama, then EP2 of the top six —
/// so scrolling passes different videos, like the user asked.
List<FeedItem> buildForYouFeed() {
  final items = <FeedItem>[];
  for (final d in dramas) {
    items.add(buildDramaFeed(d).first);
  }
  for (final d in dramas.take(6)) {
    items.add(buildDramaFeed(d)[1]);
  }
  return items;
}
