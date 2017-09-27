//
//  AunViewController.m
//  DrawNotes
//
//  Created by Wirawit Rueopas on 4/5/2557 BE.
//  Copyright (c) 2557 Wirawit Rueopas. All rights reserved.
//

#import "AunViewController.h"
#import "AunEraserView.h"
#import "AunHomeViewController.h"
#import "AunConstants.h"
#import "AUNSettingViewController.h"
@interface AunViewController ()
{
    NSOperationQueue *renderingQueue;
    UIImage *upperTearImage;
    UIImage *lowerTearImage;
    BOOL editBeforeTear;
    UIImage *previousImageBeforeTear;
    
    UIView *disableUndoButtonView;
}
@end

@implementation AunViewController

CGPoint previousPoint1, previousPoint2 , currentPoint ;
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect frame = undoButton.frame;
    frame.origin.x += 3;
    frame.origin.y += 3;
    frame.size.height -= 6;
    frame.size.width -= 6;
    
    disableUndoButtonView = [[UIView alloc] initWithFrame:frame];
    disableUndoButtonView.backgroundColor = [UIColor whiteColor];
    disableUndoButtonView.layer.cornerRadius = disableUndoButtonView.bounds.size.height/2;
    UIGestureRecognizer *dummyGR = [[UIGestureRecognizer alloc]initWithTarget:disableUndoButtonView action:nil];
    [disableUndoButtonView addGestureRecognizer:dummyGR];
    disableUndoButtonView.alpha = 0.5f;
    movingBoxEnable = YES;
    renderingQueue = [[NSOperationQueue alloc] init];
    
    self.mainImage.image = self.tempInitImage;
	// Do any additional setup after loading the view, typically from a nib.
    colorSettingView.delegate = self;
    
    CGAffineTransform trans = CGAffineTransformMakeRotation(M_PI);
    bwSlider.transform = trans;
    
    
    currentSelectedButton = brushModeButton;
    colorSettingView.layer.cornerRadius = 5;
    [self setSpringAnimation];
    
    
    leftEdgeRecognizer = [[UIScreenEdgePanGestureRecognizer alloc]initWithTarget:self action:@selector(handleEdgePan:)];
    leftEdgeRecognizer.edges = UIRectEdgeLeft;
    leftEdgeRecognizer.delegate = self;
    [self.view addGestureRecognizer:leftEdgeRecognizer];
    
    rightEdgeRecognizer = [[UIScreenEdgePanGestureRecognizer alloc]initWithTarget:self action:@selector(handleEdgeRightPan:)];
    rightEdgeRecognizer.edges = UIRectEdgeRight;
    rightEdgeRecognizer.delegate = self;
    [self.view addGestureRecognizer:rightEdgeRecognizer];
    
    [self additionalLoad];
    
    pinchEraserRecognizer = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(handlePinch:)];
    [self.view addGestureRecognizer:pinchEraserRecognizer];
    panTearDownNoteRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handleTearDownPaper:)];
    [self.view addGestureRecognizer:panTearDownNoteRecognizer];
    [panTearDownNoteRecognizer setMinimumNumberOfTouches:2];
    [panTearDownNoteRecognizer setMaximumNumberOfTouches:3];
    
    CGRect rect = label_deleteYES.frame;
    label_deleteYES.frame = CGRectMake(rect.origin.x, self.view.frame.size.height, rect.size.width, rect.size.height);
    
    alphaView.frame = self.view.bounds;
    alphaView.userInteractionEnabled = NO;
    alphaView.backgroundColor = [UIColor blackColor];
    alphaView.alpha = 0.0f;
    
    [self.view insertSubview:bwView belowSubview:colorSettingView];
    [self.view insertSubview:colorBarPicker belowSubview:bwView];
    
    undomanager = [[NSUndoManager alloc]init];
    drawMode = YES ;
    tempSelectMode = 0;
    shapeMode = 0 ;
    currentMode = 0 ;
    previousPoint1 = CGPointMake(-100, -100);
    previousPoint2 = CGPointMake(-100, -100);
    currentPoint = CGPointMake(-100, -100);
    lastFactor = 1;
    tempShapeView = [[UIImageView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:tempShapeView];
    self.view.multipleTouchEnabled = YES;
    [self createEraserView];
    
    colorModeButton.layer.cornerRadius = 20;
    //colorSettingView.clipsToBounds = YES;
    colorBarPicker.hidden = YES;
    [self setColorPickerShadow];
    
    bwView.layer.cornerRadius = 20;
    blackColorButton.layer.cornerRadius = 20 ;
    bwView.transform = CGAffineTransformMakeRotation(90*M_PI/180);
    bwView.frame = CGRectMake(50, 65, 50, 250);
    bwView.hidden = YES;
    
    [self setUpperLowerHalfEffect];
    colorBarPicker.transform = CGAffineTransformMakeRotation(90*M_PI/180);
    colorBarPicker.frame = CGRectMake(-10, 65, 50, 250);
    colorBarPicker.layer.cornerRadius = 20 ;
    
    
    
    edgeAlphaView.layer.cornerRadius = 16;
    edgeAlphaView.layer.shadowColor=[UIColor darkGrayColor].CGColor;
    edgeAlphaView.layer.shadowOffset = CGSizeMake(3.0f,0.0f);
    edgeAlphaView.layer.shadowOpacity = 0.7f;
    edgeAlphaView.layer.shadowRadius = 10.0f;
    edgeAlphaView.alpha = 0.0f;
    
    edgeAlphaViewRight.layer.cornerRadius = 16;
    edgeAlphaViewRight.layer.shadowColor=[UIColor darkGrayColor].CGColor;
    edgeAlphaViewRight.layer.shadowOffset = CGSizeMake(-3.0f,0.0f);
    edgeAlphaViewRight.layer.shadowOpacity = 0.7f;
    edgeAlphaViewRight.layer.shadowRadius = 10.0f;
    edgeAlphaViewRight.alpha = 0.0f;
    
    
    [self.view insertSubview:disableUndoButtonView aboveSubview:undoButton];
    disableUndoButtonView.hidden = NO;
    
    if(!self.noteIndexPath){// if new note
        [homeButton setImage: saveNoteIcon forState:UIControlStateNormal];
    }else{
        [homeButton setImage: settingIcon forState:UIControlStateNormal];
    }
    
    [self.view setNeedsDisplay];
    [self renderTearingImage];
    previousImageBeforeTear = self.mainImage.image;
}
#pragma mark - Set up Method
-(void)setColorPickerShadow{
    colorBarPicker.layer.shadowColor = [[UIColor blackColor] CGColor];
    colorBarPicker.layer.shadowOffset = CGSizeMake(-6.0f,0.0f);
    colorBarPicker.layer.shadowOpacity = 0.5f;
    colorBarPicker.layer.shadowRadius = 5.0f;
    
    bwView.layer.shadowColor = [[UIColor blackColor] CGColor];
    bwView.layer.shadowOffset = CGSizeMake(-6.0f,0.0f);
    bwView.layer.shadowOpacity = 0.5f;
    bwView.layer.shadowRadius = 5.0f;
}

