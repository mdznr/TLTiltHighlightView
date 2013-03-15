//
//  MTZTiltShadowView.h
//  MTZTiltShadowView
//
//  Modifed from code created by Ash Furrow on 2013-03-05.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//  Copyright (c) 2013 Matt Zanchelli. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <CoreMotion/CoreMotion.h>

#import "MTZTiltShadowView.h"

#define LOWEST_FPS_ALLOWED 3

// Private properties.
@interface MTZTiltShadowView ()

// Our motion manager.
@property (nonatomic, strong) CMMotionManager *motionManager;

// Last time checked accelerometer
@property (nonatomic, strong) NSDate *lastTimeCheckedAccelerometer;

@end

@implementation MTZTiltShadowView

@synthesize shadowColor = _shadowColor;

#pragma mark - Public Initializers

// Allows support for using instances loaded from nibs or storyboards.
- (id)initWithCoder:(NSCoder *)aCoder
{
    if (!(self = [super initWithCoder:aCoder])) return nil;
    
    [self setup];
    
    return self;
}

// Allows support for using instances instantiated programatically.
- (id)initWithFrame:(CGRect)frame
{
    if (!(self = [super initWithFrame:frame])) return nil;
    
    [self setup];
    
    return self;
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
	// Some defaults that look nice
	self.maxShadowDistance = 1.25f;
	self.maxBlurRadius = 0.5f;
	_shadowColor = [UIColor colorWithWhite:0.0f alpha:0.33f];
}

- (void)awakeFromNib
{
	[super awakeFromNib];
	
	// Set up the mask
	[self setupMask];
	
	// Set up the shadow
	[self setupShadow];
	
    // Set up our motion updates
    [self setupMotionDetection];
}

- (void)setupMask
{
	UIImage *_maskingImage = self.imageView.image;
	CALayer *_maskingLayer = [CALayer layer];
	_maskingLayer.frame = self.bounds;
	[_maskingLayer setContents:(id)[_maskingImage CGImage]];
	[self.imageView.layer setMask:_maskingLayer];
    self.imageView.layer.masksToBounds = YES;
	
    CALayer *containerLayer = [CALayer layer];
    [containerLayer addSublayer:self.imageView.layer];
    [self.layer addSublayer:containerLayer];
}

// Creates the shadow and sets up some default properties
- (void)setupShadow
{
	[self setClipsToBounds:NO];
	[self.layer setShadowColor:[_shadowColor CGColor]];
	[self.layer setShadowOffset:CGSizeMake(0, 0)];
	[self.layer setShadowRadius:1.0f];
	[self.layer setShadowOpacity:1.0f];
	
//	[self.layer setShadowPath:[[UIBezierPath bezierPathWithRect:self.bounds] CGPath]];
//	bezierPathWithRoundedRect:cornerRadius:
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
    CGFloat x = 0.0f;
	CGFloat y = 0.0f;
	
	// We need to account for the interface's orientation when calculating the relative roll.
    switch ( [[UIApplication sharedApplication] statusBarOrientation] ) {
        case UIInterfaceOrientationPortrait:
            x =  sinf(deviceMotion.attitude.roll);
			y =  sinf(deviceMotion.attitude.pitch);
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            x = -sinf(deviceMotion.attitude.roll);
			y = -sinf(deviceMotion.attitude.pitch);
            break;
        case UIInterfaceOrientationLandscapeLeft:
			x = -sinf(deviceMotion.attitude.pitch);
            y =  sinf(deviceMotion.attitude.roll);
            break;
        case UIInterfaceOrientationLandscapeRight:
			x =  sinf(deviceMotion.attitude.pitch);
            y = -sinf(deviceMotion.attitude.roll);
            break;
    }
	
	const CGFloat distance = self.maxShadowDistance;
	CGSize shadowOffset = CGSizeMake( (x*distance), (y*distance) );
	
	const CGFloat blur = self.maxBlurRadius;
	double triangle = sqrt( (x*x) + (y*y) );
	CGFloat shadowRadius = triangle * blur;
	
	// Find the current time
	NSDate *now = [NSDate date];
	
	// Get the time difference (in seconds)
	NSTimeInterval timeDifference = [now timeIntervalSinceDate:_lastTimeCheckedAccelerometer];
	
	// Update lastTimeCheckedAccelerometer to current time
	_lastTimeCheckedAccelerometer = now;

	double lowestFrameRate = 1 / LOWEST_FPS_ALLOWED;
	
	// If the time difference is greater than the desiredFPS
	if ( timeDifference > lowestFrameRate ) {
		CABasicAnimation *moveHeight = [CABasicAnimation animationWithKeyPath:@"shadowOffset.height"];
		[moveHeight setFromValue:[NSNumber numberWithFloat:self.layer.shadowOffset.height]];
		[moveHeight setToValue:[NSNumber numberWithFloat:shadowOffset.height]];
		[moveHeight setDuration:lowestFrameRate];
		moveHeight.autoreverses = YES;
		
		CABasicAnimation *moveWidth  = [CABasicAnimation animationWithKeyPath:@"shadowOffset.width"];
		[moveWidth setFromValue:[NSNumber numberWithFloat:self.layer.shadowOffset.width]];
		[moveWidth setToValue:[NSNumber numberWithFloat:shadowOffset.width]];
		[moveWidth setDuration:lowestFrameRate];
		moveWidth.autoreverses = YES;
		
		CABasicAnimation *shadowUpdate = [CABasicAnimation animationWithKeyPath:@"shadowRadius" ];
		shadowUpdate.delegate = self;
		[shadowUpdate setFromValue:[NSNumber numberWithFloat:self.layer.shadowRadius]];
		[shadowUpdate setToValue:[NSNumber numberWithFloat:shadowRadius]];
		[shadowUpdate setDuration:lowestFrameRate];
		shadowUpdate.autoreverses = YES;
		
		// Add animation to a specific element's layer. Must be called after the element is displayed.
		[self.layer addAnimation:shadowUpdate forKey:@"shadowRadius"];
		[self.layer addAnimation:moveHeight forKey:@"shadowOffset.height"];
		[self.layer addAnimation:moveWidth forKey:@"shadowOffset.width"];
	} else {
		[self.layer setShadowOffset:shadowOffset];
		[self.layer setShadowRadius:shadowRadius];
	}
}

@end
