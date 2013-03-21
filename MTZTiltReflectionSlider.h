//
//  MTZTiltReflectionSlider.h
//  MTZTiltReflectionSlider
//
//  Created by Matt Zanchelli on 3/20/13.
//  Copyright (c) 2013 Matt Zanchelli. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MTZTiltReflectionSlider : UISlider

@property (nonatomic, strong) UIImage *baseImage;

- (void)stopMotionDetection;
- (void)resumeMotionDetection;

@end