-(void)setUpperLowerHalfEffect{
    upperHalf.hidden = YES;
    upperHalf.clipsToBounds = YES;
    
    lowerHalf.hidden = YES;
    lowerHalf.clipsToBounds = YES;
    bgColorEdittingView.hidden = YES;
    bgColorEdittingView.clipsToBounds = YES;
    upperHalf.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    lowerHalf.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
}
-(void)createEraserView{
    eraserView = [[AunEraserView alloc]initEraserView];
    [self.view addSubview:eraserView];
}
-(void)additionalLoad{
    drawModeIcon = [UIImage imageNamed:@"brushIcon"];
    shapeLineIcon = [UIImage imageNamed:@"shapeLineIcon"];
    shapeRectIcon = [UIImage imageNamed:@"shapeRectangleIcon"];
    shapeCircleIcon = [UIImage imageNamed:@"shapeCircleIcon"];
    
    selectorIcon = [UIImage imageNamed:@"selector"];
    selectorImageView = [[UIImageView alloc]initWithImage:selectorIcon];
    selectorImageView.alpha = 1.0f;
    selectorImageView.frame = CGRectMake(19, 18, 44, 44);
    
    selectorForColorModeImageView = [[UIImageView alloc] initWithImage:selectorIcon];
    selectorForColorModeImageView.alpha = 1.0f;
    selectorForColorModeImageView.frame = CGRectMake(3, 3, 44, 44);
    
    saveNoteIcon = [UIImage imageNamed:@"saveIcon"];
    settingIcon = [UIImage imageNamed:@"settingIcon"];
    
    [bwView addSubview:selectorForColorModeImageView];
    
    [colorSettingView addSubview:selectorImageView];
}
#pragma mark - Gesture Recognizer Handler

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if(colorSettingView.MOVING_BOX_MODE){
        return NO;
    }else if (!colorSettingView.LEFT_NORMAL_MODE&&gestureRecognizer==leftEdgeRecognizer){
        return NO;
    }else if (colorSettingView.LEFT_NORMAL_MODE&&gestureRecognizer==rightEdgeRecognizer){
        return NO;
    }else{
        return YES;
    }
    
}
-(void)handleTearDownPaper:(UIPanGestureRecognizer *)sender{
    if(colorSettingView.PAN_BOX_MODE)return;
    self.tempDrawImage.image = nil;
    tempShapeView.image = nil;
    eraserView.hidden = YES;
    
    CGPoint touchTranslation = [sender translationInView:self.view];
    CGFloat yLocation = touchTranslation.y;
    if(touchTranslation.y>-10){
        //NSLog(@"speed : %f", [sender velocityInView:self.view].y);
        if(sender.state == UIGestureRecognizerStateBegan){
            //[self createTearingImage];
            if(editBeforeTear){
                [self createTearingImage];
                editBeforeTear = NO;
            }
                upperHalf.image = upperTearImage;
                lowerHalf.image = lowerTearImage;
        }
        [self doTearingViewEffect:(yLocation)];
        if(yLocation+90>self.view.frame.size.height-150){
            [self clearPageOrNot];
            if(sender.state==UIGestureRecognizerStateEnded){
                [self clearPage];
                [self renderTearingImage];
                return;
            }
        }else{
            [self abortClearPage];
        }
    }else{
        
    }
    //NSLog(@"%f %f",touchTranslation.x,touchTranslation.y);
    if(sender.state==UIGestureRecognizerStateEnded){
        [self abortTearingViewEffect];
    }
}
-(void)clearPage{
    pinchEraserRecognizer.enabled = NO;
    panTearDownNoteRecognizer.enabled = NO;
    leftEdgeRecognizer.enabled = NO;
    clearingPageNow = YES;
    
    CGRect rect = label_deleteYES.frame;
    self.tempDrawImage.image = nil;
    self.mainImage.image = nil;
    
    label_deleteYES.frame = CGRectMake(rect.origin.x, self.view.frame.size.height, rect.size.width, rect.size.height);
    label_deleteYES.hidden = YES;
    [UIView animateWithDuration:0.8f animations:^{
        label_deleteYES.frame = CGRectMake(rect.origin.x, self.view.frame.size.height, rect.size.width, rect.size.height);
        upperHalf.alpha = 0.0f;
        lowerHalf.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, lowerHalf.frame.size.height);
        bgColorEdittingView.alpha = 0.0f;
    } completion:^(BOOL f){
        upperHalf.hidden = YES;
        lowerHalf.hidden = YES;
        bgColorEdittingView.hidden= YES;
        bgColorEdittingView.alpha = 1.0f;
        upperHalf.alpha = 1.0f;
        pinchEraserRecognizer.enabled = YES;
        panTearDownNoteRecognizer.enabled = YES;
        leftEdgeRecognizer.enabled =YES;
        clearingPageNow = NO;
        label_newPage.hidden = NO;
        [UIView animateWithDuration:1.5f animations:^{
            label_newPage.alpha = 0.0f;
        } completion:^(BOOL f){
            label_newPage.hidden = YES;
            label_newPage.alpha = 1.0f;
        }];
        
    }];
}
-(void)abortClearPage{
    CGRect rect = label_deleteYES.frame;
    
    [UIView animateWithDuration:0.2f animations:^{
        label_deleteYES.frame = CGRectMake(rect.origin.x, self.view.frame.size.height, rect.size.width, rect.size.height);
    } completion:^(BOOL f){ label_deleteYES.hidden = YES;}];
}
-(void)clearPageOrNot{
    label_deleteYES.hidden = NO;
    CGRect rect = label_deleteYES.frame;
    [UIView animateWithDuration:0.2f animations:^{
        label_deleteYES.frame = CGRectMake(rect.origin.x, 256, rect.size.width, rect.size.height);
    } completion:^(BOOL b){}];
}
-(void)handlePinch:(UIPinchGestureRecognizer *)sender{
    CGFloat factor = [sender scale];
    if(tempSelectMode==1){//ERASER ERASER ERASER ERASER ERASER ERASER
        if (sender.state == UIGestureRecognizerStateBegan)
        {
            eraserView.hidden = NO;
            CGFloat radius = eraserView.eraserRadius;
            eraserView.frame = CGRectMake(self.view.frame.size.width/2 - radius, 100-radius, 2*radius, 2*radius);
        }
        
        CGFloat diff = factor - lastFactor;
        eraserView.eraserRadius = eraserView.eraserRadius+10*diff;
        
        if(eraserView.eraserRadius>17){
            eraserView.eraserRadius=17;
        }else if(eraserView.eraserRadius<2){
            eraserView.eraserRadius=2;
        }
        
        CGFloat radius = eraserView.eraserRadius;
        eraserView.frame = CGRectMake(self.view.frame.size.width/2 - radius, 100-radius, 2*radius, 2*radius);
        
        
        lastFactor = factor;
        if (sender.state == UIGestureRecognizerStateEnded)
        {
            lastFactor = 1.0;
            eraserView.hidden = YES;
            [self setCurrentEraserMode];
        }
        
        
    }else if(tempSelectMode==0){//BRUSH BRUSH BRUSH BRUSH BRUSH BRUSH BRUSH
        if (sender.state == UIGestureRecognizerStateBegan)
        {
            eraserView.hidden = NO;
            CGFloat radius = eraserView.brushRadius;
            eraserView.frame = CGRectMake(self.view.frame.size.width/2 - radius, 100-radius, 2*radius, 2*radius);
        }
        
        CGFloat diff = factor - lastFactor;
        eraserView.brushRadius = eraserView.brushRadius+10*diff;
        
        if(eraserView.brushRadius>17){
            eraserView.brushRadius=17;
        }else if(eraserView.brushRadius<1.5){
            eraserView.brushRadius=1.5;
        }
        
        CGFloat radius = eraserView.brushRadius;
        eraserView.frame = CGRectMake(self.view.frame.size.width/2 - radius, 100-radius, 2*radius, 2*radius);
        
        
        lastFactor = factor;
        if (sender.state == UIGestureRecognizerStateEnded)
        {
            lastFactor = 1.0;
            eraserView.hidden = YES;
            [self setCurrentBrushMode];
        }
    }
    self.tempDrawImage.image = nil;
    
}
-(void)handleEdgeRightPan:(UIGestureRecognizer *)gestureRecognizer{
    CGPoint p = [gestureRecognizer locationInView:self.view];
    if(colorSettingView.MOVING_BOX_MODE&&!lastDraggedBoxMode){
        CGPoint temp = [colorSettingView moveViewToPoint:p InSize:self.view.frame.size];
        [UIView animateWithDuration:0.3f animations:^{
            settingGearButton.alpha = 0.0f;
        }];
        
        if(p.x < 20){
            colorSettingView.LEFT_NORMAL_MODE = YES;
            [self animateEdgeShadowAlpha:YES];
        }else if (p.x > 300){
            colorSettingView.LEFT_NORMAL_MODE = NO;
            [self animateEdgeShadowAlpha:YES];
        }else{
            [self animateEdgeShadowAlpha:NO];
        }
        if(gestureRecognizer.state == UIGestureRecognizerStateEnded){
            [self returnModeWithPoint:p andTemp:temp];
            //lastDraggedBoxMode = YES;
            [self animateEdgeShadowAlpha:NO];
        }
        return;
    }
    if(colorSettingView.MOVING_BOX_MODE){
        return;
    }
    
    [colorSettingView moveOutToScreen:alphaView];
    [UIView animateWithDuration:0.3f animations:^{
        settingGearButton.alpha = 1.0f;
    }];
    if(p.x<160 && !colorSettingView.MOVING_BOX_MODE && colorSettingView.finishOnAnimation &&movingBoxEnable){
        [self toMovingBoxModeAtPoint:p];
        colorBarPicker.transform = CGAffineTransformMakeRotation(0);
        bwView.transform = CGAffineTransformMakeRotation(0);
        colorBarPicker.frame = CGRectMake(self.view.frame.size.width/2-125, self.view.frame.size.height , 250, 50);
        colorBarPicker.hidden = YES;
        bwView.hidden = YES;
    }
    
}
-(void)handleEdgePan:(UIGestureRecognizer *)gestureRecognizer{
    CGPoint p = [gestureRecognizer locationInView:self.view];
    if(colorSettingView.MOVING_BOX_MODE&&!lastDraggedBoxMode){
        CGPoint temp = [colorSettingView moveViewToPoint:p InSize:self.view.frame.size];
        [UIView animateWithDuration:0.3f animations:^{
            settingGearButton.alpha = 0.0f;
        }];
        if(p.x < 20){
            colorSettingView.LEFT_NORMAL_MODE = YES;
            [self animateEdgeShadowAlpha:YES];
        }else if (p.x > 300){
            colorSettingView.LEFT_NORMAL_MODE = NO;
            [self animateEdgeShadowAlpha:YES];
        }else{
            [self animateEdgeShadowAlpha:NO];
        }
        if(gestureRecognizer.state == UIGestureRecognizerStateEnded){
            [self returnModeWithPoint:p andTemp:temp];
            //lastDraggedBoxMode = YES;
            [self animateEdgeShadowAlpha:NO];
        }
        return;
    }
    if(colorSettingView.MOVING_BOX_MODE){
        return;
    }
    
    [colorSettingView moveOutToScreen:alphaView];
    [UIView animateWithDuration:0.3f animations:^{
        settingGearButton.alpha = 1.0f;
    }];
    if(p.x>160 && !colorSettingView.MOVING_BOX_MODE && colorSettingView.finishOnAnimation &&movingBoxEnable){
        [self toMovingBoxModeAtPoint:p];
        colorBarPicker.transform = CGAffineTransformMakeRotation(0);
        bwView.transform = CGAffineTransformMakeRotation(0);
        colorBarPicker.frame = CGRectMake(self.view.frame.size.width/2-125, self.view.frame.size.height , 250, 50);
        colorBarPicker.hidden = YES;
        bwView.hidden = YES;
    }
    
}
-(void)returnModeWithPoint:(CGPoint) p andTemp:(CGPoint)temp{
    if(p.x<20){
        colorSettingView.LEFT_NORMAL_MODE = YES;
        [self setBackToNormalMode];
        [self backToNormalForReturning];
        [UIView animateWithDuration:0.2f animations:^{
            colorSettingView.frame = CGRectMake(-15, 60,68, 260);
        } completion:^(BOOL b){
        }];
    }else if(p.x >300){
        colorSettingView.LEFT_NORMAL_MODE = NO;
        [self setBackToNormalMode];
        [self backToNormalForReturning ];
        [UIView animateWithDuration:0.2f animations:^{
            colorSettingView.frame = CGRectMake(267, 60,68, 260);
        } completion:^(BOOL b){
        }];
    }else{
        [colorSettingView animateAdjustingAtPoint:temp inSize:self.view.frame.size];
    }
}
-(void)backToNormalForReturning{
    [colorSettingView disableGesture];
    colorSettingView.clipsToBounds = NO;
    colorSettingView.PAN_BOX_MODE = NO;
    colorSettingView.MOVING_BOX_MODE = NO;
    [colorSettingView.delegate setBackToNormalMode];
    if(colorSettingView.LEFT_NORMAL_MODE){
        [UIView animateWithDuration:0.2f animations:^{
            colorSettingView.frame = CGRectMake(-15, 60,68, 260);
        } completion:^(BOOL b){
        }];
    }
    else{
        [UIView animateWithDuration:0.2f animations:^{
            colorSettingView.frame = CGRectMake(267, 60,68, 260);
        } completion:^(BOOL b){
        }];
    }
}
#pragma mark - touches Event method
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    if(colorSettingView.PAN_BOX_MODE){
        return;
    }
    if(clearingPageNow){
        return;
    }
    UITouch *touch = [touches anyObject];
    previousPoint1 = [touch previousLocationInView:self.view];
    previousPoint2 = [touch previousLocationInView:self.view];
    currentPoint = [touch locationInView:self.view];
    touchLocation1 = [touch locationInView:self.view];
    if(tempSelectMode==0||tempSelectMode==3){
        [self setCurrentBrushMode];
    }else if(tempSelectMode==1){
        [self setCurrentEraserMode];
    }
    if(colorSettingView.on&&!colorSettingView.MOVING_BOX_MODE){//on and not boxmode
        [colorSettingView moveInside:alphaView];
        [UIView animateWithDuration:0.3 animations:^{
            settingGearButton.alpha = 0.0f;
        }];
        colorBarPicker.hidden = YES;
        bwView.hidden = YES;
        fromColorViewMode = YES;
    }
    
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if(colorSettingView.PAN_BOX_MODE){
        [self setModeButtonsUserInteractionEnabled:NO];
        currentSelectedButton.frame = CGRectMake(5, 5, currentSelectedButton.frame.size.width, currentSelectedButton.frame.size.height);
        selectorImageView.frame = currentSelectedButton.frame;
        bwView.hidden = YES;
        colorBarPicker.hidden = YES;
        [UIView animateWithDuration:0.25f animations:^{
            alphaView.alpha = 0.0f;
        } completion:^(BOOL f){
        }];
        
        [colorSettingView moveBackFromPanMode];
        return;
    }
    if(clearingPageNow){
        return;
    }
    if(colorSettingView.on&&!colorSettingView.MOVING_BOX_MODE){// now setting
        return;
    }
    if(tempSelectMode==3){
        [self endShapeDrawing];
        return;
    }
    if(!mouseSwiped) {
        if(fromColorViewMode){
            fromColorViewMode = NO;
            return;
        }
        UIGraphicsBeginImageContext(self.view.frame.size);
        [self.tempDrawImage.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), cRadius*2);
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), cRed, cGreen, cBlue, cAlpha);
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
        CGContextStrokePath(UIGraphicsGetCurrentContext());
        CGContextFlush(UIGraphicsGetCurrentContext());
        self.tempDrawImage.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    //CGSize *half = CGSizeMake(self.mainImage.frame.size.width, self.mainImage.frame.size.height);
    
    UIGraphicsBeginImageContext(self.mainImage.frame.size);
    [self.mainImage.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) blendMode:kCGBlendModeNormal alpha:1.0];
    [self.tempDrawImage.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) blendMode:kCGBlendModeNormal alpha:cAlpha];
    
    [self setMainImageAndUndo:UIGraphicsGetImageFromCurrentImageContext()];
    self.tempDrawImage.image = nil;
    UIGraphicsEndImageContext();
    
    if([undomanager canUndo]){
        disableUndoButtonView.hidden = YES;
    }
    //NSLog(@"hey");
    
    mouseSwiped = NO;
    editBeforeTear = YES;
    eraserView.hidden = YES;
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    //CFAbsoluteTime initTime = CFAbsoluteTimeGetCurrent();
    if(colorSettingView.PAN_BOX_MODE){
        return;
    }
    if(clearingPageNow){
        return;
    }
    UITouch *touch = [touches anyObject];
    previousPoint2 = previousPoint1;
    previousPoint1 = [touch previousLocationInView:self.view];
    currentPoint = [touch locationInView:self.view];
    if(colorSettingView.on&&!colorSettingView.MOVING_BOX_MODE){
        return;
    }
    
    
    mouseSwiped = YES;
    
    if(tempSelectMode==3){
        if(shapeMode==0){
            [self drawShapeLine:currentPoint];
        }else if(shapeMode==1){
            [self drawShapeRect:currentPoint];
        }else if (shapeMode==2){
            [self drawShapeCircle:currentPoint];
        }
        return;
    }
    if(tempSelectMode==0||tempSelectMode ==1){
        eraserView.hidden = NO;
    }
    
    eraserView.frame = CGRectMake(currentPoint.x-cRadius, currentPoint.y-cRadius, cRadius*2, cRadius*2);
    
    // calculate mid point
    CGPoint mid1 = midPoint(previousPoint1, previousPoint2);
    CGPoint mid2 = midPoint(currentPoint, previousPoint1);
    
    UIImageView *imageView = self.tempDrawImage ;
    UIGraphicsBeginImageContext(imageView.frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [imageView.image drawInRect:CGRectMake(0, 0, imageView.frame.size.width, imageView.frame.size.height)];
    
    CGContextMoveToPoint(context, mid1.x, mid1.y);
    // Use QuadCurve is the key
    CGContextAddQuadCurveToPoint(context, previousPoint1.x, previousPoint1.y, mid2.x, mid2.y);
    
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineWidth(context, 2*cRadius);
    CGContextSetRGBStrokeColor(context, cRed , cGreen, cBlue, 1);
    CGContextStrokePath(context);
    
    imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    [imageView setAlpha:cAlpha];
    UIGraphicsEndImageContext();
    
    //NSLog(@"time %f",CFAbsoluteTimeGetCurrent() - initTime);
    
}
-(CGFloat)distanceBetweenPoints:(CGPoint)curr :(CGPoint)prev{
    return sqrt(pow(curr.x-prev.x, 2)+pow(curr.y-prev.y, 2));
}

