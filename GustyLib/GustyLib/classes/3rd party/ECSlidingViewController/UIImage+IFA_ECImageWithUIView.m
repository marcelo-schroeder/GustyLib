//
//  UIImage+ImageWithUIView.m
//

#import "UIImage+IFA_ECImageWithUIView.h"

@implementation UIImage (IFA_ECImageWithUIView)
#pragma mark -
#pragma mark TakeScreenShot

+ (UIImage *)ifa_imageWithUIView:(UIView *)view
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
