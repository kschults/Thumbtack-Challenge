//
//  KTCCoordinateButton.m
//  Thumbtack Challenge
//
//  Created by Karl Schults on 9/30/12.
//  Copyright (c) 2012. All rights reserved.
//

#import "KTCCoordinateButton.h"

@implementation KTCCoordinateButton

@synthesize textLabel;
@synthesize x,y, isMine, isRevealed;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UILabel* l = [[UILabel alloc] initWithFrame:self.bounds];
        [l setTextAlignment:UITextAlignmentCenter];
        [l setBackgroundColor:[UIColor clearColor]];
        textLabel = l;
        [self addSubview:l];
        
    }
    return self;
}

- (void)dealloc {
    [self setTextLabel:nil];
}

- (void)reset {
    [self setIsMine:NO];
    [self setIsRevealed:NO];
    [self setUserInteractionEnabled:YES];
    [self setBackgroundColor:[UIColor blackColor]];
    [self.textLabel setText:@""];
}

@end