#pragma mark - User-Driven Button
- (IBAction)toBlackColorMode:(id)sender {
    hueMode = NO;
    eraserView.brushAlpha = 1.0f;
    eraserView.brushR = 0.0f;
    eraserView.brushG = 0.0f;
    eraserView.brushB = 0.0f;
    
    bwSlider.value = 1.0f;
    UIColor *currentBrushColor = [UIColor colorWithRed:eraserView.brushR green:eraserView.brushG  blue:eraserView.brushB  alpha:eraserView.brushAlpha];
    [colorModeButton setBackgroundColor:currentBrushColor];
    [bwSlider setMinimumTrackTintColor:currentBrushColor];
    
    colorBarPicker.hidden = YES;
    
    CGPoint refRect = blackColorButton.frame.origin;
    selectorForColorModeImageView.frame = CGRectMake(refRect.x-2, refRect.y-2, 44, 44);
}
- (IBAction)toHueColorMode:(id)sender {
    [self toHueColorModeMethod];
}

- (IBAction)undoButtonPush:(id)sender {
    if([undomanager canUndo]){
        [undomanager undo];
        editBeforeTear = YES;
        if(![undomanager canUndo]){
            disableUndoButtonView.hidden = NO;
        }
    }
}

- (IBAction)sliderChanged:(id)sender {
    eraserView.brushAlpha = bwSlider.value;
    UIColor *currentBrushColor = [UIColor colorWithRed:eraserView.brushR green:eraserView.brushG  blue:eraserView.brushB  alpha:eraserView.brushAlpha];
    //bwSlider.backgroundColor = currentBrushColor;
    [colorModeButton setBackgroundColor:currentBrushColor];
}

