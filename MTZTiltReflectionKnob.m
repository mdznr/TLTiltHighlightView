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
#import "UIImage+Rotate.h"

// Private properties.
@interface MTZTiltReflectionKnob ()

// Our motion manager.
@property (nonatomic, strong) CMMotionManager *motionManager;

@property (nonatomic, strong) UIImage *base;
@property (nonatomic, strong) UIImage *shineX;
@property (nonatomic, strong) UIImage *shineY;

@property (nonatomic, strong) UIImage *currentBase;
@property (nonatomic, strong) UIImage *currentShineX;
@property (nonatomic, strong) UIImage *currentShineY;

@property CGFloat xMotion;
@property CGFloat yMotion;

@property double previousRoll;
@property double previousPitch;

@property (nonatomic, strong) NSDate *drawRectTimeStamp;

@end

@implementation MTZTiltReflectionKnob

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
    // Drawing code
	_shineX = [UIImage imageNamed:@"SliderKnobShine"];
	_shineY = [UIImage imageNamed:@"SliderKnobShine"];
	_base   = [UIImage imageNamed:@"SliderKnobBase"];
	
    // Set up our motion updates
    [self setupMotionDetection];
}

// Starts the
- (void)setupMotionDetection
{
    NSAssert(self.motionManager == nil, @"Motion manager being set up more than once.");
    
    // Set up a motion manager and start motion updates, calling deviceMotionDidUpdate: when updated.
    self.motionManager = [[CMMotionManager alloc] init];
	self.motionManager.deviceMotionUpdateInterval = 1.0/60.0;
	
	if ( self.motionManager.deviceMotionAvailable ) {
		NSOperationQueue *queue = [NSOperationQueue currentQueue];
		[self.motionManager startDeviceMotionUpdatesToQueue:queue
												withHandler:^ (CMDeviceMotion *motionData, NSError *error) {
//													CMAttitude *attitude = motionData.attitude;
													[self deviceMotionDidUpdate:motionData];
												}];
	}
	
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
	// Don't redraw if the change in motion wasn't enough.
//	2*pi*24 = 150.79644737
//	1/ANS = 0.006631455962
//	ANS/2 = 0.003315727981
	if ( ABS(deviceMotion.attitude.roll - _previousRoll) < 0.003315727981f ||
		ABS(deviceMotion.attitude.pitch - _previousPitch) < 0.003315727981f ) {
		return;
	}
	
//	NSLog(@"roll: %f pitch: %f", deviceMotion.attitude.roll, deviceMotion.attitude.pitch);
	
	_previousRoll = deviceMotion.attitude.roll;
	_previousPitch = deviceMotion.attitude.pitch;
	
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
	
	[self setNeedsDisplay];
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
//	NSDate *now = [NSDate date];
	
	CGFloat x = -_xMotion * M_PI_4;
	CGFloat y =  _yMotion * M_PI_2;
	
	UIImage *shineX = [_shineX squareImageRotatedByRadians:(M_PI_4 +  y+x)];
	UIImage *shineY = [_shineY squareImageRotatedByRadians:(M_PI_4 + -y+x)];
	
//	UIImage *shineX = [UIImage imageWithCIImage:[_shineX.CIImage imageByApplyingTransform:CGAffineTransformMakeRotation(M_PI_4 +  y+x)]];
//	UIImage *shineY = [UIImage imageWithCIImage:[_shineY.CIImage imageByApplyingTransform:CGAffineTransformMakeRotation(M_PI_4 + -y+x)]];
	
//	base = [base squareImageRotatedByRadians:(x)];
	[_base drawInRect:rect];
	
//	[shineX drawInRect:rect];
	[shineX drawInRect:rect blendMode:kCGBlendModeOverlay alpha:(1.0f - x)];
	
//	[shineY drawInRect:rect];
	[shineY drawInRect:rect blendMode:kCGBlendModeOverlay alpha:(1.0f + x)];
	
//	NSLog(@"drawRect duration: %f", [now timeIntervalSinceNow]);
}

@end
