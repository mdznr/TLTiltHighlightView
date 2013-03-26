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

@end
