//
//  UIImage+Rotate.m
//
//  Created by Matt on 4/10/13.
//  Copyright (c) 2013 Matt Zanchelli. All rights reserved.
//

#import "UIImage+Rotate.h"

@implementation UIImage (Rotate)

- (UIImage *)imageWithRotation:(CGFloat)angle
{
//	NSDate *begin = [NSDate date];// ***
	
    UIImage *copy = nil;
    CGContextRef ctxt = nil;
    CGRect rect = CGRectZero;
	rect.size = self.size;
	
	UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0f);
	
	ctxt = UIGraphicsGetCurrentContext();
	
//	NSDate *getcur = [NSDate date];// ***
//	NSLog(@"curcontext: %f", [getcur timeIntervalSinceDate:begin]);// ***
	
	CGContextTranslateCTM( ctxt, rect.size.width/2, rect.size.height/2 );
	CGContextRotateCTM( ctxt, angle );
	CGContextTranslateCTM( ctxt, -rect.size.width/2, -rect.size.height/2 );
	
//	NSDate *transform = [NSDate date];// ***
//	NSLog(@"transforms: %f", [transform timeIntervalSinceDate:getcur]);// ***
	
    CGContextDrawImage(ctxt, rect, self.CGImage);
	
//	NSDate *drawImage = [NSDate date];// ***
//	NSLog(@"draw Image: %f", [drawImage timeIntervalSinceDate:transform]);// ***
	
    copy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
	
//	NSDate *getCurrentContext = [NSDate date];// ***
//	NSLog(@"Get Image : %f", [getCurrentContext timeIntervalSinceDate:transform]);// ***
	
    return copy;
}

@end
