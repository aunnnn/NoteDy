//
//  AunCustomUnwindSegue.m
//  DrawNotes
//
//  Created by Wirawit Rueopas on 4/5/2557 BE.
//  Copyright (c) 2557 Wirawit Rueopas. All rights reserved.
//

#import "AunCustomUnwindSegue.h"
#import "AunHomeViewController.h"
#import "AunViewController.h"

@implementation AunCustomUnwindSegue
-(void)perform{
    
    
    AunHomeViewController *destinationViewController = (AunHomeViewController *)self.destinationViewController;
    AunViewController *sourceViewController = (AunViewController *) self.sourceViewController;
    
    UIImageView* sourceView = [[UIImageView alloc] initWithImage:sourceViewController.mainImage.image];
    sourceView.backgroundColor = [UIColor whiteColor];
    sourceView.frame = sourceViewController.mainImage.frame;
    [sourceViewController.view addSubview:destinationViewController.view];
    [sourceViewController.view addSubview:sourceView];
    
    
    //new image
    if(!sourceViewController.noteIndexPath) sourceViewController.noteIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    //error because "done" method should be adding new note in the array by now but how to do it with fetchresultcontroller
    UICollectionViewLayoutAttributes *attributes = [destinationViewController.collectionView layoutAttributesForItemAtIndexPath:sourceViewController.noteIndexPath];
    CGRect dstRect = [destinationViewController.collectionView convertRect:attributes.frame toView:destinationViewController.view];
    
    dstRect.size.width-=12;
    dstRect.size.height-=12;
    dstRect.origin.x += 6;
    dstRect.origin.y += 6;
    
    
    [UIView animateWithDuration:0.16f
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         // Grow!
                         sourceView.frame = dstRect;
                         //targetAnimView.transform = CGAffineTransformMakeScale(1,1);
                     }
                     completion:^(BOOL finished){
                         [sourceView removeFromSuperview]; // remove from temp super view
                         [destinationViewController.view removeFromSuperview];
                         [sourceViewController dismissViewControllerAnimated:NO completion:nil];
                     }];
}
//-(UIImage*)imageWithView:(UIView*) view{
//    CGSize halfSize = view.bounds.size;
////    halfSize.height = halfSize.height/2;
////    halfSize.width = halfSize.width/2;
//
//    UIGraphicsBeginImageContextWithOptions(halfSize,YES, 0.2);
//    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
//    UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    return screenshot;
//}


@end
