class ScreenSize{

  final double height;
  final double width;

  ScreenSize({this.height, this.width});

  double dividingHeight(){
    double hPixels = height/1000;
    return hPixels;
  }

  double dividingWidth(){
    double hPixels = width/100;
    return hPixels;
  }

}