- (IBAction)takeBarValue:(AunColorBarPicker *)sender {
    UIColor *resultColor = [UIColor colorWithHue:sender.value saturation:1.0f brightness:1.0f alpha:eraserView.brushAlpha];
    const CGFloat* components = CGColorGetComponents(resultColor.CGColor);
    [eraserView setBrushR:components[0] G:components[1] B:components[2] A:eraserView.brushAlpha];
    //suspicious!!
    [colorModeButton setBackgroundColor:resultColor];
    [bwSlider setMinimumTrackTintColor:resultColor];
}
- (IBAction)selectColor:(id)sender {
    bwView.hidden = NO;
    if(tempSelectMode==1){//uitility method
        if(selectModeBeforeEraser==0){
            selectorImageView.frame = brushModeButton.frame;
            currentSelectedButton = brushModeButton;
            tempSelectMode = 0 ;
        }else if(selectModeBeforeEraser==3){
            selectorImageView.frame = shapeModeButton.frame;
            currentSelectedButton = shapeModeButton;
            tempSelectMode = 3 ;
        }
    }
    
    
    if(!colorSettingView.PAN_BOX_MODE){
        if(colorSettingView.LEFT_NORMAL_MODE){
            bwView.frame = CGRectMake(-20, 65, 50, 250);
            
            [UIView animateWithDuration:0.25f animations:^{
                //colorBarPicker.frame = CGRectMake(60, 65, 50, 250);
                bwView.frame = CGRectMake(60, 65, 50, 250);
                alphaView.alpha = 0.5f;
            } completion:^(BOOL f){
            }];
        }else{
            bwView.frame = CGRectMake(290, 65, 50, 250);
            
            [UIView animateWithDuration:0.25f animations:^{
                //colorBarPicker.frame = CGRectMake(60, 65, 50, 250);
                bwView.frame = CGRectMake(210, 65, 50, 250);
                alphaView.alpha = 0.5f;
            } completion:^(BOOL f){
            }];
        }
    }else{
        bwView.frame = CGRectMake(self.view.frame.size.width/2-125, colorSettingView.frame.origin.y+pan_box_width-40, 250, 50);
        
        [UIView animateWithDuration:0.25f animations:^{
            bwView.frame = CGRectMake(self.view.frame.size.width/2-125,colorSettingView.frame.origin.y+pan_box_width+20 , 250, 50);
            alphaView.alpha = 0.5f;
        } completion:^(BOOL f){
        }];
    }
    
    if(hueMode){
        [self toHueColorModeMethod];
    }
}

