//
//  KTCCoordinateButton.m
//  Thumbtack Challenge
//
//  Created by Karl Schults on 9/30/12.
//  Copyright (c) 2012. All rights reserved.
//

#import "KTCCoordinateButton.h"

#define MinesweeperGrey [UIColor colorWithRed:.7f green:0.7f blue:0.7f alpha:1.0f]

@interface KTCCoordinateButton()

@property (nonatomic, unsafe_unretained) UIImageView* flagImage; 

@end

@implementation KTCCoordinateButton

@synthesize delegate;
@synthesize textLabel, flagImage;
@synthesize x,y, isMine, isRevealed, isFlagged;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UILabel* l = [[UILabel alloc] initWithFrame:self.bounds];
        [l setTextAlignment:UITextAlignmentCenter];
        [l setBackgroundColor:[UIColor clearColor]];
        [self addSubview:l];
        textLabel = l;
        
        UIImageView* v = [[UIImageView alloc] initWithFrame:self.bounds];
        [v setImage:[UIImage imageNamed:@"flag.gif"]];
        [v setHidden:YES];
        [self addSubview:v];
        flagImage = v;
        
        [self setIsMine:NO];
        [self setIsRevealed:NO];
        [self setBackgroundColor:MinesweeperGrey];
        [self setIsFlagged:NO];
    }
    return self;
}

- (void)dealloc {
    [self setTextLabel:nil];
}

- (void)touchBeganOnButton {
    [delegate touchBeganOnButton:self];
}
- (void)touchEndedOnButton {
    [delegate touchEndedOnButton:self];
}
- (void)handleSingleTap {
    [delegate touchEndedOnButton:self];
    [delegate didSingleTapButton:self];
}
- (void)handleDoubleTap {
    [delegate touchEndedOnButton:self];
    [delegate didDoubleTapButton:self];
}

- (void)setDelegate:(id<KTCCoordinateButtonDelegate>)d {
    delegate = d;
    [self addTarget:self action:@selector(touchBeganOnButton) forControlEvents:UIControlEventTouchDown];
    [self addTarget:self action:@selector(touchEndedOnButton) forControlEvents:UIControlEventTouchUpOutside];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap)];
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap)];
    [singleTap requireGestureRecognizerToFail:doubleTap];
    [doubleTap setNumberOfTapsRequired:2];
    [self addGestureRecognizer:doubleTap];
    [self addGestureRecognizer:singleTap];

}

- (void)reset {
    [self setIsMine:NO];
    [self setIsRevealed:NO];
    [self setIsFlagged:NO];
    [self setUserInteractionEnabled:YES];
    [self setBackgroundColor:MinesweeperGrey];
    [self.textLabel setText:@""];
}

- (void)toggleFlag {
    [self setIsFlagged:!self.isFlagged];
    [flagImage setHidden:!self.isFlagged];
}

@end
