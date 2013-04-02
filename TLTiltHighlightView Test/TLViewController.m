//
//  TLViewController.m
//  TLTiltHighlightView
//
//  Created by Ash Furrow on 2013-03-05.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import "TLViewController.h"

#import "TLTiltHighlightView.h"
#import "MTZTiltShadowView.h"
#import "MTZTiltReflectionSlider.h"

#import <MediaPlayer/MediaPlayer.h>

@interface TLViewController ()

@property (strong, nonatomic) IBOutlet MTZTiltReflectionSlider *slider;
@property (strong, nonatomic) IBOutlet MTZTiltReflectionSlider *smallSlider;

@end

@implementation TLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	[_slider setSize:MTZTiltReflectionSliderSizeRegular];
	[_smallSlider setSize:MTZTiltReflectionSliderSizeSmall];
	
	MPVolumeView *volumeView = [[MPVolumeView alloc] initWithFrame: CGRectZero];
    [self.view addSubview: volumeView];
	
	MPMusicPlayerController *musicPlayer = [MPMusicPlayerController applicationMusicPlayer];
	[_slider setValue:musicPlayer.volume animated:NO];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)becomeInactive
{
	[_slider stopMotionDetection];
	[_smallSlider stopMotionDetection];
}

- (void)becomeActive
{
	[_slider resumeMotionDetection];
	[_smallSlider resumeMotionDetection];
}

- (void)volumeDidChangeTo:(float)volume
{
	[_slider setValue:volume animated:YES];
}

- (IBAction)sliderChanged:(UISlider *)sender
{
	MPMusicPlayerController *musicPlayer = [MPMusicPlayerController applicationMusicPlayer];
	[musicPlayer setVolume:sender.value];
}



@end