//}
- (IBAction)selectShapeMode:(id)sender {
    if(tempSelectMode != 3){
        selectorImageView.frame = shapeModeButton.frame;
        tempSelectMode = 3 ;
        currentSelectedButton = shapeModeButton;
        return ;
    }
    if(shapeMode==0){
        [shapeModeButton setImage:shapeRectIcon forState:UIControlStateNormal];
        shapeMode = 1 ;
    }else if(shapeMode==1){
        [shapeModeButton setImage:shapeCircleIcon forState:UIControlStateNormal];
        shapeMode = 2 ;
    }else if (shapeMode==2){
        [shapeModeButton setImage:shapeLineIcon forState:UIControlStateNormal];
        shapeMode = 0 ;
    }else{

    }
}
- (IBAction)selectEraser:(id)sender {
    if(tempSelectMode != 1){
        selectModeBeforeEraser = tempSelectMode;
        tempSelectMode = 1 ;
        currentSelectedButton = eraserModeButton;
        selectorImageView.frame = eraserModeButton.frame;
        
        const CGFloat* components = CGColorGetComponents(self.view.backgroundColor.CGColor);
        [eraserView setEraserR:components[0] G:components[1] B:components[2] A:eraserView.eraserAlpha];
        
        //        CAKeyframeAnimation *springEffect = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
        //        springEffect.values = @[@(0.1), @(1.4), @(0.95), @(1)];
        //        springEffect.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        //        springEffect.removedOnCompletion = NO;
        //        springEffect.duration = 0.08f;
        //        springEffect.delegate = self;
        //        [eraserView.layer addAnimation:springEffect forKey:@"springeffect"];
    }
    
}

