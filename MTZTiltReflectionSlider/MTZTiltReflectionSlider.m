//
//  MTZTiltReflectionSlider.m
//  MTZTiltReflectionSlider
//
//  Created by Matt Zanchelli on 3/20/13.
//  Copyright (c) 2013 Matt Zanchelli. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <CoreMotion/CoreMotion.h>

#import "MTZTiltReflectionSlider.h"
#import "GZCoreGraphicsAdditions.h"
#import "UIImage+Shadow.h"
#import "UIImage+Rotate.h"
#import "UISlider+ForAllStates.h"

// Private properties.
@interface MTZTiltReflectionSlider ()

// Our motion manager.
@property (nonatomic, strong) CMMotionManager *motionManager;

@property CGFloat xMotion;
@property CGFloat yMotion;

@property double previousRoll;
@property double previousPitch;

@property UIImage *baseImage;

@property UIImage *shine;

- (UIImage *)createKnobWithBase:(UIImage *)base
					   andShine:(UIImage *)shine1 withAlpha:(CGFloat)alpha1
					   andShine:(UIImage *)shine2 withAlpha:(CGFloat)alpha2;

@end

@implementation MTZTiltReflectionSlider

#pragma mark - Public Initializers

// Allows support for using instances loaded from nibs or storyboards.
- (id)initWithCoder:(NSCoder *)aCoder
{
    self = [super initWithCoder:aCoder];
    if ( self ) {
		[self setSize:MTZTiltReflectionSliderSizeRegular];
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if ( self ) {
		[self setSize:MTZTiltReflectionSliderSizeRegular];
        [self setup];
    }
    return self;
}

- (id)initWithSliderSize:(MTZTiltReflectionSliderSize)sliderSize
{
	self = [super init];
	if ( self ) {
		[self setSize:sliderSize];
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
	// Set the slider track images
	[self setMinimumTrackImage:[[UIImage imageNamed:@"MTZTiltReflectionSliderTrackFill"]
								resizableImageWithCapInsets:UIEdgeInsetsMake(0, 6, 0, 0)]
					  forState:UIControlStateNormal];
	
	[self setMaximumTrackImage:[[UIImage imageNamed:@"MTZTiltReflectionSliderTrackEmpty"]
								resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 6)]
					  forState:UIControlStateNormal];
	
	// Set up our motion updates
	[self setupMotionDetection];
}

- (void)setSize:(MTZTiltReflectionSliderSize)size
{
	_size = size;
	
	// Set the base image
	switch ( _size ) {
		case MTZTiltReflectionSliderSizeRegular:
			_baseImage = [UIImage imageNamed:@"MTZTiltReflectionSliderKnobBase"];
			_shine = [UIImage imageNamed:@"MTZTiltReflectionSliderShine.jpg"];
			break;
		case MTZTiltReflectionSliderSizeSmall:
			_baseImage = [UIImage imageNamed:@"MTZTiltReflectionSliderKnobBase-Small"];
			_shine = [UIImage imageNamed:@"MTZTiltReflectionSliderShine-Small.jpg"];
			break;
		default:
			break;
	}
	
	[self updateButtonImageForRoll:_xMotion pitch:_yMotion];
}

- (CGRect)trackRectForBounds:(CGRect)bounds
{
	// Set the correct bounds for the track.
	return (CGRect){0, 0, bounds.size.width, 10};
}

// Starts the Motion Detection
- (void)setupMotionDetection
{
    NSAssert(self.motionManager == nil, @"Motion manager being set up more than once.");
    
    // Set up a motion manager and start motion updates, calling deviceMotionDidUpdate: when updated.
    self.motionManager = [[CMMotionManager alloc] init];
	self.motionManager.deviceMotionUpdateInterval = 1.0/60.0;
	
	if ( self.motionManager.deviceMotionAvailable ) {
		NSOperationQueue *queue = [NSOperationQueue currentQueue];
		[self.motionManager startDeviceMotionUpdatesToQueue:queue
												withHandler:^(CMDeviceMotion *motionData, NSError *error) {
													[self deviceMotionDidUpdate:motionData];
												}];
	}
	
	// Need to call once for the initial load
    
    [self updateButtonImageForRoll:0 pitch:0];
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
												withHandler:^(CMDeviceMotion *motionData, NSError *error) {
													[self deviceMotionDidUpdate:motionData];
												}];
	}
}

