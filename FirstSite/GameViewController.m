//
//  GameViewController.m
//  FirstSite
//
//  Created by Daren David Taylor on 17/05/2014.
//  Copyright (c) 2014 Sparx. All rights reserved.
//

#import "GameViewController.h"
#import "ClefBlock.h"
#import "NoteBlock.h"
#import "Note.h"
#import "Excercise.h"
#import "Recorder.h"
#import "MarkerBlock.h"

@interface GameViewController () <RecorderDelegate>

@property (nonatomic, assign) NSUInteger currentNoteIndex;

@end

@implementation GameViewController {
    NSUInteger _runningX;
    

    
    Recorder *_recorder;
    
    MarkerBlock *_markerBlock;
    
    
    CGFloat _clefWidth;
    CGFloat _noteWidth;
    
}

- (void)setCurrentNoteIndex:(NSUInteger)currentNoteIndex
{
    _currentNoteIndex = currentNoteIndex;
    
    CGFloat x = _clefWidth;
    
    x+=(_currentNoteIndex*_noteWidth);
    
    
    CGRect rect = _markerBlock.frame;
    rect.origin.x = x;
    _markerBlock.frame = rect;
}

- (IBAction)moveMarkerBlock:(id)sender
{
    self.currentNoteIndex++;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    _markerBlock = [[[NSBundle mainBundle] loadNibNamed:@"MarkerBlock" owner:self options:nil] lastObject];
    
    [self.view addSubview:_markerBlock];
    
    _runningX = 0;
    
    _clefWidth = [self addClefBlock];
    
    [self.excercise.noteSequence enumerateObjectsUsingBlock:^(Note *note, NSUInteger idx, BOOL *stop) {
        _noteWidth = [self addNoteBlock:note];
    }];
    
    _recorder = [[Recorder alloc] init];
    _recorder.delegate = self;
    
    [self.view bringSubviewToFront:_markerBlock];
    
    self.currentNoteIndex = 0;
}

- (CGFloat)addBlock:(UIView *)view
{
    CGRect rect = view.frame;
    rect.origin.x = _runningX;
    view.frame = rect;
    
    _runningX += rect.size.width;
    
    [self.view addSubview:view];
    
    return rect.size.width;
}

- (CGFloat)addClefBlock
{
    ClefBlock *clefBlock = [[[NSBundle mainBundle] loadNibNamed:@"ClefBlock" owner:self options:nil] lastObject];
    
    clefBlock.clef = _excercise.clef;
    
    return [self addBlock:clefBlock];
}

- (CGFloat)addNoteBlock:(Note *)note
{
    NoteBlock *noteBlock = [[[NSBundle mainBundle] loadNibNamed:@"NoteBlock" owner:self options:nil] lastObject];
    
    noteBlock.clef = _excercise.clef;
    
    CGFloat width = [self addBlock:noteBlock];
    
    noteBlock.note = note;
    
    return width;
}

- (void)recordedFreq:(float)freq;
{
    if (freq > 100.0f)  // to avoid environmental noise
    {
        double toneStep = pow(2.0, 1.0/12.0);
        double baseFreq = 440.0;
        
        int noteIndex = (int) round(log(freq/baseFreq) / log(toneStep));
        NSUInteger detectedOctave = (57 + noteIndex) / 12;
        NSUInteger detectedNote = (57 + noteIndex) % 12;
        
    //    NSLog(@"--------------");
    //    NSLog(@"detected frequency:%f", freq);
    //    NSLog(@"note index:%d", noteIndex);
    //    NSLog(@"detected octave:%d", detectedOctave);
    //    NSLog(@"detected note:%d", detectedNote);
        
        Note *note = [[Note alloc] init];
        
        note.octave = detectedOctave;
        note.note = @[@"C", @"C", @"D", @"D", @"E", @"F",@"F", @"G",@"G", @"A",@"A", @"B"][detectedNote];
        
        
        switch (detectedNote)
        
        {
            case 1:
            case 3:
            case 6:
            case 8:
            case 10:
                note.accidental = AccidentalSharp;
                break;
        }
        
        
        NSLog(@"detected note = %@ : reference note = %@", note, _excercise.noteSequence[_currentNoteIndex]);
        
        
        if ([note isEqual:_excercise.noteSequence[_currentNoteIndex]]) {
            
             dispatch_async(dispatch_get_main_queue(), ^{
                 
                 if(self.currentNoteIndex != _excercise.noteSequence.count-1) {
                     self.currentNoteIndex++;
                 }
                 else {
                     self.currentNoteIndex = 0;
                 }
             });
        }
    }
}

@end