- (IBAction)changeBrushMode:(id)sender {
    if(tempSelectMode != 0){
        selectorImageView.frame = brushModeButton.frame;
        currentSelectedButton = brushModeButton;
        tempSelectMode = 0 ;
        return ;
    }
    //    if(drawMode){
    //        [brushModeButton setImage:writeModeIcon forState:UIControlStateNormal];
    //        drawMode = NO;
    //    }else{
    //        [brushModeButton setImage:drawModeIcon forState:UIControlStateNormal];
    //        drawMode = YES;
    //    }
    [brushModeButton setImage:drawModeIcon forState:UIControlStateNormal];
    drawMode = YES;
}

- (IBAction)settingGearButtonPushed:(id)sender {
    
}

-(void)drawShapeLine:(CGPoint) location2{
    touchLocation2 = location2;
    UIGraphicsBeginImageContext(self.view.frame.size);
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), eraserView.brushRadius*2);
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), cRed, cGreen, cBlue, 1);
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), touchLocation1.x, touchLocation1.y);
    
    CGFloat deltaY = touchLocation2.y - touchLocation1.y;
    CGFloat deltaX = touchLocation2.x - touchLocation1.x;
    CGFloat angleInDegrees = -atan2(deltaY, deltaX) * 180 / M_PI;
    if(angleInDegrees<0)angleInDegrees+=360;
    CGFloat yOffset = 0 ;
    if(abs(angleInDegrees-45)<=5){
        yOffset = deltaX*(1-tanf(angleInDegrees*M_PI/180));
    }else if(abs(angleInDegrees-135)<=5){
        yOffset = deltaX*(-1-tanf(angleInDegrees*M_PI/180));
    }else if(abs(angleInDegrees-225)<=5){
        yOffset = deltaX*(1-tanf(angleInDegrees*M_PI/180));
    }else if(abs(angleInDegrees-315)<=5){
        yOffset = deltaX*(-1-tanf(angleInDegrees*M_PI/180));
    }else if(abs(angleInDegrees-0)<=5){
        yOffset = deltaX*(0-tanf(angleInDegrees*M_PI/180));
    }else if(abs(angleInDegrees-90)<=5){
        touchLocation2.x = touchLocation1.x;
    }else if(abs(angleInDegrees-180)<=5){
        yOffset = deltaX*(0-tanf(angleInDegrees*M_PI/180));
    }else if(abs(angleInDegrees-270)<=5){
        touchLocation2.x = touchLocation1.x;
    }
    
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), touchLocation2.x, touchLocation2.y-yOffset);
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    CGContextFlush(UIGraphicsGetCurrentContext());
    tempShapeView.image =UIGraphicsGetImageFromCurrentImageContext();
    [tempShapeView setAlpha:cAlpha];
    UIGraphicsEndImageContext();
}
-(void)drawShapeRect:(CGPoint) location2{
    
    touchLocation2 = location2;
    UIGraphicsBeginImageContext(self.view.frame.size);
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), eraserView.brushRadius*2);
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), cRed, cGreen, cBlue, 1);
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), touchLocation1.x, touchLocation1.y);
    CGFloat width = touchLocation2.x-touchLocation1.x;
    CGFloat height = touchLocation2.y-touchLocation1.y;
    CGContextAddRect(UIGraphicsGetCurrentContext(), CGRectMake(touchLocation1.x, touchLocation1.y, width, height));
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    
    CGContextFlush(UIGraphicsGetCurrentContext());
    tempShapeView.image =UIGraphicsGetImageFromCurrentImageContext();
    [tempShapeView setAlpha:cAlpha];
    UIGraphicsEndImageContext();
}
-(void)drawShapeCircle:(CGPoint) location2{
    touchLocation2 = location2;
    UIGraphicsBeginImageContext(self.view.frame.size);
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), eraserView.brushRadius*2);
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), cRed, cGreen, cBlue, 1);
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), touchLocation1.x, touchLocation1.y);
    CGFloat w = touchLocation2.x-touchLocation1.x;
    CGFloat h = touchLocation2.y-touchLocation1.y;
    if(w-h<=20&&w-h>=-20)h=w;
    CGContextAddEllipseInRect(UIGraphicsGetCurrentContext(), CGRectMake(touchLocation1.x, touchLocation1.y, w, h));
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    
    CGContextFlush(UIGraphicsGetCurrentContext());
    tempShapeView.image =UIGraphicsGetImageFromCurrentImageContext();
    [tempShapeView setAlpha:cAlpha];
    UIGraphicsEndImageContext();
}
-(void) endShapeDrawing{
    UIGraphicsBeginImageContext(self.mainImage.frame.size);
    [self.mainImage.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) blendMode:kCGBlendModeNormal alpha:1.0];
    [tempShapeView.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) blendMode:kCGBlendModeNormal alpha:cAlpha];
    [self setMainImageAndUndo:UIGraphicsGetImageFromCurrentImageContext()];
    
    tempShapeView.image = nil;
    UIGraphicsEndImageContext();
}
#pragma mark - Core Data
- (NSManagedObjectContext *)managedObjectContext
{
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}
#pragma mark - Adjust Method
-(void)setMainImageAndUndo:(UIImage *)mainImage{
    if(_mainImage.image != mainImage){
        [[undomanager prepareWithInvocationTarget:self] setMainImageAndUndo:_mainImage.image];
        self.mainImage.image = mainImage;
    }
    
}
-(void)toMovingBoxModeAtPoint:(CGPoint) p{
    [self setModeButtonsUserInteractionEnabled:NO];
    brushModeButton.frame = CGRectMake(pan_box_width/2-button_width/2, 10, button_width, button_width);
    eraserModeButton.frame = CGRectMake(10, pan_box_width/2-button_width/2, button_width, button_width);
    colorModeButton.frame = CGRectMake(pan_box_width/2-button_width/2, 110, button_width, button_width);
    imageBehindColorView.frame = CGRectMake(pan_box_width/2-button_width/2, 110, button_width, button_width);
    shapeModeButton.frame = CGRectMake(110, pan_box_width/2-button_width/2, button_width, button_width);
    [colorSettingView goToMovingBoxMode];
    currentSelectedButton.frame = CGRectMake(5, 5, currentSelectedButton.frame.size.width, currentSelectedButton.frame.size.height);
    selectorImageView.frame = currentSelectedButton.frame;
    [UIView animateWithDuration:0.2f  animations:^{
        colorSettingView.frame = CGRectMake(p.x-mode_box_width/2, p.y-mode_box_width/2,mode_box_width, mode_box_width);
        alphaView.alpha = 0.0f;
    } completion:^(BOOL b){
        //[colorSettingView.layer addAnimation:springEffect forKey:@"springcolorsettingview"];
    }];
    
}
-(void) setModeButtonsUserInteractionEnabled:(BOOL)b{
    colorModeButton.userInteractionEnabled = b;
    imageBehindColorView.userInteractionEnabled = b;
    shapeModeButton.userInteractionEnabled = b;
    brushModeButton.userInteractionEnabled = b;
    eraserModeButton.userInteractionEnabled = b;
}
-(void)changeToPanMode{
    [self setModeButtonsUserInteractionEnabled:YES];
    brushModeButton.frame = CGRectMake(pan_box_width/2-button_width/2, 10, button_width, button_width);
    eraserModeButton.frame = CGRectMake(10, pan_box_width/2-button_width/2, button_width, button_width);
    colorModeButton.frame = CGRectMake(pan_box_width/2-button_width/2, 110, button_width, button_width);
    imageBehindColorView.frame = CGRectMake(pan_box_width/2-button_width/2, 110, button_width, button_width);
    shapeModeButton.frame = CGRectMake(110, pan_box_width/2-button_width/2, button_width, button_width);
    selectorImageView.frame = currentSelectedButton.frame;
    
    brushModeButton.alpha = 0.0f;
    eraserModeButton.alpha = 0.0f;
    colorModeButton.alpha = 0.0f;
    shapeModeButton.alpha = 0.0f;
    currentSelectedButton.alpha = 1.0f;
    
    [UIView animateWithDuration:0.2f animations:^{
        brushModeButton.alpha = 1.0f;
        eraserModeButton.alpha = 1.0f;
        colorModeButton.alpha = 1.0f;
        
        shapeModeButton.alpha = 1.0f;
        colorSettingView.frame = CGRectMake(self.view.frame.size.width/2-pan_box_width/2, self.view.frame.size.height/2-pan_box_width/2, pan_box_width, pan_box_width);
    } completion:^(BOOL b){
    }];
}

