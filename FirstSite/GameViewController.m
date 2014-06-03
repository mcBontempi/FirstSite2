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

@interface GameViewController () <RecorderDelegate>
@end

@implementation GameViewController {
    NSUInteger _runningX;
    
    Excercise *_excercise;
    
    Recorder *_recorder;
    
    // Game State
    NSUInteger _currentNoteIndex;
    Note *_currentNote;
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _runningX = 0;
    
    _excercise = [[Excercise alloc] init];
    _excercise.clef = ClefBass;
    
    [self addClefBlock];
    
    enum Accidental accidental = AccidentalNone;
    
    for (NSUInteger i = 4; i<5; i++){
        
        for (NSUInteger n = 0 ; n < 2 ; n++) {
            
            Note *note = [[Note alloc] init];
            
            note.octave = i;
            note.note = @[@"C", @"D", @"E", @"F", @"G", @"A", @"B"][n];
            note.accidental = accidental++;
            
            if(accidental == AccidentalSharp) {
                
                accidental = AccidentalNone;
            }
            
            [self addNoteBlock:note];
        }
    }
    
    _recorder = [[Recorder alloc] init];
    _recorder.delegate = self;
    
}

- (void)addBlock:(UIView *)view
{
    if (_runningX > 1000) {
        _runningX = 0;
    }
    
    CGRect rect = view.frame;
    rect.origin.x = _runningX;
    view.frame = rect;
    
    _runningX += rect.size.width;
    
    [self.view.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        //     [obj removeFromSuperview];
        
    }];
    
    self.view.backgroundColor = [UIColor greenColor];
    
    [self.view addSubview:view];
}

- (void)addClefBlock
{
    ClefBlock *clefBlock = [[[NSBundle mainBundle] loadNibNamed:@"ClefBlock" owner:self options:nil] lastObject];
    
    [self addBlock:clefBlock];
}

- (void)addNoteBlock:(Note *)note
{
    NoteBlock *noteBlock = [[[NSBundle mainBundle] loadNibNamed:@"NoteBlock" owner:self options:nil] lastObject];
    
    noteBlock.clef = _excercise.clef;
    
    [self addBlock:noteBlock];
    
    noteBlock.note = note;
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
        
        NSLog(@"--------------");
        NSLog(@"detected frequency:%f", freq);
        NSLog(@"note index:%d", noteIndex);
        NSLog(@"detected octave:%d", detectedOctave);
        NSLog(@"detected note:%d", detectedNote);
        
        Note *note = [[Note alloc] init];
        
        note.octave = detectedOctave;
        note.note = @[@"C", @"C", @"D", @"D", @"E", @"F",@"F", @"G",@"G", @"A",@"A", @"B"][detectedNote];
        
        switch (noteIndex)
        
        {
            case 1:
            case 3:
            case 6:
            case 8:
            case 10:
                note.accidental = AccidentalSharp;
                break;
        }
        
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self addNoteBlock:note];
        });
        
        
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
        
        
    }
}

@end
