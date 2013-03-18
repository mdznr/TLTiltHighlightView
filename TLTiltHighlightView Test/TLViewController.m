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
#import "MTZTiltReflectionKnob.h"

@interface TLViewController ()

@property (strong, nonatomic) IBOutlet MTZTiltReflectionKnob *knob;

@end

@implementation TLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
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
	[_knob stopMotionDetection];
}

- (void)becomeActive
{
	[_knob resumeMotionDetection];
}

@end