#pragma mark CoreMotion Methods

- (void)deviceMotionDidUpdate:(CMDeviceMotion *)deviceMotion
{
	// Don't redraw if the change in motion wasn't enough.
	if ( ABS(deviceMotion.attitude.roll - _previousRoll) < 0.003315f ||
		 ABS(deviceMotion.attitude.pitch - _previousPitch) < 0.003315f ) {
		return;
	}
	
	_previousRoll = deviceMotion.attitude.roll;
	_previousPitch = deviceMotion.attitude.pitch;
	
    // Called when the deviceMotion property of our CMMotionManger updates.
    // Recalculates the gradient locations.
    
    // We need to account for the interface's orientation when calculating the relative roll.
    CGFloat roll = 0.0f;
    CGFloat pitch = 0.0f;
    switch ( [[UIApplication sharedApplication] statusBarOrientation] ) {
        case UIInterfaceOrientationPortrait:
            roll = deviceMotion.attitude.roll;
            pitch = deviceMotion.attitude.pitch;
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            roll = -deviceMotion.attitude.roll;
            pitch = -deviceMotion.attitude.pitch;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            roll = -deviceMotion.attitude.pitch;
            pitch = -deviceMotion.attitude.roll;
            break;
        case UIInterfaceOrientationLandscapeRight:
            roll = deviceMotion.attitude.pitch;
            pitch = deviceMotion.attitude.roll;
            break;
    }
	
    // Update the image with the calculated values.
    [self updateButtonImageForRoll:roll pitch:pitch];
}

- (UIImage *)createKnobWithBase:(UIImage *)base
					   andShine:(UIImage *)shine1 withAlpha:(CGFloat)alpha1
					   andShine:(UIImage *)shine2 withAlpha:(CGFloat)alpha2
{	
	// Made masking made possible with help from Tim Davies https://github.com/tmdvs
	CGFloat scale = [[UIScreen mainScreen] scale];
	CGSize imageSize = base.size;
	
	CALayer *circle = [[CALayer alloc] init];
	circle.cornerRadius = (imageSize.height) / 2;
	circle.masksToBounds = YES;
	circle.contentsScale = scale;
	circle.frame = CGRectMake(0, 0, imageSize.width, imageSize.height);
	
	// Draw the base and shines
	UIGraphicsBeginImageContextWithOptions(imageSize, NO, scale);
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSaveGState(context);
	
	CGPoint point = CGPointMake(0, 0);
	[base drawAtPoint:point];
	[shine1 drawAtPoint:point blendMode:kCGBlendModeOverlay alpha:alpha1];
	[shine2 drawAtPoint:point blendMode:kCGBlendModeOverlay alpha:alpha2];
	CGContextRestoreGState(context);
	
	UIImage *knobImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	// Draw the final image
	UIGraphicsBeginImageContextWithOptions(imageSize, NO, scale);
	circle.contents = (id)knobImage.CGImage;
	context = UIGraphicsGetCurrentContext();
	
	CGContextSaveGState(context);
	[circle renderInContext:context];
	CGContextRestoreGState(context);
	
	UIImage *outputImage = [UIImage imageWithCGImage:UIGraphicsGetImageFromCurrentImageContext().CGImage
											   scale:scale
										 orientation:UIImageOrientationUp];
	
	UIGraphicsEndImageContext();
	
	return outputImage;
}

// Uppdates the Thumb (knob) image for the given roll and pitch
-(void)updateButtonImageForRoll:(CGFloat)roll pitch:(CGFloat)pitch
{
	
	// Get the x and y motions
	// x and y vary from -1 to 1
	CGFloat x = roll;
	CGFloat y = pitch;
	
	UIImage *shineX = [_shine imageWithRotation:(M_PI_4 - x + y)];
	UIImage *shineY = [_shine imageWithRotation:(M_PI_4 - x - y)];
	
	// Create the image
	UIImage *knobImage = [self createKnobWithBase:_baseImage
										 andShine:shineX withAlpha:(1.0f - x)
										 andShine:shineY withAlpha:(1.0f + x)];
	knobImage = [knobImage imageWithShadowOfSize:2];
	// possible to combine the above two methods?
	
	// Set it as the thumbImage for all states
    [self setThumbImageForAllStates:knobImage];
}

@end