-(void)setBackToNormalMode{
    if(colorSettingView.LEFT_NORMAL_MODE){
        brushModeButton.frame = CGRectMake(21, 20, button_width, button_width);
        eraserModeButton.frame = CGRectMake(21, 80, button_width, button_width);
        colorModeButton.frame = CGRectMake(21, 140, button_width, button_width);
        imageBehindColorView.frame = CGRectMake(21, 140, button_width, button_width);
        shapeModeButton.frame = CGRectMake(21, 200, button_width, button_width);
        selectorImageView.frame = currentSelectedButton.frame;
    }else{
        brushModeButton.frame = CGRectMake(6, 20, button_width, button_width);
        eraserModeButton.frame = CGRectMake(6, 80, button_width, button_width);
        colorModeButton.frame = CGRectMake(6, 140, button_width, button_width);
        imageBehindColorView.frame = CGRectMake(6, 140, button_width, button_width);
        shapeModeButton.frame = CGRectMake(6, 200, button_width, button_width);
        selectorImageView.frame = currentSelectedButton.frame;
    }
    
    colorBarPicker.transform = CGAffineTransformMakeRotation(90*M_PI/180);
    bwView.transform = CGAffineTransformMakeRotation(90*M_PI/180);
    if(colorSettingView.LEFT_NORMAL_MODE){
        colorBarPicker.frame = CGRectMake(-10, 65, 50, 250);
        colorBarPicker.hidden = YES;
        bwView.frame = CGRectMake(50, 65, 50, 250);
        bwView.hidden = YES;
    }else{
        colorBarPicker.frame = CGRectMake(280, 65, 50, 250);
        colorBarPicker.hidden = YES;
        bwView.frame = CGRectMake(220, 65, 50, 250);
        bwView.hidden = YES;
        
    }
    
    
    lastDraggedBoxMode = NO;
    [self setModeButtonsUserInteractionEnabled:YES];
}
-(void)setHiddenEraserViewComponents:(BOOL)b{
    brushModeButton.hidden = b;
    eraserModeButton.hidden = b;
    colorModeButton.hidden = b;
    imageBehindColorView.hidden = b;
    shapeModeButton.hidden = b;
    currentSelectedButton.hidden = false;
}
-(void)setTempDrawImageNull{
    self.tempDrawImage.image = nil;
}
-(void) toHueColorModeMethod{
    hueMode = YES;
    colorBarPicker.hidden = NO;
    UIColor *resultColor = [UIColor colorWithHue:colorBarPicker.value saturation:1.0f brightness:1.0f alpha:eraserView.brushAlpha];
    [bwSlider setMinimumTrackTintColor:resultColor];
    const CGFloat* components = CGColorGetComponents(resultColor.CGColor);
    [eraserView setBrushR:components[0] G:components[1] B:components[2] A:eraserView.brushAlpha];
    [colorModeButton setBackgroundColor:resultColor];
    if(!colorSettingView.PAN_BOX_MODE){
        CGPoint refRect = hueColorButton.frame.origin;
        if(colorSettingView.LEFT_NORMAL_MODE){
            selectorForColorModeImageView.frame = CGRectMake(refRect.x-2, refRect.y-2, 44, 44);
            colorBarPicker.frame = bwView.frame;
            [UIView animateWithDuration:0.25f animations:^{
                colorBarPicker.frame = CGRectMake(117, 65, 50, 250);
            } completion:^(BOOL B){
                
            }];
        }else{
            selectorForColorModeImageView.frame = CGRectMake(refRect.x-2, refRect.y-2, 44, 44);
            colorBarPicker.frame = bwView.frame;
            [UIView animateWithDuration:0.25f animations:^{
                colorBarPicker.frame = CGRectMake(153, 65, 50, 250);
            } completion:^(BOOL B){
                
            }];
        }
    }else{
        CGPoint refRect = hueColorButton.frame.origin;
        selectorForColorModeImageView.frame = CGRectMake(refRect.x-2, refRect.y-2, 44, 44);
        colorBarPicker.frame = bwView.frame;
        [UIView animateWithDuration:0.25f animations:^{
            colorBarPicker.frame = CGRectMake(self.view.frame.size.width/2-125,colorSettingView.frame.origin.y+pan_box_width+80 , 250, 50);
        } completion:^(BOOL f){
        }];
    }
}
-(void)setCurrentBrushMode{//use to adjust brush property after changing from eraser mode
    cRed = eraserView.brushR;
    cGreen = eraserView.brushG;
    cBlue = eraserView.brushB;
    cAlpha = eraserView.brushAlpha;
    cRadius = eraserView.brushRadius;
    eraserView.frame = CGRectMake(100, 100, cRadius*2, cRadius*2);
    
}
-(void)setCurrentEraserMode{
    cRed = eraserView.eraserR;
    cGreen = eraserView.eraserG;
    cBlue = eraserView.eraserB;
    cAlpha = eraserView.eraserAlpha;
    cRadius = eraserView.eraserRadius;
    eraserView.frame = CGRectMake(100, 100, cRadius*2, cRadius*2);
}
#pragma mark - utilities
-(int)getRandomNumFrom: (int) min To: (int) max{
    if(min > max){
        int temp = max ;
        max = min ;
        min = temp ;
    }
    return min + arc4random()%(max-min+1) ;
}
CGPoint midPoint(CGPoint p1, CGPoint p2)
{
    
    return CGPointMake((p1.x + p2.x) * 0.5, (p1.y + p2.y) * 0.5);
    
}
#pragma mark - Animation Handler method

