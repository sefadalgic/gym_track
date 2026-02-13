class ImageConstants {
  static ImageConstants? _instance;
  static ImageConstants get instance {
    if (_instance == null) _instance = ImageConstants._init();
    return _instance!;
  }

  ImageConstants._init();

  final String logo = toPng("logo");
}

String toPng(String name) => "assets/images/$name.png";
