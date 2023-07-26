import 'package:flutter/cupertino.dart';
import 'package:rflutter/features/feed/screen/feed_screen.dart';
import 'package:rflutter/features/post/screen/add_post_screen.dart';

class Constants {
  static const logoPath = 'assets/images/logo.png';
  static const logoEmotePath = 'assets/images/loginEmote.png';
  static const googlePath = 'assets/images/google.png';

  static const IconData up =
      IconData(0xe800, fontFamily: 'MyFlutterApp', fontPackage: null);
  static const IconData down =
      IconData(0xe801, fontFamily: 'MyFlutterApp', fontPackage: null);

  static const items = [FeedScreen(), AddPostScreen()];

  static const bannerDefault =
      'https://thumbs.dreamstime.com/b/abstract-stained-pattern-rectangle-background-blue-sky-over-fiery-red-orange-color-modern-painting-art-watercolor-effe-texture-123047399.jpg';
  static const avatarDefault =
      'https://external-preview.redd.it/5kh5OreeLd85QsqYO1Xz_4XSLYwZntfjqou-8fyBFoE.png?auto=webp&s=dbdabd04c399ce9c761ff899f5d38656d1de87c2';
}
