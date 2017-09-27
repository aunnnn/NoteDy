//
//  AunHomeViewController.m
//  DrawNotes
//
//  Created by Wirawit Rueopas on 4/5/2557 BE.
//  Copyright (c) 2557 Wirawit Rueopas. All rights reserved.
//

#import "AunHomeViewController.h"
#import "AunViewController.h"
#import "AunCustomUnwindSegue.h"
#import "AunTutorialViewController.h"
#import "AunAppDelegate.h"
#define print(s) NSLog(@"--print-->  %@",s)


@interface AunHomeViewController ()<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,TutorialFirstTimeDelegate>
{
    UIView *tempDarkView;
    NSCache *imageCache;
    BOOL needShowFirstTimeTutorial;
    NSOperationQueue *noteLoadingQueue;
    NSMutableDictionary *decompressingNotesToIndexPath;
}
@end
static NSString *CellIdentifier = @"AFCollectionViewCell";

@implementation AunHomeViewController
{
    NSMutableArray *_objectChanges;
    NSMutableArray *_sectionChanges;
    //NSMutableDictionary *loadingIndexDictionary; //to check if loading image
    NSMutableDictionary * editingIndexDictionary;

    BOOL showingTutorial;
}
- (void)viewDidLoad
{
    [self showOpenTutorial];
    [super viewDidLoad];

    //loadingIndexDictionary = [NSMutableDictionary new];
    editingIndexDictionary = [NSMutableDictionary new];
    noteLoadingQueue = [[NSOperationQueue alloc] init];
    imageCache = [[NSCache alloc] init];
	// Do any additional setup after loading the view.
    deletingNotesEnabled = NO;
    
    
    //[self loadData];
    indexPathToDelete = [NSMutableArray array];
    deletedCell = [NSMutableArray array];
    
    _objectChanges = [NSMutableArray array];
    _sectionChanges = [NSMutableArray array];
    
    
    [self updateEmptyViewLabel];
}