-(void)setSpringAnimation{
    springEffect = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    springEffect.values = @[@(0.1), @(1.4), @(0.95), @(1)];
    springEffect.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    springEffect.removedOnCompletion = NO;
    springEffect.duration = 0.35f;
    springEffect.delegate = self;
}
-(void)animateEdgeShadowAlpha:(BOOL)b{
    UIView *targetAlphaView;

    if(colorSettingView.LEFT_NORMAL_MODE){
        targetAlphaView = edgeAlphaView;
    }else{
        targetAlphaView = edgeAlphaViewRight;
    }
    if(b&&targetAlphaView.alpha == 1.0f)return;
    if(!b&&targetAlphaView.alpha == 0.0f) return;
    if(b){
        [UIView animateWithDuration:0.2f animations:^{
            targetAlphaView.alpha = 1.0f;
        }];
    }else{
        [UIView animateWithDuration:0.2f animations:^{
            targetAlphaView.alpha = 0.0f;
        }];
    }
}
-(void)doTearingViewEffect:(CGFloat) yLocation{
    //    upperHalf.image = self.mainImage.image;
    //    lowerHalf.image = self.mainImage.image;
    upperHalf.hidden = NO;
    lowerHalf.hidden = NO;
    bgColorEdittingView.hidden= NO;
    //test
    lowerHalf.frame = CGRectMake(0, yLocation, self.view.frame.size.width, lowerHalf.frame.size.height);
}
-(void)abortTearingViewEffect{
    [UIView animateWithDuration:0.3f animations:^{
        lowerHalf.frame = CGRectMake(0, 0, self.view.frame.size.width, lowerHalf.frame.size.height);
    } completion:^(BOOL f){
        if(f){
            upperHalf.hidden = YES;
            lowerHalf.hidden = YES;
            bgColorEdittingView.hidden= YES;
            [self renderTearingImage];
        }
    }];
}
-(void)createTearingImage{
    
    CGRect r = upperHalf.bounds;
    UIGraphicsBeginImageContextWithOptions(r.size, NO, 0);
    
    UIBezierPath *up = [UIBezierPath bezierPath];
    up.lineJoinStyle = kCGLineJoinMiter;
    CGPoint start = CGPointMake(0,[self getRandomNumFrom:80 To:120]);
    [up moveToPoint:start];
    
    for(int i =10 ; i <= self.view.frame.size.width ; i+=[self getRandomNumFrom:3 To:10]){
        CGPoint temp =CGPointMake(i, [self getRandomNumFrom:80 To:120]);
        [up addLineToPoint:temp];
    }
    CGPoint temp =CGPointMake(upperHalf.frame.size.width, [self getRandomNumFrom:80 To:120]);
    [up addLineToPoint:temp];
    UIBezierPath *down = [UIBezierPath bezierPathWithCGPath:up.CGPath];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    [up addLineToPoint:CGPointMake(upperHalf.frame.size.width, 0)];
    [up addLineToPoint:CGPointMake(0, 0)];
    [up closePath];
    [up stroke];
    [up addClip];
    
    CGContextSetFillColorWithColor(context, self.view.backgroundColor.CGColor);
    CGContextFillRect(context, upperHalf.frame);
    [self.mainImage.image drawInRect:upperHalf.bounds];
    //upperHalf.image = UIGraphicsGetImageFromCurrentImageContext();
    upperTearImage = UIGraphicsGetImageFromCurrentImageContext();
    
    
    
    CGContextRestoreGState(context);
    CGContextClearRect(context, lowerHalf.bounds);
    [down addLineToPoint:CGPointMake(lowerHalf.frame.size.width, lowerHalf.frame.size.height)];
    [down addLineToPoint:CGPointMake(0, lowerHalf.frame.size.height)];
    [down closePath];
    [down stroke];
    [down addClip];
    CGContextSetFillColorWithColor(context, self.view.backgroundColor.CGColor);
    CGContextFillRect(context, upperHalf.frame);
    [self.mainImage.image drawInRect:lowerHalf.bounds];
    //lowerHalf.image = UIGraphicsGetImageFromCurrentImageContext();
    lowerTearImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"ToSetting"]){
        AunSettingViewController *vc = (AunSettingViewController*)[segue destinationViewController];
        vc.on = movingBoxEnable;
    }
}

-(void)renderTearingImage{
    [renderingQueue addOperationWithBlock:^{
        [self createTearingImage];
    }];
}
-(IBAction)settingDone:(UIStoryboardSegue*)segue{
    AunSettingViewController *vc = (AunSettingViewController*)[segue sourceViewController];
    movingBoxEnable = vc.switchButton.on;
}

@end
