//
//  MTZTiltShadowView.h
//  MTZTiltShadowView
//
//  Modifed from code created by Ash Furrow on 2013-03-05.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//  Copyright (c) 2013 Matt Zanchelli. All rights reserved.
//

#import <UIKit/UIKit.h>

/// Provides a view with a shadow whose position updates to the current
/// positional attitude of the device.
///
/// The default background colour of this view is opaque white.
@interface MTZTiltShadowView : UIView

/// The highlight colour used in our gradient. (Black by default)
@property (nonatomic, strong) UIColor *shadowColor;

@property (nonatomic) CGFloat maxShadowDistance;
@property (nonatomic) CGFloat maxBlurRadius;

@end
