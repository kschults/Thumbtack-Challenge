//
//  KTCMinesweeperController.h
//  Thumbtack Challenge
//
//  Created by Karl Schults on 9/30/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <UIKit/UIKit.h>

//Default parameters
#define defaultSize 8
#define defaultMines 10

@interface KTCMinesweeperController : UIViewController <UIAlertViewDelegate>

@property (nonatomic) NSInteger buttonsOnASide;
@property (nonatomic) NSInteger numberOfMines;

@property (unsafe_unretained, nonatomic) IBOutlet UIView *buttonsContainer;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *smiley;

- (IBAction)buttonTouchedDown;
- (IBAction)buttonTouchUp;
- (IBAction)buttonClicked:(id)sender;
- (IBAction)smileyClicked:(id)sender;

@end
