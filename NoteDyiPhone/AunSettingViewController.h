//
//  AunSettingViewController.h
//  DrawNotes
//
//  Created by Wirawit Rueopas on 5/8/2557 BE.
//  Copyright (c) 2557 Wirawit Rueopas. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AunSettingViewController : UIViewController
@property (strong, nonatomic) IBOutlet UISwitch *switchButton;
@property (nonatomic)BOOL on;
- (IBAction)switchButtonPushed:(id)sender;

@end
