//
//  MTZTiltShadowView.h
//  MTZTiltShadowView
//
//  Modifed from code created by Ash Furrow on 2013-03-05.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//  Copyright (c) 2013 Matt Zanchelli. All rights reserved.
//

#import <UIKit/UIKit.h>

/// Provides a button with a shadow whose position updates to the current
/// positional attitude of the device.
@interface MTZTiltShadowView : UIButton

/// The colour of the shadow. (Black by default)
@property (nonatomic, strong) UIColor *shadowColor;

@property (nonatomic) CGFloat maxShadowDistance;
@property (nonatomic) CGFloat maxBlurRadius;

@end
