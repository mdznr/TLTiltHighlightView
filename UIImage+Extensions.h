//
//  UIImage+Extensions.h
//
//  Created by Hardy Macia on 7/1/09.
//  Copyright 2009 Catamount Software. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface UIImage (UIImage_Extensions)

- (UIImage *)imageRotatedByRadians:(CGFloat)radians;
- (UIImage *)squareImageRotatedByRadians:(CGFloat)radians;
- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees;
- (UIImage *)squareImageRotatedByDegrees:(CGFloat)degrees;

@end;