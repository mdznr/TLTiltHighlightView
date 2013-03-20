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
#import "GZCoreGraphicsAdditions.h"

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
													[self deviceMotionDidUpdate:motionData];
												}];
	}
}

- (void)stopMotionDetection
{
	if ( self.motionManager ) {
		[self.motionManager stopDeviceMotionUpdates];
		self.motionManager = nil;
	}
}

- (void)resumeMotionDetection
{
	if ( self.motionManager != nil ) {
		NSLog(@"Motion is already active.");
		return;
	}
	
	// Set up a motion manager and start motion updates, calling deviceMotionDidUpdate: when updated.
	self.motionManager = [[CMMotionManager alloc] init];
	self.motionManager.deviceMotionUpdateInterval = 1.0/60.0;
	
	if ( self.motionManager.deviceMotionAvailable ) {
		NSOperationQueue *queue = [NSOperationQueue currentQueue];
		[self.motionManager startDeviceMotionUpdatesToQueue:queue
												withHandler:^ (CMDeviceMotion *motionData, NSError *error) {
													[self deviceMotionDidUpdate:motionData];
												}];
	}
}

#pragma mark CoreMotion Methods

- (void)deviceMotionDidUpdate:(CMDeviceMotion *)deviceMotion
{
	// Don't redraw if the change in motion wasn't enough.
	if ( ABS(deviceMotion.attitude.roll - _previousRoll) < 0.003315727981f ||
		ABS(deviceMotion.attitude.pitch - _previousPitch) < 0.003315727981f ) {
		return;
	}
	
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
	// Mask it to a circle (radius is half the width)
	CALayer *imageLayer = self.layer;
	[imageLayer setCornerRadius:rect.size.width/2];
	[imageLayer setMasksToBounds:YES];
	
	// Get the x and y motinos
	//	x and y vary from -1 to 1
	CGFloat x = -_xMotion;
	CGFloat y =  _yMotion;
	
	// Rotate the base to get proper lighting on top and bottom
	[[_base squareImageRotatedByRadians:(x)] drawInRect:rect];
	
	// Empty float value to be used in modff
	float *f = malloc(sizeof(float));
	
	// Get the first shine and draw it
	UIImage *shineX = [UIImage imageWithSize:rect.size drawing:^(CGContextRef context, CGRect drawingRect)
					   {
						   CGContextDrawConicalGradientWithDictionary(context, drawingRect,
								@{@(modff((0.09375 + y/4 + x/8 + 1), f)): [UIColor colorWithWhite:0.40f alpha:1.0f],
								  @(modff((0.25000 + y/4 + x/8 + 1), f)): [UIColor colorWithWhite:0.90f alpha:1.0f],
								  @(modff((0.40625 + y/4 + x/8 + 1), f)): [UIColor colorWithWhite:0.40f alpha:1.0f],
								  @(modff((0.59375 + y/4 + x/8 + 1), f)): [UIColor colorWithWhite:0.40f alpha:1.0f],
								  @(modff((0.75000 + y/4 + x/8 + 1), f)): [UIColor colorWithWhite:0.90f alpha:1.0f],
								  @(modff((0.90625 + y/4 + x/8 + 1), f)): [UIColor colorWithWhite:0.40f alpha:1.0f]});
					   }];
	[shineX drawInRect:rect blendMode:kCGBlendModeOverlay alpha:(1.0f - x)];
	
	// Get the second shine and draw it
	UIImage *shineY = [UIImage imageWithSize:rect.size drawing:^(CGContextRef context, CGRect drawingRect)
					   {
						   CGContextDrawConicalGradientWithDictionary(context, drawingRect,
								@{@(modff((0.09375 - y/4 + x/8 + 1), f)): [UIColor colorWithWhite:0.40f alpha:1.0f],
								  @(modff((0.25000 - y/4 + x/8 + 1), f)): [UIColor colorWithWhite:0.90f alpha:1.0f],
								  @(modff((0.40625 - y/4 + x/8 + 1), f)): [UIColor colorWithWhite:0.40f alpha:1.0f],
								  @(modff((0.59375 - y/4 + x/8 + 1), f)): [UIColor colorWithWhite:0.40f alpha:1.0f],
								  @(modff((0.75000 - y/4 + x/8 + 1), f)): [UIColor colorWithWhite:0.90f alpha:1.0f],
								  @(modff((0.90625 - y/4 + x/8 + 1), f)): [UIColor colorWithWhite:0.40f alpha:1.0f]});
					   }];
	[shineY drawInRect:rect blendMode:kCGBlendModeOverlay alpha:(1.0f + x)];
}

@end
