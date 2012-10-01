//
//  KTCMinesweeperController.m
//  Thumbtack Challenge
//
//  Created by Karl Schults on 9/30/12.
//  Copyright (c) 2012. All rights reserved.
//

// Minesweeper images via http://www.personal.kent.edu/~bherzog/

#import "KTCMinesweeperController.h"
#include <stdlib.h>

//Padding between buttons
#define buttonSpace 5

@interface KTCMinesweeperController()

@property (nonatomic) BOOL isGameOver;
@property (nonatomic, strong) NSArray* buttons;
@property (nonatomic, strong) NSArray* mines;

- (void)resetGame;
- (void)endGameWithStatus:(BOOL)didWin;

@end

@implementation KTCMinesweeperController

@synthesize buttonsContainer;
@synthesize smiley;
@synthesize isGameOver;
@synthesize buttons;
@synthesize buttonsOnASide, numberOfMines, mines;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if (0 == buttonsOnASide) {
        buttonsOnASide = defaultSize;
    }
    if (0 == numberOfMines) {
        numberOfMines = defaultMines;
    }
    
    if (numberOfMines >= buttonsOnASide*buttonsOnASide) {
        //We have a problem
    }
    
    CGFloat totalSpace = buttonsContainer.frame.size.width; //Width is the narrower dimension
    CGFloat buttonWidth = (totalSpace - buttonSpace * (buttonsOnASide + 1)) / buttonsOnASide;
    
    //Create buttons
    int x,y;
    NSMutableArray* tempButtons = [NSMutableArray arrayWithCapacity:buttonsOnASide];
    for (y=0; y<buttonsOnASide; y++) {
        NSMutableArray* nthRow = [[NSMutableArray alloc] initWithCapacity:y];
        
        for (x=0; x<buttonsOnASide; x++) {
            CGRect nButtonFrame = CGRectMake(x *buttonWidth + (x + 1) * buttonSpace, y * buttonWidth + (y + 1) * buttonSpace, buttonWidth, buttonWidth);
            KTCCoordinateButton* nButton = [[KTCCoordinateButton alloc] initWithFrame:nButtonFrame];
            [nButton setX:x];
            [nButton setY:y];
            [nButton setDelegate:self];
            
            [buttonsContainer addSubview:nButton];
            [nthRow addObject:nButton];
        }
        [tempButtons addObject:nthRow]; 
    }
    buttons = tempButtons;
    
    
    //Set up mines
    [self resetGame];
}