-(void)showOpenTutorial{
    AunAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    if(delegate.isFirstTime){
        //showing tutorial
        needShowFirstTimeTutorial = YES;
        [self showTutorialFirstTime];
    }else{
        needShowFirstTimeTutorial = NO;
        [self hideTutorial];
    }
}
-(void)didArriveLastPage{
    self.tutorialDoneButton.hidden = NO;
    needShowFirstTimeTutorial = NO;
}
-(void)showTutorial{
    if(showingTutorial) return;
    showingTutorial = YES;
    self.tutorialView.hidden = NO;
    tempDarkView.hidden = NO;
    self.tutorialDoneButton.hidden = NO;
    if(!tempDarkView){
        tempDarkView = [[UIView alloc]initWithFrame:self.view.bounds];
        tempDarkView.backgroundColor = [UIColor blackColor];
    }
    tempDarkView.alpha = 0.5f;
    [self.view insertSubview:tempDarkView belowSubview:self.tutorialView];
}
-(void)showTutorialFirstTime{
    [self showTutorial];
    self.tutorialDoneButton.hidden = YES;
}
-(void)hideTutorial{
    self.tutorialView.hidden = YES;
    self.tutorialDoneButton.hidden = YES;
    tempDarkView.hidden = YES;
    showingTutorial = NO;
}
#pragma mark - CollectionView Method
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo =
    [[self.fetchedResultsController sections]
     objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"Cell";
    //print(identifier);
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    if(deletingNotesEnabled){
        if([indexPathToDelete containsObject:indexPath]){
            cell.backgroundColor = [UIColor redColor];
            //NSLog(@"hy%@",indexPathToDelete);
        }else {
            cell.backgroundColor = [UIColor clearColor];
            //NSLog(@"hy2%@",indexPathToDelete);
        }
    }else{
        //prevent the bg color to be red from unknown issue
        cell.backgroundColor = [UIColor clearColor];
    }
    UIImageView *noteImageView = (UIImageView *)[cell viewWithTag:100];
    
//    UIImage *image = [imageCache objectForKey:[NSNumber numberWithInteger:indexPath.row]];
//    if(!image && ![loadingIndexDictionary objectForKey:[NSString stringWithFormat:@"%i",(int)indexPath.row]]){
//        [noteLoadingQueue addOperationWithBlock:^{
//            NSLog(@"loading for%i",(int)indexPath.row);
//            [loadingIndexDictionary setValue:[NSNumber numberWithInteger:indexPath.row] forKey:[NSString stringWithFormat:@"%i",(int)indexPath.row]];
//            NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
//            print(@"loading");
//            UIImage *loadingImage = [UIImage imageWithData:[object valueForKey:@"noteImage"]];
//            
//            [imageCache setObject:loadingImage forKey:[NSNumber numberWithInteger:indexPath.row]];
//            
//            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//                NSLog(@"finish loading for%i",(int)indexPath.row);
//                [loadingIndexDictionary removeObjectForKey:[NSString stringWithFormat:@"%i",(int)indexPath.row] ];
//                noteImageView.backgroundColor = [UIColor whiteColor];
//                noteImageView.image = loadingImage;
//                //[collectionView reloadItemsAtIndexPaths:@[indexPath]];
//            }];
//        }];
//    }else if(image){
//        noteImageView.backgroundColor = [UIColor whiteColor];
//        noteImageView.image = image;
//    }else{
//        //no image but loading image
//        noteImageView.backgroundColor = [UIColor blueColor];
//    }

//    NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
//    NSTimeInterval start =  [NSDate timeIntervalSinceReferenceDate];
//    UIImage *image = [imageCache objectForKey:[NSNumber numberWithInteger:indexPath.row]];
//    if(!image){
//        image = [UIImage imageWithData:[object valueForKey:@"noteImage"]];
//        if(image){
//            NSLog(@"use cache");
//            [imageCache setObject:image forKey:[NSNumber numberWithInteger:indexPath.row]];
//        }
//    }
//    NSLog(@"time Elapsed %f",[NSDate timeIntervalSinceReferenceDate]-start);
//
//    noteImageView.image = image ;
    [self newTemporaryLoadingApproachWithIndexPath:indexPath WithNoteImageView:noteImageView ];
    return cell;
}
-(void)newTemporaryLoadingApproachWithIndexPath:(NSIndexPath*) indexPath WithNoteImageView:(UIImageView*)noteImageView{
    NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    //NSTimeInterval start =  [NSDate timeIntervalSinceReferenceDate];
     UIImage *image = [imageCache objectForKey:[NSNumber numberWithInteger:indexPath.row]];
    //[self printCache];
    if(!image ){
        [decompressingNotesToIndexPath setObject:indexPath forKey:indexPath];
        [noteLoadingQueue addOperationWithBlock:^{
            UIImage * decompressedImage = [UIImage imageWithData:[object valueForKey:@"noteImage"]];
        
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
    
                UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
                UIImageView *noteImageView = (UIImageView *)[cell viewWithTag:100];
                noteImageView.image = decompressedImage;
                [imageCache setObject:decompressedImage forKey:[NSNumber numberWithInteger:indexPath.row]];
            }];
        }];
    }else{
        noteImageView.image = image ;
    }
    //NSLog(@"time Elapsed %f",[NSDate timeIntervalSinceReferenceDate]-start);
    
}
-(void)printCache{
    NSLog(@" Start Print Cache");
    for(int i = 0 ; i < [self.collectionView numberOfItemsInSection:0];i++){
        NSNumber *key = [NSNumber numberWithInteger:i];
        UIImage *img = [imageCache objectForKey:key];
        if(img){
            NSLog(@"row %d image:%@",i,img);
        }
    }
     NSLog(@" End Print Cache");
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if(deletingNotesEnabled){
        //cell.backgroundColor =[UIColor redColor];

        // Add the selected item into the array
        if(![indexPathToDelete containsObject:indexPath]){
            [indexPathToDelete addObject:indexPath];
            
            [editButton setTitle:[NSString stringWithFormat:@"Delete(%d)",(int)indexPathToDelete.count]];
            [UIView setAnimationsEnabled:NO];
        }
        else{
            [indexPathToDelete removeObject:indexPath] ;
            [editButton setTitle:[NSString stringWithFormat:@"Delete(%d)",(int)indexPathToDelete.count]];
            [UIView setAnimationsEnabled:NO];
        }
        [collectionView reloadItemsAtIndexPaths:@[indexPath]];
    }
}


