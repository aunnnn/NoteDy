//
//  AunEraserView.m
//  DrawNotes
//
//  Created by Wirawit Rueopas on 4/5/2557 BE.
//  Copyright (c) 2557 Wirawit Rueopas. All rights reserved.
//

#import "AunEraserView.h"

@implementation AunEraserView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.layer.cornerRadius = 20;
        self.hidden = YES;
    }
    return self;
}
-(id) initEraserView{
    self.eraserRadius = 10 ;
    self.brushRadius = 2 ;
    
    self.brushR = 0.0f ;
    self.brushG = 0.0f ;
    self.brushB = 0.0f ;
    self.brushAlpha = 1.0f ;
    
    self.eraserR = 1.0f;
    self.eraserG = 1.0f;
    self.eraserB = 1.0f;
    self.eraserAlpha = 1.0f;
    return [self initWithFrame:CGRectMake(100, 100, 40, 40)];
}
-(void)setBrushR:(CGFloat)r G:(CGFloat)g B:(CGFloat)b A:(CGFloat)a {
    self.brushR = r ;
    self.brushG = g ;
    self.brushB = b ;
    self.brushAlpha = a ;
}
-(void)setEraserR:(CGFloat)r G:(CGFloat)g B:(CGFloat)b A:(CGFloat)a {
    self.eraserR = r ;
    self.eraserG = g ;
    self.eraserB = b ;
    self.eraserAlpha = a ;
}
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    /* Draw a circle */
    // Get the contextRef
    CGFloat lineWidth = 5;
    CGRect borderRect = CGRectInset(rect, lineWidth * 0.5, lineWidth * 0.5);
    
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    // Set the border width
    CGContextSetLineWidth(contextRef, lineWidth);
    
    // Set the circle fill color to WHITE
    CGContextSetRGBFillColor(contextRef, 1, 1, 1, 0.7f);
    
    // Set the cicle border color to BLACK
    CGContextSetRGBStrokeColor(contextRef, 0.0, 0.0, 0.0, 1.0);
    
    // Fill the circle with the fill color
    CGContextFillEllipseInRect(contextRef, borderRect);
    
    // Draw the circle border
    CGContextStrokeEllipseInRect(contextRef, borderRect);
}


@end
