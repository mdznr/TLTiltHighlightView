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

// Private properties.
@interface MTZTiltShadowView ()

// Our gradient layer.
@property (nonatomic, strong) CAGradientLayer *gradientLayer;
// Our motion manager.
@property (nonatomic, strong) CMMotionManager *motionManager;

@end

@implementation MTZTiltShadowView

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
	// Set up the shadow
	[self setupShadow];
    // Set up our motion updates
    [self setupMotionDetection];
}

// Creates the shadow and sets up some default properties
- (void)setupShadow
{
	self.backgroundColor = [UIColor colorWithWhite:1.0f alpha:1.0f];
	self.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.33f];
	
	[self setClipsToBounds:NO];
	[self.layer setShadowColor:[self.shadowColor CGColor]];
	[self.layer setShadowOffset:CGSizeMake(0, 0)];
	[self.layer setShadowRadius:1.0f];
	[self.layer setShadowOpacity:1.0f];
}

// Starts the 
- (void)setupMotionDetection
{
    NSAssert(self.motionManager == nil, @"Motion manager being set up more than once.");
    
    // Set up a motion manager and start motion updates, calling deviceMotionDidUpdate: when updated.
    self.motionManager = [[CMMotionManager alloc] init];
    
    __weak __typeof(self) weakSelf = self;
    [self.motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue]
											withHandler:^(CMDeviceMotion *motion, NSError *error)
	{
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
    switch ( [[UIApplication sharedApplication] statusBarOrientation] )
	{
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
	
	const CGFloat distance = 1.25f;
	[self.layer setShadowOffset:CGSizeMake( (x*distance), (y*distance) )];
	
	const CGFloat blur = 0.75f;
	double triangle = sqrt( (x*x) + (y*y) );
	[self.layer setShadowRadius:triangle * blur];
}

@end
