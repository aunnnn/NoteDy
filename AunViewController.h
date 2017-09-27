//
//  AunViewController.h
//  DrawNotes
//
//  Created by Wirawit Rueopas on 4/5/2557 BE.
//  Copyright (c) 2557 Wirawit Rueopas. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <UIKit/UIKit.h>
#import "AunColorSettingView.h"
#import "AunEraserView.h"
#import "AunColorBarPicker.h"
@interface AunViewController : UIViewController<sampleDelegate,UIGestureRecognizerDelegate>
{
    CAKeyframeAnimation *springEffect;
    BOOL springAnimation ;
    UIScreenEdgePanGestureRecognizer *leftEdgeRecognizer ;
    UIScreenEdgePanGestureRecognizer *rightEdgeRecognizer ;
    UIPinchGestureRecognizer *pinchEraserRecognizer;
    UIPanGestureRecognizer *panTearDownNoteRecognizer;
    IBOutlet AunColorSettingView *colorSettingView ;
    IBOutlet UIView *alphaView;
    IBOutlet UIView *edgeAlphaView;
    IBOutlet UIView *edgeAlphaViewRight;
    BOOL fromColorViewMode ;
    BOOL clearingPageNow ;
    CGFloat lastFactor ;
    
    CGFloat cRadius ;
    CGFloat cRed;
    CGFloat cGreen;
    CGFloat cBlue;
    CGFloat cAlpha;
    
    BOOL mouseSwiped ;
    UIImage *drawModeIcon ;
    UIImage *writeModeIcon ;
    UIImage *shapeLineIcon ;
    UIImage *shapeRectIcon ;
    UIImage *shapeCircleIcon ;
    UIImage *selectorIcon ;
    UIImage *saveNoteIcon;
    UIImage *settingIcon;
    AunEraserView *eraserView ;
    
    UIImageView *selectorImageView ;    //yellow selector circle
    UIImageView *selectorForColorModeImageView;
    BOOL hueMode;
    UIButton *currentSelectedButton ;
    
    NSUndoManager *undomanager ;
    IBOutlet UIButton *undoButton;
    IBOutlet UIButton *homeButton;
    
    IBOutlet UIButton *colorModeButton;
    IBOutlet UIImageView *imageBehindColorView;
    IBOutlet UIButton *shapeModeButton;
    IBOutlet UIButton *brushModeButton;
    IBOutlet UIButton *eraserModeButton;
    IBOutlet UIButton *blackColorButton;
    IBOutlet UIButton *hueColorButton;
    IBOutlet AunColorBarPicker *colorBarPicker;
    IBOutlet AunColorBarView *colorBarPickerView;
    IBOutlet UIView *bwView;
    IBOutlet UISlider *bwSlider;
    
    CGPoint touchLocation1,touchLocation2;
    
    BOOL lastDraggedBoxMode;
    
    IBOutlet UIImageView *upperHalf;
    IBOutlet UIImageView *lowerHalf;
    IBOutlet UIView *bgColorEdittingView;
    IBOutlet UILabel *label_deleteYES;
    IBOutlet UILabel *label_newPage;
    //BOOL dividingViewEffecting;
    
    BOOL drawMode ;
    NSInteger tempSelectMode ;
    NSInteger selectModeBeforeEraser;
    NSInteger currentMode ; // 0 = brush , 1 = eraser , 2 = color , 3 = shape
    NSInteger shapeMode;// 0 = line, 1 = rect, 2 = circle
    
    UIImageView *tempShapeView;
    
    IBOutlet UIButton *settingGearButton;
    BOOL movingBoxEnable;
    
}
@property (strong, nonatomic) IBOutlet UIImageView *mainImage;
@property (strong, nonatomic) IBOutlet UIImageView *tempDrawImage;
@property (strong, nonatomic) UIImage *tempInitImage;
@property (strong,nonatomic) NSIndexPath *noteIndexPath;
//@property (strong, nonatomic) IBOutlet UIButton *goHomeButtonPush;
- (IBAction)toBlackColorMode:(id)sender;
- (IBAction)toHueColorMode:(id)sender;

- (IBAction)undoButtonPush:(id)sender;
- (IBAction)sliderChanged:(id)sender;
- (IBAction)takeBarValue:(AunColorBarPicker *)sender;
- (IBAction)selectColor:(id)sender;
- (IBAction)selectShapeMode:(id)sender;
- (IBAction)selectEraser:(id)sender;
- (IBAction)changeBrushMode:(id)sender;
- (IBAction)settingGearButtonPushed:(id)sender;

@end