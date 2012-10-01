//
//  KTCWelcomeScreen.m
//  Thumbtack Challenge
//
//  Created by Karl Schults on 9/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

/* NB: UIPicker hiding and showing code via http://jeffmenter.wordpress.com/2012/04/28/showing-and-dismissing-a-uipickerview-control/ */

#import "KTCWelcomeScreen.h"
#import "KTCMinesweeperController.h"

/* Picker Dismisser UIView Subclass */
@interface PickerDismissView : UIView
@property (nonatomic, strong) id parentViewController;
@end

@implementation PickerDismissView
@synthesize parentViewController = _parentViewController;
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Got a touch? Tell parentViewController to dismiss the picker.
    [self.parentViewController performSelector:@selector(dismissPickerView)];
}
@end
/* End Picker Dismisser */

@interface KTCWelcomeScreen()

@property (strong, nonatomic) PickerDismissView *pickerDismissView;
@property (strong, nonatomic) UIPickerView *pickerView;
@property CGRect pickerDismissViewShownFrame;
@property CGRect pickerDismissViewHiddenFrame;
@property CGRect pickerViewShownFrame;
@property CGRect pickerViewHiddenFrame;

@end

@implementation KTCWelcomeScreen

@synthesize optionsTable;

@synthesize pickerDismissView = _pickerDismissView;
@synthesize pickerView = _pickerView;
@synthesize pickerDismissViewShownFrame = _pickerDismissViewShownFrame;
@synthesize pickerDismissViewHiddenFrame = _pickerDismissViewHiddenFrame;
@synthesize pickerViewShownFrame = _pickerViewShownFrame;
@synthesize pickerViewHiddenFrame = _pickerViewHiddenFrame;

//Picker frame constants
static const CGFloat kPickerDefaultWidth = 320.f;
static const CGFloat kPickerDefaultHeight = 216.f;
static const CGFloat kPickerDismissViewShownOpacity = 0.333;
static const CGFloat kPickerDismissViewHiddenOpacity = 0.f;
static const NSTimeInterval kPickerAnimationTime = 0.333;

int buttonsOnASide, numberOfMines;
int shownPicker;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        //Set picker frames
        self.pickerViewShownFrame = CGRectMake(0.f, self.view.frame.size.height - kPickerDefaultHeight, kPickerDefaultWidth, kPickerDefaultHeight);
        self.pickerViewHiddenFrame = CGRectMake(0.f, self.view.frame.size.height, kPickerDefaultWidth, kPickerDefaultHeight);
        
        // Set up the initial state of the picker.
        self.pickerView = [[UIPickerView alloc] init];
        self.pickerView.frame = self.pickerViewHiddenFrame;
        self.pickerView.delegate = self;
        self.pickerView.dataSource = self;
        self.pickerView.showsSelectionIndicator = YES;
        
        // Add the picker as a subview of our view.
        [self.view addSubview:self.pickerView];
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
    buttonsOnASide = defaultSize;
    numberOfMines = defaultMines;
}

- (void)viewDidUnload
{
    [self setOptionsTable:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [self setPickerView:nil];
    [self setPickerDismissView:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // Have to add this here because there is no valid navigationController.view until here.
    if (!self.pickerDismissView) {
        // Set picker dismiss view's shown and hidden position frames.
        self.pickerDismissViewShownFrame = CGRectMake(0.f, 0.f, kPickerDefaultWidth, self.navigationController.view.frame.size.height - kPickerDefaultHeight);
        self.pickerDismissViewHiddenFrame = self.navigationController.view.frame;
        
        // Set up the initial state of the picker dismiss view.
        self.pickerDismissView = [[PickerDismissView alloc] init];
        self.pickerDismissView.frame = self.pickerDismissViewHiddenFrame;
        self.pickerDismissView.parentViewController = self;
        self.pickerDismissView.backgroundColor = [UIColor blackColor];
        self.pickerDismissView.alpha = kPickerDismissViewHiddenOpacity;
        
        // We are inserting it as a subview of the navigation controller's view. We do this so that we can make it appear OVER the navigation bar.
        [self.navigationController.view insertSubview:self.pickerDismissView aboveSubview:self.navigationController.navigationBar];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)newGame:(id)sender {
    KTCMinesweeperController* c = [[KTCMinesweeperController alloc] initWithNibName:@"KTCMinesweeperController" bundle:[NSBundle mainBundle]];
    [c setButtonsOnASide:buttonsOnASide];
    [c setNumberOfMines:numberOfMines];
    [self.navigationController pushViewController:c animated:YES];
}

- (void)showPickerView {    
    // To show the picker, we animate the frame and alpha values for the pickerview and the picker dismiss view.
    [UIView animateWithDuration:kPickerAnimationTime animations:^{
        self.pickerDismissView.frame = self.pickerDismissViewShownFrame;
        self.pickerDismissView.alpha = kPickerDismissViewShownOpacity;
        self.pickerView.frame = self.pickerViewShownFrame;
    }];
}

- (void)dismissPickerView {
    // Ditto to dismiss.
    [UIView animateWithDuration:kPickerAnimationTime animations:^{
        self.pickerDismissView.frame = self.pickerDismissViewHiddenFrame;
        self.pickerDismissView.alpha = kPickerDismissViewHiddenOpacity;
        self.pickerView.frame = self.pickerViewHiddenFrame;
    }];
    [optionsTable deselectRowAtIndexPath:[optionsTable indexPathForSelectedRow] animated:NO];
}


#pragma mark - UITableView delegate protocols
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    if (0 == indexPath.row) {
        [cell.textLabel setText:@"Size of grid"];
        [cell.detailTextLabel setText:[NSString stringWithFormat:@"%d", buttonsOnASide]];
    } else {
        [cell.textLabel setText:@"Number of mines"];
        [cell.detailTextLabel setText:[NSString stringWithFormat:@"%d", numberOfMines]];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    shownPicker = indexPath.row;
    if (0 == shownPicker) {
        [self.pickerView selectRow:buttonsOnASide - 1 inComponent:0 animated:NO];
    } else {
        [self.pickerView selectRow:numberOfMines - 1 inComponent:0 animated:NO];
    }
    [self.pickerView reloadAllComponents];
    [self showPickerView];
}

#pragma mark - UIPickerView delegate protocols
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (0 == shownPicker) { //Grid size
        return 16; //Probably about as big as we want to go - any bigger and it's hard to click
    } else {
        return buttonsOnASide*buttonsOnASide; //You could have every button be a mine if you wanted
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [NSString stringWithFormat:@"%d", row + 1];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (0 == shownPicker) {
        buttonsOnASide = row + 1;
        numberOfMines = MIN(numberOfMines, buttonsOnASide*buttonsOnASide);
    } else {
        numberOfMines = row + 1;
    }
    [optionsTable reloadData];
}

@end
