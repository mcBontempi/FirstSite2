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

@implementation GameViewController {
    NSUInteger _runningX;
}

- (void)viewDidAppear:(BOOL)animated

{
    [super viewDidAppear:animated];
    _runningX = 0;
    
    [self addClefBlock];
    
    for (NSUInteger i = 0; i<10; i++){
        
        for (NSUInteger n = 0 ; n < 7 ; n++) {
        
        Note *note = [[Note alloc] init];
        
        note.octave = i;
        note.note = @[@"C", @"D", @"E", @"F", @"G", @"A", @"B"][n];
        note.accidental = AccedentalNone;
        
        [self addNoteBlock:note];
        }
    }
}

- (void)addBlock:(UIView *)view
{
    CGRect rect = view.frame;
    rect.origin.x = _runningX;
    view.frame = rect;
    
    _runningX += rect.size.width;
    
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
    
    [self addBlock:noteBlock];
    
    noteBlock.note = note;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
