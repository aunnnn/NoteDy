//
//  AunHomeViewController.h
//  DrawNotes
//
//  Created by Wirawit Rueopas on 4/5/2557 BE.
//  Copyright (c) 2557 Wirawit Rueopas. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AunHomeViewController : UIViewController<NSFetchedResultsControllerDelegate>
{
    //NSMutableArray *noteImages; //array of uiimages
    
    BOOL deletingNotesEnabled;
    UIBarButtonItem *doneButton;
    NSMutableArray *indexPathToDelete;
    IBOutlet UIBarButtonItem *editButton;
    IBOutlet UIBarButtonItem *addButton;
    IBOutlet UINavigationBar *navigationBar;
    NSMutableArray *deletedCell ;
    IBOutlet UIView *emptyNoteLabel;
    
    
    
}
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
//@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) IBOutlet UIImageView *imageViewAnimation;
- (IBAction)addBarButtonPushedForCancelAction:(id)sender;
- (IBAction)deleteNotes:(id)sender;
- (IBAction)tutorialDoneButtonPushed:(id)sender;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UIView *tutorialView;
@property (strong, nonatomic) IBOutlet UIButton *tutorialDoneButton;


@end