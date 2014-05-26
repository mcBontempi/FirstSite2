//
//  ViewController.m
//  FirstSite
//
//  Created by Daren David Taylor on 14/05/2014.
//  Copyright (c) 2014 Sparx. All rights reserved.
//

#import "ViewController.h"
#import "Recorder.h"

@interface ViewController () <RecorderDelegate>
@end

@implementation ViewController {
    Recorder *_recorder;
    
    Note _detectedNote;

}
- (IBAction)stopButtonTapped:(id)sender
{
    [_recorder stopRecording];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    _recorder = [[Recorder alloc] init];
    _recorder.delegate = self;
    _recorder.trackingPitch = YES;
    [_recorder startRecording];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)recordedFreq:(float)freq;
{
    float deltaFreq;
    
    _detectedNote = -1;
    deltaFreq = 0.0f;
    
    if (freq > 100.0f)  // to avoid environmental noise
    {
        double toneStep = pow(2.0, 1.0/12.0);
        double baseFreq = 440.0;
        
        int noteIndex = (int) round(log(freq/baseFreq) / log(toneStep));
        _detectedNote = (120 + noteIndex) % 12;
        
        
        NSLog(@"%d", _detectedNote);
    }
    
}

@end
