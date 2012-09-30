//
//  KTCMinesweeperController.m
//  Thumbtack Challenge
//
//  Created by Karl Schults on 9/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

// Minesweeper images via http://www.personal.kent.edu/~bherzog/

#import "KTCMinesweeperController.h"
#import "KTCCoordinateButton.h"
#include <stdlib.h>

#define defaultSize 8
#define defaultMines 10

//Padding between buttons
#define buttonSpace 5

@interface KTCMinesweeperController()

@property (nonatomic) BOOL isGameOver;
@property (nonatomic, strong) NSArray* buttons;
@property (nonatomic, strong) NSArray* mines;

- (void)resetGame;

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
            CGRect nButtonFrame = CGRectMake(x *(buttonWidth + buttonSpace), y *(buttonWidth + buttonSpace), buttonWidth, buttonWidth);
            KTCCoordinateButton* nButton = [[KTCCoordinateButton alloc] initWithFrame:nButtonFrame];
            [nButton setX:x];
            [nButton setY:y];
            [nButton setIsMine:NO];
            [nButton setBackgroundColor:[UIColor blackColor]];
            [nButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [nButton addTarget:self action:@selector(buttonTouchedDown) forControlEvents:UIControlEventTouchDown];
            [nButton addTarget:self action:@selector(buttonTouchUp) forControlEvents:UIControlEventTouchUpOutside | UIControlEventTouchUpInside];
            
            [buttonsContainer addSubview:nButton];
            [nthRow addObject:nButton];
        }
        [tempButtons addObject:nthRow]; 
    }
    buttons = tempButtons;
    
    
    //Set up mines
    [self resetGame];
}

- (void)viewDidUnload
{
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

#pragma mark - Game Utils

- (void)resetGame {
    isGameOver = NO;
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

- (void)checkAdjacentMines:(KTCCoordinateButton*)button {
    if ([button isMine]) {
        //Boom
        [smiley setImage:[UIImage imageNamed:@"dead.gif"] forState:UIControlStateNormal];
        isGameOver = YES;
        for (KTCCoordinateButton* b in mines) {
            [b setBackgroundColor:[UIColor redColor]];
        }
;
        [[[UIAlertView alloc] initWithTitle:@"BOOM!" message:@"Game Over" delegate:nil cancelButtonTitle:@"Try Again" otherButtonTitles:nil] show];
    } else {
        [button setBackgroundColor:[UIColor whiteColor]];
        [button setIsRevealed:YES];
        
        //Get count of adjacent mines
        int numMinesTouching = 0;
        NSMutableArray* adjacentUnrevealed = [NSMutableArray array];
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
        if (0 == numMinesTouching) {
            for (KTCCoordinateButton* b in adjacentUnrevealed) {
                [self checkAdjacentMines:b];
            }            
        }
        

    }
    [button setUserInteractionEnabled:NO]; //Disable the button once it's been revealed    
}

- (IBAction)buttonClicked:(id)sender {
    KTCCoordinateButton* button = (KTCCoordinateButton *) sender;
    [self checkAdjacentMines:button];
}

- (IBAction)smileyClicked:(id)sender {
    if (isGameOver) {
        [self resetGame];
    } else {
        
    }
}

- (void)buttonTouchedDown {
    [smiley setImage:[UIImage imageNamed:@"uhoh.gif"] forState:UIControlStateNormal];
}
- (void)buttonTouchUp {
    if (!isGameOver) {
        [smiley setImage:[UIImage imageNamed:@"smile.gif"] forState:UIControlStateNormal];        
    }
}

@end
