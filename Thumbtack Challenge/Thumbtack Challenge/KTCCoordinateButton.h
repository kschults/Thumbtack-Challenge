//
//  KTCCoordinateButton.h
//  Thumbtack Challenge
//
//  Created by Karl Schults on 9/30/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KTCCoordinateButton;

@protocol KTCCoordinateButtonDelegate <NSObject>
- (void)didDoubleTapButton:(KTCCoordinateButton *)b;
- (void)didSingleTapButton:(KTCCoordinateButton *)b;
- (void)touchBeganOnButton:(KTCCoordinateButton *)b;
- (void)touchEndedOnButton:(KTCCoordinateButton *)b;
@end

@interface KTCCoordinateButton : UIButton {
    id<KTCCoordinateButtonDelegate> _delegate;
}

@property (nonatomic, unsafe_unretained) UILabel* textLabel;

@property (nonatomic, unsafe_unretained) id<KTCCoordinateButtonDelegate> delegate;

@property (nonatomic) NSInteger x;
@property (nonatomic) NSInteger y;
@property (nonatomic) BOOL isMine;
@property (nonatomic) BOOL isRevealed;
@property (nonatomic) BOOL isFlagged;

- (void)reset;
- (void)toggleFlag;

@end
