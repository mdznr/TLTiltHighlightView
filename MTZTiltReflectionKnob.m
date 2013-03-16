//
//  MTZTiltReflectionKnob.h
//  MTZTiltReflectionKnob
//
//  Created by Matt on 3/15/13.
//  Copyright (c) 2013 Matt Zanchelli. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <CoreMotion/CoreMotion.h>

#import "MTZTiltReflectionKnob.h"
#import "UIImage+Extensions.h"

// Private properties.
@interface MTZTiltReflectionKnob ()

@property (nonatomic, strong) UIImageView *base;
@property (nonatomic, strong) UIImageView *shineX;
@property (nonatomic, strong) UIImageView *shineY;

@property CGFloat xMotion;
@property CGFloat yMotion;

// Our motion manager.
@property (nonatomic, strong) CMMotionManager *motionManager;

@end

@implementation MTZTiltReflectionKnob

// Synthesize

#pragma mark - Public Initializers

// Allows support for using instances loaded from nibs or storyboards.
- (id)initWithCoder:(NSCoder *)aCoder
{
    self = [super initWithCoder:aCoder];
    if ( self ) {
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if ( self ) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
	[super awakeFromNib];
}

// We need to stop our motionManager from continuing to update once our instance is deallocated.
- (void)dealloc
{
    [self.motionManager stopAccelerometerUpdates];
}

#pragma mark - Private methods

// Sets up the initial state of the view.
- (void)setup
{	
	[self addSubview:_base];
	[self addSubview:_shineX];
	[self addSubview:_shineY];
	
    // Set up our motion updates
    [self setupMotionDetection];
}

// Starts the
- (void)setupMotionDetection
{
    NSAssert(self.motionManager == nil, @"Motion manager being set up more than once.");
    
    // Set up a motion manager and start motion updates, calling deviceMotionDidUpdate: when updated.
    self.motionManager = [[CMMotionManager alloc] init];
    
    __weak __typeof(self) weakSelf = self;
    [self.motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion *motion, NSError *error) {
        if ( error ) {
            [weakSelf.motionManager stopDeviceMotionUpdates];
            return;
        }
        [weakSelf deviceMotionDidUpdate:motion];
    }];
}

#pragma mark CoreMotion Methods

- (void)deviceMotionDidUpdate:(CMDeviceMotion *)deviceMotion
{	
	// We need to account for the interface's orientation when calculating the relative roll.
    switch ( [[UIApplication sharedApplication] statusBarOrientation] ) {
        case UIInterfaceOrientationPortrait:
            _xMotion =  sinf(deviceMotion.attitude.roll);
			_yMotion =  sinf(deviceMotion.attitude.pitch);
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            _xMotion = -sinf(deviceMotion.attitude.roll);
			_yMotion = -sinf(deviceMotion.attitude.pitch);
            break;
        case UIInterfaceOrientationLandscapeLeft:
			_xMotion = -sinf(deviceMotion.attitude.pitch);
            _yMotion =  sinf(deviceMotion.attitude.roll);
            break;
        case UIInterfaceOrientationLandscapeRight:
			_xMotion =  sinf(deviceMotion.attitude.pitch);
            _yMotion = -sinf(deviceMotion.attitude.roll);
            break;
    }
	
//	NSLog(@"x: %f y: %f", x, y);
//	_shineY.transform = CGAffineTransformMakeRotation(y *  1.5707963268);
//	_shineX.transform = CGAffineTransformMakeRotation(y * -1.5707963268);
//	_base.transform   = CGAffineTransformMakeRotation(x *  1.5707963268);
	[self setNeedsDisplay];
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
	UIImage *shineX = [UIImage imageNamed:@"SliderKnobShine"];
	UIImage *shineY = [UIImage imageNamed:@"SliderKnobShine"];
	UIImage *base = [UIImage imageNamed:@"SliderKnobBase"];
	
	CGFloat x = -_xMotion * M_PI_4;
	CGFloat y = _yMotion * M_PI_2;
	
	base = [base squareImageRotatedByRadians:(x)];
	[base drawInRect:rect];
	
	shineX = [shineX squareImageRotatedByRadians:(M_PI_4 + y+x)];
	[shineX drawInRect:rect blendMode:kCGBlendModeOverlay alpha:1.0f];
	
	shineY = [shineY squareImageRotatedByRadians:(M_PI_4 + -y+x)];
	[shineY drawInRect:rect blendMode:kCGBlendModeOverlay alpha:1.0f];
}

@end