//-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
//    if(deletingNotesEnabled){
//        //cell.backgroundColor =[UIColor clearColor];
//
//        // Add the selected item into the array
//        [indexPathToDelete removeObject:indexPath];
//        [collectionView reloadItemsAtIndexPaths:@[indexPath]];
//    }
//}
#pragma mark -SHake
-(BOOL)canBecomeFirstResponder{
    return YES;
}
-(void)viewDidAppear:(BOOL)animated{
    [self becomeFirstResponder];
}
-(void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event{
    [self showTutorial];
}
#pragma mark - User-Driven Method

- (IBAction)tutorialDoneButtonPushed:(id)sender {
    [self hideTutorial];
}
- (IBAction)done:(UIStoryboardSegue *)segue {
    AunViewController *vc = [segue sourceViewController];
    
    if (vc.noteIndexPath) {
        // Update existing device
        NSManagedObject *editedNote = [[self fetchedResultsController] objectAtIndexPath:vc.noteIndexPath];
        NSData *noteData = UIImagePNGRepresentation(vc.mainImage.image);
        [editedNote setValue:noteData forKey:@"noteImage"];//this cause refresh at that cell
        [imageCache removeObjectForKey:[NSNumber numberWithInteger:vc.noteIndexPath.row]];
    } else if(vc.mainImage.image!=nil){
        // Create a new note
        //[imageCache removeAllObjects];
        [self rearrageImageCacheAfterAddANewNote];
        NSManagedObject *newNote = [NSEntityDescription insertNewObjectForEntityForName:@"NoteImage" inManagedObjectContext:[self managedObjectContext]];//!!!need to save context because the index of notes has changed
        //when update cell , nsfetchedresultscontroller don't know about the new items;
        
         NSData *noteData = UIImagePNGRepresentation(vc.mainImage.image);
        [newNote setValue:noteData forKey:@"noteImage"];
        [newNote setValue:[NSDate date] forKey:@"dateCreated"];
        [self saveContext];
        
        [self.collectionView setContentOffset:CGPointZero animated:YES];
        //as animatingh setcontentoffset , cellforItematindexpath was called, and it need the saved context to generate new note  image for home view controller.

    }
    [self updateEmptyViewLabel];
    
}
-(void)rearrageImageCacheAfterAddANewNote{

    UIImage *tempImage;
    for(int row = (int)[self.collectionView numberOfItemsInSection:0]-1 ; row >=0; row--){

        NSObject *key = [NSNumber numberWithInteger:row];
        tempImage = [imageCache objectForKey:key];
        if(tempImage){
            //NSLog(@"move cache");
            NSObject *newKey = [NSNumber numberWithInteger:row+1];
            [imageCache removeObjectForKey:key];
            [imageCache setObject:tempImage forKey:newKey];
        }
    }
    NSObject *keyFirst = [NSNumber numberWithInteger:0];
    [imageCache removeObjectForKey:keyFirst];
    
}
-(void)rearrangeImageCacheAfterDelete{
    UIImage *tempImage;
    int lastIndex = 0 ;
    int countCache = 0;
    int countDeletedNotes = 0;
    NSMutableArray *orderedNewCache = [NSMutableArray new];
    for(int row = 0 ; row < [self.collectionView numberOfItemsInSection:0] ; row++){
        NSObject *key = [NSNumber numberWithInteger:row];
        tempImage = [imageCache objectForKey:key];
        if(tempImage){
            lastIndex = row;
            countCache++;
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:row inSection:0];
            if([indexPathToDelete containsObject:indexPath]){
                countDeletedNotes++;
                [imageCache removeObjectForKey:key];
                //NSLog(@"delete %i",countDeletedNotes);
                continue;
            }
            //if not to delete add object to new array
            [orderedNewCache addObject:tempImage];
        }
    }
    int firstIndex = lastIndex - countCache+1;
    int k = 0;
    [imageCache removeAllObjects];
    for(int cacheRow = firstIndex ; cacheRow <= lastIndex-countDeletedNotes;cacheRow++){
        NSObject *key = [NSNumber numberWithInteger:cacheRow];
        [imageCache setObject:orderedNewCache[k] forKey:key];
        k++;
    }
    
}
- (IBAction)addBarButtonPushedForCancelAction:(id)sender {
    if(deletingNotesEnabled){
        [UIView setAnimationsEnabled:YES];
        for (NSIndexPath *indexPath in indexPathToDelete) {
            UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
            cell.backgroundColor =[UIColor clearColor];
            
        }
        //[self.collectionView reloadItemsAtIndexPaths:indexPathToDelete];
        [indexPathToDelete removeAllObjects];
        
        deletingNotesEnabled = NO;
        self.collectionView.allowsMultipleSelection = NO;
        [UIView transitionWithView:editButton.customView duration:0.25f options:UIViewAnimationOptionTransitionNone animations:^{
            [editButton setTitle:@"Edit"];
        } completion:nil];
        [addButton setTitle:@"New"];
        editButton.tintColor = [UIColor whiteColor];
    }else{
        [self performSegueWithIdentifier:@"newnotesegue" sender:self];
    }
}
- (IBAction)deleteNotes:(id)sender {
    if(deletingNotesEnabled){
        [UIView setAnimationsEnabled:YES];
        // Delete all selected items
        //[self.collectionView deleteItemsAtIndexPaths:indexPathToDelete];
        [self rearrangeImageCacheAfterDelete];
        for (NSIndexPath *indexPath in indexPathToDelete) {
            UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
            cell.backgroundColor =[UIColor clearColor];
            [[self managedObjectContext] deleteObject:[[self fetchedResultsController] objectAtIndexPath:indexPath]];
        }
        // Remove all items from selectedRecipes array
        [indexPathToDelete removeAllObjects];
 
        [self updateEmptyViewLabel];
       // [imageCache removeAllObjects];
        
        deletingNotesEnabled = NO;
        self.collectionView.allowsMultipleSelection = NO;
        //editButton.title = @"Edit";
        [UIView transitionWithView:editButton.customView duration:0.25f options:UIViewAnimationOptionTransitionNone animations:^{
            [editButton setTitle:@"Edit"];
        } completion:nil];
        [addButton setTitle:@"New"];
        editButton.tintColor = [UIColor whiteColor];
        //[editButton setStyle:UIBarButtonItemStylePlain];
    }else{
        deletingNotesEnabled = YES;
        self.collectionView.allowsMultipleSelection = YES;
        //editButton.title = @"Delete";
        [UIView transitionWithView:editButton.customView duration:0.25f options:UIViewAnimationOptionTransitionNone animations:^{
            [editButton setTitle:@"Delete"];
            
        } completion:nil];
        [addButton setTitle:@"Cancel"];
        
        [editButton setTintColor:[UIColor redColor]];
        //editButton.tintColor = [UIColor redColor];
        //[editButton setStyle:UIBarButtonItemStylePlain];
    }
}


