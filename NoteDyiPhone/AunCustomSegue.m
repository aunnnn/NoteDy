//
//  AunCustomSegue.m
//  DrawNotes
//
//  Created by Wirawit Rueopas on 4/5/2557 BE.
//  Copyright (c) 2557 Wirawit Rueopas. All rights reserved.
//

#import "AunCustomSegue.h"
#import "AunHomeViewController.h"
#import "AunViewController.h"
@implementation AunCustomSegue
- (void)perform {
    AunHomeViewController *sourceViewController = self.sourceViewController;
    AunViewController *destinationViewController = self.destinationViewController;
    
    
    UIImageView *targetAnimView = [[UIImageView alloc] initWithImage:destinationViewController.tempInitImage];
    targetAnimView.backgroundColor = [UIColor whiteColor];
    // Add the destination view as a subview, temporarily
    [sourceViewController.view addSubview:targetAnimView];
    
    // Get the frame
    NSIndexPath *np = [sourceViewController.collectionView indexPathsForSelectedItems][0];
    UICollectionViewLayoutAttributes *attributes = [sourceViewController.collectionView layoutAttributesForItemAtIndexPath:np];
    CGRect originalRect = [sourceViewController.collectionView convertRect:attributes.frame toView:sourceViewController.view];
    // Transformation start scale
    targetAnimView.frame = originalRect;//
    //targetAnimView.transform = CGAffineTransformMakeScale(0.5,0.5);
    CGRect destinationRect = sourceViewController.view.frame;
    
    
    [UIView animateWithDuration:0.16f
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         // Grow!
                         targetAnimView.frame = destinationRect;
                         //targetAnimView.transform = CGAffineTransformMakeScale(1,1);
                     }
                     completion:^(BOOL finished){
                         [targetAnimView removeFromSuperview]; // remove from temp super view
                         [sourceViewController presentViewController:destinationViewController animated:NO completion:NULL]; // present VC
                     }];
}
@end
