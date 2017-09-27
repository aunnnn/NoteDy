//
//  AunColorSettingView.h
//  DrawNotes
//
//  Created by Wirawit Rueopas on 4/5/2557 BE.
//  Copyright (c) 2557 Wirawit Rueopas. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol sampleDelegate <NSObject>
@required
-(void)changeToPanMode;
-(void)animateEdgeShadowAlpha:(BOOL)b;
-(void)setBackToNormalMode;
-(void)setTempDrawImageNull;
-(void)setHiddenEraserViewComponents:(BOOL)b;
@end

@interface AunColorSettingView : UIView
{
    
    UITapGestureRecognizer *tapGesture;
    UIPanGestureRecognizer *panGesture;
    CGPoint pointBeforePan;
}
@property BOOL on ; //NO only if this view is aside the screen
@property BOOL finishOnAnimation;
@property BOOL MOVING_BOX_MODE ; //YES if this view has already came out from the side
@property BOOL PAN_BOX_MODE ; //YES if this view is pan on the center of the screen
@property BOOL LEFT_NORMAL_MODE ; // left or right
@property id<sampleDelegate>delegate;
-(void)moveOutToScreen:(UIView*)parentView;
-(void)moveInside:(UIView*)parentView;
-(CGPoint)moveViewToPoint: (CGPoint)point InSize:(CGSize) superViewSize;
-(void)animateAdjustingAtPoint:(CGPoint) point inSize:(CGSize) superViewSize;
-(void)moveBackFromPanMode;
-(void)goToMovingBoxMode;
-(void)disableGesture;

@end
