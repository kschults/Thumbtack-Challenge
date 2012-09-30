//
//  KTCCoordinateButton.h
//  Thumbtack Challenge
//
//  Created by Karl Schults on 9/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KTCCoordinateButton : UIButton

@property (nonatomic, unsafe_unretained) UILabel* textLabel;

@property (nonatomic) NSInteger x;
@property (nonatomic) NSInteger y;
@property (nonatomic) BOOL isMine;
@property (nonatomic) BOOL isRevealed;

- (void)reset;

@end
