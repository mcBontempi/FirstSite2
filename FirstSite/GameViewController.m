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
#import "IndicatorNoteBlock.h"

@interface GameViewController () <RecorderDelegate>

@property (nonatomic, assign) NSUInteger currentNoteIndex;

@end

const CGFloat verticalOffset = 100;

@implementation GameViewController {
    NSUInteger _runningX;
    
    Recorder *_recorder;
    
    IndicatorNoteBlock *_markerBlock;
    
    CGFloat _clefWidth;
    CGFloat _noteWidth;
    
    NSUInteger _lastDetectedNote;
    
    __weak IBOutlet UILabel *_debugLabel2;
    __weak IBOutlet UILabel *_debugLabel;
}

- (void)setCurrentNoteIndex:(NSUInteger)currentNoteIndex
{
    _currentNoteIndex = currentNoteIndex;
    
    CGFloat x = _clefWidth;
    
    x+=(_currentNoteIndex*_noteWidth);
    
    
    CGRect rect = _markerBlock.frame;
    rect.origin.x = x;
    rect.origin.y = verticalOffset;
    _markerBlock.frame = rect;
}

- (IBAction)moveMarkerBlock:(id)sender
{
    self.currentNoteIndex++;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    _markerBlock = [[[NSBundle mainBundle] loadNibNamed:@"IndicatorNoteBlock" owner:self options:nil] lastObject];
    
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
    rect.origin.y = verticalOffset;
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

- (void)error
{
    _lastDetectedNote = 0;
    
    _debugLabel.alpha = 0.0;
}

- (void)recordedFreq:(float)freq debugText:(NSString *)debug2Text
{
    if(freq
       > 0) {
        
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
        
        
        if (_lastDetectedNote != detectedNote) {
            _lastDetectedNote = detectedNote;
        }
        else {
            
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
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    NSLog(@"note = %@", note);
                    
                    _markerBlock.note = note;
                    _markerBlock.clef = _excercise.clef;
                    
                    _debugLabel.alpha = 1.0;
                    _debugLabel2.alpha = 1.0;
                    
                    _debugLabel.text = [NSString stringWithFormat:@"detected note = %@ : reference note = %@", note, _excercise.noteSequence[_currentNoteIndex]];
                    
                    _debugLabel2.text = debug2Text;
                    
                    [UIView animateWithDuration:20.0 animations:^{_debugLabel.alpha = 0.0; _debugLabel2.alpha=0.0;}];
                    
                });
            }
        }
    }
    
}

@end
