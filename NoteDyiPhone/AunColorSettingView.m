//
//  AunColorSettingView.m
//  DrawNotes
//
//  Created by Wirawit Rueopas on 4/5/2557 BE.
//  Copyright (c) 2557 Wirawit Rueopas. All rights reserved.
//

#import "AunColorSettingView.h"
#import "AunConstants.h"
@implementation AunColorSettingView

-(void)commonInit{
    self.LEFT_NORMAL_MODE = YES;
    self.frame = CGRectMake(-colorSettingView_WIDTH, colorSettingView_OFFSET_Y, colorSettingView_WIDTH, colorSettingView_HEIGHT);
    
    self.on = NO;
    self.backgroundColor = [UIColor colorWithRed:24.0/255.0 green:148.0/255.0 blue:184.0/255.0 alpha:1.0];
    
    self.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.layer.shadowOffset = CGSizeMake(-6.0f,0.0f);
    self.layer.shadowOpacity = 0.5f;
    self.layer.shadowRadius = 5.0f;
    
    panGesture = [[UIPanGestureRecognizer alloc]
                  initWithTarget:self
                  action:@selector(viewDragged:)] ;
	[self addGestureRecognizer:panGesture];
    
    tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(viewTapped:)];
    [tapGesture setNumberOfTapsRequired:1];
    [self addGestureRecognizer:tapGesture];
}
-(void)viewTapped:(UIGestureRecognizer*)gesture{
    if(self.PAN_BOX_MODE||!self.MOVING_BOX_MODE) return;
    self.PAN_BOX_MODE = YES;
    pointBeforePan = [gesture locationInView:self.superview];
    if(pointBeforePan.x >= self.superview.frame.size.width-mode_box_width/2){
        pointBeforePan.x = self.superview.frame.size.width-mode_box_width/2;
    }else if(pointBeforePan.x <= mode_box_width/2){
        pointBeforePan.x = mode_box_width/2;
    }
    if(pointBeforePan.y >= self.superview.frame.size.height-mode_box_width/2){
        pointBeforePan.y = self.superview.frame.size.height-mode_box_width/2;
    }else if(pointBeforePan.y <= mode_box_width/2){
        pointBeforePan.y = mode_box_width/2;
    }
    [self.delegate changeToPanMode];
}
-(void)viewDragged:(UIGestureRecognizer*)gesture{
    [self.delegate setTempDrawImageNull];
    if(!self.MOVING_BOX_MODE)return;
    if(self.PAN_BOX_MODE)return;
    CGPoint fingerLocation = [gesture locationInView:self.superview];
    CGSize superViewSize = self.superview.frame.size;
    CGPoint resultLocation = [self moveViewToPoint:fingerLocation InSize:superViewSize];
    if(fingerLocation.x < 20 ){
        self.LEFT_NORMAL_MODE = YES;
        [self.delegate animateEdgeShadowAlpha:YES];
        if(gesture.state == UIGestureRecognizerStateEnded){
            [self backToNormalMode];
            [self.delegate animateEdgeShadowAlpha:NO];
        }
    }else if(fingerLocation.x > 300){
        self.LEFT_NORMAL_MODE = NO;
        [self.delegate animateEdgeShadowAlpha:YES];
        if(gesture.state == UIGestureRecognizerStateEnded){
            [self backToNormalMode];
            [self.delegate animateEdgeShadowAlpha:NO];
        }
    }else{
        [self.delegate animateEdgeShadowAlpha:NO];
        if(gesture.state == UIGestureRecognizerStateEnded){
            [self animateAdjustingAtPoint:resultLocation inSize:superViewSize];
        }
    }
    
}
-(void)backToNormalMode{
    tapGesture.enabled = NO;
    panGesture.enabled = NO;
    self.clipsToBounds = NO;
    self.PAN_BOX_MODE = NO;
    self.MOVING_BOX_MODE = NO;
    [self.delegate setBackToNormalMode];
    if(self.LEFT_NORMAL_MODE){
        [UIView animateWithDuration:0.2f animations:^{
            self.frame = CGRectMake(-colorSettingView_OFFSET_X, colorSettingView_OFFSET_Y,colorSettingView_WIDTH, colorSettingView_HEIGHT);
        } completion:^(BOOL b){
        }];
    }
    else{
        [UIView animateWithDuration:0.2f animations:^{
            self.frame = CGRectMake(320-colorSettingView_WIDTH+colorSettingView_OFFSET_X, colorSettingView_OFFSET_Y,colorSettingView_WIDTH, colorSettingView_HEIGHT);
        } completion:^(BOOL b){
        }];
    }
}
-(void)disableGesture{
    tapGesture.enabled = NO;
    panGesture.enabled = NO;
}
-(void)goToMovingBoxMode{
    tapGesture.enabled = YES;
    panGesture.enabled = YES;
    self.MOVING_BOX_MODE =  YES;
    self.clipsToBounds = YES;
}
-(void)moveBackFromPanMode{
    self.PAN_BOX_MODE = NO;
    [self.delegate setHiddenEraserViewComponents:YES];
    [UIView animateWithDuration:0.2f animations:^{
        self.frame = CGRectMake(pointBeforePan.x-mode_box_width/2, pointBeforePan.y-mode_box_width/2,mode_box_width, mode_box_width);
    } completion:^(BOOL b){
        [self.delegate setHiddenEraserViewComponents:NO];
    }];
    
}
-(id)initWithCoder:(NSCoder *)aDecoder{
    if ((self = [super initWithCoder:aDecoder])) {
        [self commonInit];
    }
    return self;
}
-(CGPoint)moveViewToPoint: (CGPoint)point InSize:(CGSize) superViewSize{
    if(point.x+mode_box_width/2 > superViewSize.width+screen_box_offset){
        point.x = superViewSize.width-mode_box_width/2+screen_box_offset;
    }
    if(point.x-mode_box_width/2 < 0-screen_box_offset){
        point.x = mode_box_width/2-screen_box_offset;
    }
    if(point.y-mode_box_width/2 < 0-screen_box_offset){
        point.y = mode_box_width/2-screen_box_offset;
    }
    if(point.y+mode_box_width/2 > superViewSize.height+screen_box_offset){
        point.y = superViewSize.height-mode_box_width/2+screen_box_offset;
    }
    self.frame = CGRectMake(point.x-mode_box_width/2, point.y-mode_box_width/2, mode_box_width, mode_box_width);
    return point;
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
   // NSLog(@"LOMOVED");
}
-(void)animateAdjustingAtPoint:(CGPoint) point inSize:(CGSize) superViewSize{
    if(point.x >= superViewSize.width-mode_box_width/2){
        point.x = superViewSize.width-mode_box_width/2;
    }else if(point.x <= mode_box_width/2){
        point.x = mode_box_width/2;
    }
    if(point.y >= superViewSize.height-mode_box_width/2){
        point.y = superViewSize.height-mode_box_width/2;
    }else if(point.y <= mode_box_width/2){
        point.y = mode_box_width/2;
    }
    if(point.y > superViewSize.height-1.5*mode_box_width){
        point.y = superViewSize.height-mode_box_width/2;
    }else if(point.y < 1.5*mode_box_width){
        point.y = mode_box_width/2;
    }else{
        if(point.x > superViewSize.width/2){
            point.x = superViewSize.width-mode_box_width/2;
        }else{
            point.x = mode_box_width/2;
        }
    }
    [UIView animateWithDuration:0.3f animations:^{
        self.frame = CGRectMake(point.x-mode_box_width/2, point.y-mode_box_width/2, mode_box_width, mode_box_width);
    } completion:^(BOOL b){
        
    }];
}
-(void)moveOutToScreen:(UIView*)belowView{
    if(!self.on){
        self.on = YES;
        self.finishOnAnimation = NO;
        if(self.LEFT_NORMAL_MODE){
            [UIView animateWithDuration:0.3f animations:^{self.frame = CGRectMake(-colorSettingView_OFFSET_X, colorSettingView_OFFSET_Y, colorSettingView_WIDTH , colorSettingView_HEIGHT);
                self.layer.shadowOffset = CGSizeMake(1.5f,0.0f);belowView.alpha = 0.3f;} completion:^(BOOL finished){
                    self.finishOnAnimation = YES;
                } ];
        }else{
            [UIView animateWithDuration:0.3f animations:^{self.frame = CGRectMake(335-colorSettingView_WIDTH, colorSettingView_OFFSET_Y, colorSettingView_WIDTH , colorSettingView_HEIGHT);
                self.layer.shadowOffset = CGSizeMake(-1.5f,0.0f);belowView.alpha = 0.3f;} completion:^(BOOL finished){
                    self.finishOnAnimation = YES;
                } ];
        }
    }
}
-(void)moveInside:(UIView*)belowView{
    self.on = NO;
    if(self.LEFT_NORMAL_MODE){
        [UIView animateWithDuration:0.3f animations:^{self.frame = CGRectMake(-colorSettingView_WIDTH, colorSettingView_OFFSET_Y, colorSettingView_WIDTH, colorSettingView_HEIGHT);
            self.layer.shadowOffset = CGSizeMake(-6.0f,0.0f);belowView.alpha = 0.0f; ;
        } completion:^(BOOL finished){/*finishColorSettingView=  YES;*/}];
    }else{
        [UIView animateWithDuration:0.3f animations:^{self.frame = CGRectMake(320+colorSettingView_WIDTH, colorSettingView_OFFSET_Y, colorSettingView_WIDTH, colorSettingView_HEIGHT);
            self.layer.shadowOffset = CGSizeMake(6.0f,0.0f);belowView.alpha = 0.0f; ;} completion:^(BOOL finished){/*finishColorSettingView=  YES;*/}];
    }
}


@end

