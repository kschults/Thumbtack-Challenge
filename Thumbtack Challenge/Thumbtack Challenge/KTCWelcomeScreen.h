//
//  KTCWelcomeScreen.h
//  Thumbtack Challenge
//
//  Created by Karl Schults on 9/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KTCWelcomeScreen : UIViewController <UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource>
- (IBAction)newGame:(id)sender;
@property (unsafe_unretained, nonatomic) IBOutlet UITableView *optionsTable;

@end
