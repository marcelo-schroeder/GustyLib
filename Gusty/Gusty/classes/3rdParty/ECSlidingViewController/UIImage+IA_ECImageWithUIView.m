//
//  UIImage+ImageWithUIView.m
//

#import "UIImage+IA_ECImageWithUIView.h"

@implementation UIImage (IA_ECImageWithUIView)
#pragma mark -
#pragma mark TakeScreenShot

+ (UIImage *)imageWithUIView:(UIView *)view
{
  CGSize screenShotSize = view.bounds.size;
  UIImage *img;  
  UIGraphicsBeginImageContext(screenShotSize);
  CGContextRef ctx = UIGraphicsGetCurrentContext();
  [view drawLayer:view.layer inContext:ctx];
  img = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
  return img;
}
@end
