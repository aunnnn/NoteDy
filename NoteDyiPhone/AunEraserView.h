//
//  AunEraserView.h
//  DrawNotes
//
//  Created by Wirawit Rueopas on 4/5/2557 BE.
//  Copyright (c) 2557 Wirawit Rueopas. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AunEraserView : UIView{
}
@property CGFloat eraserRadius;
@property CGFloat brushRadius;

@property CGFloat brushR ;
@property CGFloat brushG ;
@property CGFloat brushB ;
@property CGFloat brushAlpha ;

@property CGFloat eraserR ;
@property CGFloat eraserG ;
@property CGFloat eraserB ;
@property CGFloat eraserAlpha ;

-(id)initEraserView;
-(void)setBrushR:(CGFloat)r G:(CGFloat)g B:(CGFloat)b A:(CGFloat)a ;
-(void)setEraserR:(CGFloat)r G:(CGFloat)g B:(CGFloat)b A:(CGFloat)a ;
@end