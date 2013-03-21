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

// Private properties.
@interface MTZTiltReflectionSlider ()

// Our motion manager.
@property (nonatomic, strong) CMMotionManager *motionManager;

@property CGFloat xMotion;
@property CGFloat yMotion;

@property double previousRoll;
@property double previousPitch;

- (UIImage *)createKnobWithBase:(UIImage *)base
					   andShine:(UIImage *)shine1 withAlpha:(CGFloat)alpha1
					   andShine:(UIImage *)shine2 withAlpha:(CGFloat)alpha2;

@end

@implementation MTZTiltReflectionSlider

@synthesize baseImage = _baseImage;

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
	[self setMinimumTrackImage:[[UIImage imageNamed:@"higlightedBarBackground"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 4, 0, 0)] forState:UIControlStateNormal];
    [self setMaximumTrackImage:[[UIImage imageNamed:@"trackBackground"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 4)] forState:UIControlStateNormal];
	
    // Drawing code
	_baseImage  = [UIImage imageNamed:@"SliderKnobBaseRegular"];
	
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
	
	UIImage *outputImage = [UIImage imageWithCGImage:UIGraphicsGetImageFromCurrentImageContext().CGImage scale:scale orientation:UIImageOrientationUp];
	
	UIGraphicsEndImageContext();
	
	return outputImage;
}

// Uppdates the Thumb (knob) image for the given roll and pitch
-(void)updateButtonImageForRoll:(CGFloat)roll pitch:(CGFloat)pitch
{
	// Get the x and y motinos
	//	x and y vary from -1 to 1
	CGFloat x = -roll;
	CGFloat y =  pitch;
	
	// Empty float value to be used in modff
	float *f = malloc(sizeof(float));
	
	// Calculate the shines
	UIImage *shineX = [UIImage imageWithSize:_baseImage.size drawing:^(CGContextRef context, CGRect drawingRect)
					   {
						   CGContextDrawConicalGradientWithDictionary(context, drawingRect,
																	  @{@(modff((0.09375 + y/4 + x/8 + 1), f)): [UIColor colorWithWhite:0.40f alpha:1.0f],
																	  @(modff((0.25000 + y/4 + x/8 + 1), f)): [UIColor colorWithWhite:0.90f alpha:1.0f],
																	  @(modff((0.40625 + y/4 + x/8 + 1), f)): [UIColor colorWithWhite:0.40f alpha:1.0f],
																	  @(modff((0.59375 + y/4 + x/8 + 1), f)): [UIColor colorWithWhite:0.40f alpha:1.0f],
																	  @(modff((0.75000 + y/4 + x/8 + 1), f)): [UIColor colorWithWhite:0.90f alpha:1.0f],
																	  @(modff((0.90625 + y/4 + x/8 + 1), f)): [UIColor colorWithWhite:0.40f alpha:1.0f]});
					   }];
	UIImage *shineY = [UIImage imageWithSize:_baseImage.size drawing:^(CGContextRef context, CGRect drawingRect)
					   {
						   CGContextDrawConicalGradientWithDictionary(context, drawingRect,
																	  @{@(modff((0.09375 - y/4 + x/8 + 1), f)): [UIColor colorWithWhite:0.40f alpha:1.0f],
																	  @(modff((0.25000 - y/4 + x/8 + 1), f)): [UIColor colorWithWhite:0.90f alpha:1.0f],
																	  @(modff((0.40625 - y/4 + x/8 + 1), f)): [UIColor colorWithWhite:0.40f alpha:1.0f],
																	  @(modff((0.59375 - y/4 + x/8 + 1), f)): [UIColor colorWithWhite:0.40f alpha:1.0f],
																	  @(modff((0.75000 - y/4 + x/8 + 1), f)): [UIColor colorWithWhite:0.90f alpha:1.0f],
																	  @(modff((0.90625 - y/4 + x/8 + 1), f)): [UIColor colorWithWhite:0.40f alpha:1.0f]});
					   }];
	
	// Create the image
	UIImage *knobImage = [self createKnobWithBase:_baseImage
										 andShine:shineX withAlpha:(1.0f-x)
										 andShine:shineY withAlpha:(1.0f+x)];
	
	// Set it as the thumbImage
    [self setThumbImage:knobImage forState:UIControlStateNormal];
    [self setThumbImage:knobImage forState:UIControlStateSelected];
    [self setThumbImage:knobImage forState:UIControlStateHighlighted];
}

@end

