//
//  AunSettingViewController.m
//  DrawNotes
//
//  Created by Wirawit Rueopas on 5/8/2557 BE.
//  Copyright (c) 2557 Wirawit Rueopas. All rights reserved.
//

#import "AunSettingViewController.h"

@interface AunSettingViewController ()

@end

@implementation AunSettingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.switchButton.on = self.on;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)switchButtonPushed:(id)sender {
    if(self.switchButton.on){
        [self.switchButton setOn:YES animated:YES];
        //self.switchButton.on = NO;
    }else{
        [self.switchButton setOn:NO animated:YES];
        //self.switchButton.on = YES;
    }
}
@end