#pragma mark - AppDelegate Method
- (NSManagedObjectContext *)managedObjectContext
{
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}
- (void)saveContext{
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(saveContext)]) {
        //NSLog(@"SAVECONTEXT OK");
    }
    
}
#pragma mark - Core Data

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"NoteImage" inManagedObjectContext:[self managedObjectContext]];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:28];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"dateCreated" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[self managedObjectContext] sectionNameKeyPath:nil cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;

    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	    //NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}

#pragma mark - FetchedResultsController

-(void)controllerWillChangeContent:(NSFetchedResultsController *)controller{
    
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    NSMutableDictionary *change = [NSMutableDictionary new];
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            change[@(type)] = @(sectionIndex);
            break;
        case NSFetchedResultsChangeDelete:
            change[@(type)] = @(sectionIndex);
            break;
    }
    
    [_sectionChanges addObject:change];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    NSMutableDictionary *change = [NSMutableDictionary new];
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            //print(@"insertt");
            change[@(type)] = newIndexPath;
            break;
        case NSFetchedResultsChangeDelete:
         
            change[@(type)] = indexPath;
            break;
        case NSFetchedResultsChangeUpdate:
            change[@(type)] = indexPath;
            break;
        case NSFetchedResultsChangeMove:
            change[@(type)] = @[indexPath, newIndexPath];
            break;
    }
    [_objectChanges addObject:change];

}
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
 
    if ([_sectionChanges count] > 0)
    {
        [self.collectionView performBatchUpdates:^{
            
            for (NSDictionary *change in _sectionChanges)
            {
                [change enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop) {
                    
                    NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                    switch (type)
                    {
                        case NSFetchedResultsChangeInsert:
                    
                            [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                            break;
                        case NSFetchedResultsChangeDelete:
                            [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                            break;
                        case NSFetchedResultsChangeUpdate:
                            [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                            break;
                    }
                }];
            }
        } completion:nil];
    }
    
    if ([_objectChanges count] > 0 && [_sectionChanges count] == 0)
    {
        
        if ([self shouldReloadCollectionViewToPreventKnownIssue] || self.collectionView.window == nil) {
            // This is to prevent a bug in UICollectionView from occurring.
            // The bug presents itself when inserting the first object or deleting the last object in a collection view.
            // http://stackoverflow.com/questions/12611292/uicollectionview-assertion-failure
            // This code should be removed once the bug has been fixed, it is tracked in OpenRadar
            // http://openradar.appspot.com/12954582
            [self.collectionView reloadData];
            
        } else {
            //animate the action below
            [self.collectionView performBatchUpdates:^{
                
                for (NSDictionary *change in _objectChanges)
                {
                    [change enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop) {
                        
                        NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                        switch (type)
                        {
                            case NSFetchedResultsChangeInsert:
                                [self.collectionView insertItemsAtIndexPaths:@[obj]];
                                break;
                            case NSFetchedResultsChangeDelete:
                                [self.collectionView deleteItemsAtIndexPaths:@[obj]];
                                break;
                            case NSFetchedResultsChangeUpdate:
                                [self.collectionView reloadItemsAtIndexPaths:@[obj]];
                                break;
                            case NSFetchedResultsChangeMove:
                                [self.collectionView moveItemAtIndexPath:obj[0] toIndexPath:obj[1]];
                                break;
                        }
                    }];
                }
            } completion:nil];
        }
    }
    
    [_sectionChanges removeAllObjects];
    [_objectChanges removeAllObjects];
}
- (BOOL)shouldReloadCollectionViewToPreventKnownIssue {
    __block BOOL shouldReload = NO;
    for (NSDictionary *change in _objectChanges) {
        [change enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            NSFetchedResultsChangeType type = [key unsignedIntegerValue];
            NSIndexPath *indexPath = obj;
            switch (type) {
                case NSFetchedResultsChangeInsert:
                    if ([self.collectionView numberOfItemsInSection:indexPath.section] == 0) {
                        shouldReload = YES;
                    } else {
                        shouldReload = NO;
                    }
                    break;
                case NSFetchedResultsChangeDelete:
                    if ([self.collectionView numberOfItemsInSection:indexPath.section] == 1) {
                        shouldReload = YES;
                    } else {
                        shouldReload = NO;
                    }
                    break;
                case NSFetchedResultsChangeUpdate:
                    shouldReload = NO;
                    break;
                case NSFetchedResultsChangeMove:
                    shouldReload = NO;
                    break;
            }
        }];
    }
    
    return shouldReload;
}
#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"tonotesegue"]){
        AunViewController *vc = [segue destinationViewController];
        
        NSIndexPath *indexPath = [self.collectionView indexPathsForSelectedItems][0];
        vc.noteIndexPath = indexPath;
        NSManagedObject *targetObject = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        UIImage *targetImage = [UIImage imageWithData:[targetObject valueForKey:@"noteImage"]];
        
        vc.tempInitImage = targetImage;
    }
    AunAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    if ([segue.identifier isEqualToString:@"tutorialSegue"]&&delegate.isFirstTime){
        AunTutorialViewController *vc = [segue destinationViewController];
        vc.delegate = self;
    }
}
-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    if(deletingNotesEnabled){
        return NO;
    }else{
        return YES;
    }
}
-(UIStoryboardSegue *)segueForUnwindingToViewController:(UIViewController *)toViewController fromViewController:(UIViewController *)fromViewController identifier:(NSString *)identifier{
    if([identifier isEqualToString:@"unwindsegue"]&&((AunViewController *)fromViewController).mainImage.image!=nil){
        AunCustomUnwindSegue *segue =[[AunCustomUnwindSegue alloc] initWithIdentifier:identifier source:fromViewController destination:toViewController];
        return segue;
    }else{
        return [super segueForUnwindingToViewController:toViewController fromViewController:fromViewController identifier:identifier];
    }
}
#pragma mark - ETC.
-(void)updateEmptyViewLabel{
    if([[[self fetchedResultsController] fetchedObjects] count]==0){
        emptyNoteLabel.hidden = NO;
    }else{
        emptyNoteLabel.hidden = YES;
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [self saveContext];
}
@end
