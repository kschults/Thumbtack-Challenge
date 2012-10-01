//
//  KTCMinesweeperController.h
//  Thumbtack Challenge
//
//  Created by Karl Schults on 9/30/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KTCCoordinateButton.h"

//Default parameters
#define defaultSize 10
#define defaultMines 15

@interface KTCMinesweeperController : UIViewController <UIAlertViewDelegate, KTCCoordinateButtonDelegate>

@property (nonatomic) NSInteger buttonsOnASide;
@property (nonatomic) NSInteger numberOfMines;

@property (unsafe_unretained, nonatomic) IBOutlet UIView *buttonsContainer;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *smiley;

- (IBAction)smileyClicked:(id)sender;
//- (IBAction) buttonTouchDownRepeat:(id)sender event:(UIEvent *)event;


@end
