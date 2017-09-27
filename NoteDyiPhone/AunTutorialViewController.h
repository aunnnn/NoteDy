//
//  AunTutorialViewController.h
//  DrawNotes
//
//  Created by Wirawit Rueopas on 5/4/2557 BE.
//  Copyright (c) 2557 Wirawit Rueopas. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol TutorialFirstTimeDelegate <NSObject>
@required
-(void)didArriveLastPage;
@end

@interface AunTutorialViewController : UIViewController<UIPageViewControllerDataSource>
@property (strong, nonatomic) UIPageViewController *pageController;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;
@property (strong, nonatomic) NSArray *pageImages;
@property id<TutorialFirstTimeDelegate> delegate;
@end

