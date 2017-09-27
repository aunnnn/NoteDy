//
//  AunTutorialViewController.m
//  DrawNotes
//
//  Created by Wirawit Rueopas on 5/4/2557 BE.
//  Copyright (c) 2557 Wirawit Rueopas. All rights reserved.
//

#import "AunTutorialViewController.h"
#import "AunPageContentViewController.h"
#define print(s) NSLog(@"--print-->  %@",s)
@interface AunTutorialViewController ()

@end

@implementation AunTutorialViewController

-(void)setUpPageImages{
    UIImage *img1 = [UIImage imageNamed:@"tutorial1.png"];
    UIImage *img2 = [UIImage imageNamed:@"tutorial2.png"];
    UIImage *img3 = [UIImage imageNamed:@"tutorial3.png"];
    UIImage *img4 = [UIImage imageNamed:@"tutorial4.png"];
    UIImage *img5 = [UIImage imageNamed:@"tutorial5.png"];
    UIImage *img6 = [UIImage imageNamed:@"tutorial6.png"];
    self.pageImages = @[img1,img2,img3,img4,img5,img6];
    self.pageControl.numberOfPages = self.pageImages.count;
    self.pageControl.currentPage = 0 ;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setUpPageImages];
    self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    self.pageController.dataSource = self;
    [[self.pageController view] setFrame:[self.view bounds]];
    
    AunPageContentViewController *initialViewController = [self viewControllerAtIndex:0];
    
    NSArray *viewControllers = [NSArray arrayWithObject:initialViewController];
    
    [self.pageController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    
    
    [self addChildViewController:self.pageController];
    [[self view] addSubview:[self.pageController view]];
    [self.pageController didMoveToParentViewController:self];
    
    
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController{
    NSUInteger index = [self indexOfViewController:
                        (AunPageContentViewController *)viewController];
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    index--;
    return [self viewControllerAtIndex:index];
}
- (UIViewController *)pageViewController:
(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = [self indexOfViewController:
                        (AunPageContentViewController *)viewController];
    
    if (index == NSNotFound) {
        return nil;
    }
    index++;

    if (index == [self.pageImages count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}
- (NSUInteger)indexOfViewController:(AunPageContentViewController *)viewController
{
   // NSLog(@"turn page");
    NSInteger index = [_pageImages indexOfObject:viewController.imageView.image];
    self.pageControl.currentPage = index;
    if(index == 5&&self.delegate){
        [self.delegate didArriveLastPage];
        self.delegate = Nil;
    }
    return index;
}
- (AunPageContentViewController *)viewControllerAtIndex:(NSUInteger)index
{
    // Return the data view controller for the given index.
    if (([self.pageImages count] == 0) ||
        (index >= [self.pageImages count])) {
        return nil;
    }
    
    UIStoryboard *storyboard =
    [UIStoryboard storyboardWithName:@"Main"
                              bundle:[NSBundle mainBundle]];

    AunPageContentViewController *dataViewController = [storyboard instantiateViewControllerWithIdentifier:@"PageContent"];
    dataViewController.view.frame = [self.view bounds];
    CGRect rect = [self.view bounds];
    rect.size.height-=37;
    dataViewController.imageView.frame = rect;
    dataViewController.view.clipsToBounds = YES;
    dataViewController.view.backgroundColor = [UIColor clearColor];
    dataViewController.imageView.image = _pageImages[index];
    
   // self.pageControl.currentPage = index;
    return dataViewController;
}

@end