- (void)viewDidUnload {
    [self setButtonsContainer:nil];
    [self setSmiley:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [self setMines:nil];
    [self setButtons:nil];
    [self setButtonsContainer:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    static NSString* prefKey = @"firstView";
    NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
    if (![prefs boolForKey:prefKey]) {
        [[[UIAlertView alloc] initWithTitle:@"Welcome to Minesweeper" message:@"Tap once to reveal a space, tap twice to flag as a mine. Double tap a revealed space to reveal all unflagged adjacent spaces." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil] show];
        [prefs setBool:YES forKey:prefKey];
    }
}

#pragma mark - Game Utils

- (void)resetGame {
    isGameOver = NO;
    [smiley setImage:[UIImage imageNamed:@"smile.gif"] forState:UIControlStateNormal];
    for (NSArray* row in buttons) {
        for (KTCCoordinateButton* button in row) {
            [button reset];
        }
    }
    
    int x,y;
    NSMutableArray* tempMines = [NSMutableArray arrayWithCapacity:numberOfMines];
    
    while ([tempMines count] < numberOfMines) {
        x = arc4random_uniform(buttonsOnASide);
        y = arc4random_uniform(buttonsOnASide);
        KTCCoordinateButton* b = [[buttons objectAtIndex:y] objectAtIndex:x];
        if (![b isMine]) {
            [b setIsMine:YES];
            [tempMines addObject:b];
        }
    }
    mines = tempMines;
}

- (BOOL)checkSelfAndAdjacentMines:(KTCCoordinateButton*)button alwaysReveal:(BOOL)alwaysReveal {
    /* Reveal the given button. If it's a mine, game over, and return NO. If it's not, show the number of adjacent mines and return YES. If it has no adjacent mines, perform on all unrevealed neighbors */
    if ([button isMine] &! [button isFlagged]) {
        [self endGameWithStatus:NO];
        return NO;
    } else {
        [button setBackgroundColor:[UIColor whiteColor]];
        [button setIsRevealed:YES];
        
        int numMinesTouching = 0;
        NSMutableArray* adjacentUnrevealed = [NSMutableArray array];
        //Count adjacent mines, gather unrevealed neighbors
        for (int y = button.y - 1; y <= button.y + 1; y++) {
            if (-1 == y || y == buttonsOnASide) {
                continue; //Skip the cells that don't actually exist
            }
            NSArray* row = [buttons objectAtIndex:y];
            for (int x = button.x - 1; x <= button.x + 1; x++) {
                if (-1 == x || x == buttonsOnASide) {
                    continue;
                }
                KTCCoordinateButton* b = [row objectAtIndex:x];
                if ([b isMine]) {
                    numMinesTouching++;
                }
                if (![b isRevealed]) {
                    [adjacentUnrevealed addObject:b];                    
                }
            }
        }
        
        //Reveal count
        [button.textLabel setText:[NSString stringWithFormat:@"%d", numMinesTouching]];
        
        //Reveal all adjacent squares for squares with 0 touching
        if (0 == numMinesTouching || alwaysReveal) {
            for (KTCCoordinateButton* b in adjacentUnrevealed) {
                [self checkSelfAndAdjacentMines:b alwaysReveal:NO];
            }            
        }
        
        return YES;
    }
}

- (BOOL)hasWon {
    /* We are in a winning position if all buttons are either revealed or mines. We are in a losing position if there are any unrevealed non-mines
     */
    for (NSArray* row in buttons) {
        for (KTCCoordinateButton* button in row) {
            if (![button isRevealed] &! [button isMine]) {
                return NO;
            }
        }
    }
    return YES;
}

- (void)endGameWithStatus:(BOOL)didWin {
    [self setIsGameOver:YES];
    if (didWin) {
        [smiley setImage:[UIImage imageNamed:@"cool.gif"] forState:UIControlStateNormal];
        [[[UIAlertView alloc] initWithTitle:@"Congratulations!" message:@"You won!" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Play Again", @"Quit", nil] show];
    } else {
        //Boom
        [smiley setImage:[UIImage imageNamed:@"dead.gif"] forState:UIControlStateNormal];
        for (KTCCoordinateButton* b in mines) {
            [b setBackgroundColor:[UIColor redColor]];
        }
        ;
        [[[UIAlertView alloc] initWithTitle:@"BOOM!" message:@"Game Over" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Play Again", @"Quit", nil] show];
    }
}

- (IBAction)smileyClicked:(id)sender {
    if (isGameOver) {
        [self resetGame];
    } else {
        [self endGameWithStatus:[self hasWon]];
    }
}

#pragma mark - UIAlertViewDelegate protocol
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (0 == buttonIndex) { //Play Again
        [self resetGame];
    } else {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

#pragma mark - KTCCoordinateDelegate protocol
- (void)touchBeganOnButton:(KTCCoordinateButton *)b {
    [smiley setImage:[UIImage imageNamed:@"uhoh.gif"] forState:UIControlStateNormal];
}

- (void)touchEndedOnButton:(KTCCoordinateButton *)b {
    if (!isGameOver) {
        [smiley setImage:[UIImage imageNamed:@"smile.gif"] forState:UIControlStateNormal];        
    }
}

- (void)didSingleTapButton:(KTCCoordinateButton *)b {
    [self checkSelfAndAdjacentMines:b alwaysReveal:NO];
    if ([self hasWon]) {
        [self endGameWithStatus:YES];
    }
}

- (void)didDoubleTapButton:(KTCCoordinateButton *)b {
    if (b.isRevealed) {
        [self checkSelfAndAdjacentMines: b alwaysReveal:YES];
    } else {
        [b toggleFlag];
    }
    
    
}

@end
