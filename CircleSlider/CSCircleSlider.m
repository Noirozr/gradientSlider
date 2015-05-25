//
//  CSCircleSlider.m
//  CircleSlider
//
//  Created by Yongjia Liu on 14-1-28.
//  Copyright (c) 2014年 Yongjia Liu. All rights reserved.
//

#import "CSCircleSlider.h"
#import "Commons.h"

#define ToRad(deg)  ((M_PI * (deg))/180.0)
#define ToDeg(rad)  ((180.0*(rad))/M_PI)
#define SQR(x)  ((x)*(x))

#define SAFEAREA_PADDING 60

@interface CSCircleSlider()
{
    UITextField *textField;
    int radius;
}
@end
@implementation CSCircleSlider

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque=NO;
        
        radius=self.frame.size.width/2-SAFEAREA_PADDING;
        self.angle=360;
        UIFont *font=[UIFont fontWithName:FONTFAMILY size:FONTSIZE];
        NSString *str=@"000";
        CGSize fontSize=[str sizeWithFont:font];
        textField=[[UITextField alloc]initWithFrame:CGRectMake((frame.size.width-fontSize.width)/2,(frame.size.height-fontSize.height)/2, fontSize.width, fontSize.height)];
        textField.backgroundColor=[UIColor clearColor];
        textField.textColor=[UIColor colorWithWhite:1 alpha:0.8];
        textField.textAlignment=NSTextAlignmentCenter;
        textField.font=font;
        textField.text=[NSString stringWithFormat:@"%d",self.angle];
        textField.enabled=NO;
        
        [self addSubview:textField];
        // Initialization code
    }
    return self;
}
-(BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [super beginTrackingWithTouch:touch withEvent:event];
    return YES;
    
}
-(BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [super continueTrackingWithTouch:touch withEvent:event];
    CGPoint lastPoint=[touch locationInView:self];
    [self movehandle:lastPoint];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    return YES;
}
-(void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [super endTrackingWithTouch:touch withEvent:event];
}
-(void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    CGContextRef ctx=UIGraphicsGetCurrentContext();
    /**Draw the Background**/
    CGContextAddArc(ctx, self.frame.size.width/2, self.frame.size.height/2, radius, 0, M_PI*2, 0);
    
    //Set the stroke color to black
    [[UIColor blackColor]setStroke];
    
    //Define line width and cap
    CGContextSetLineWidth(ctx, BACKGROUND_WIDTH);
    CGContextSetLineCap(ctx, kCGLineCapButt);
    
    //draw it!
    CGContextDrawPath(ctx, kCGPathStroke);
    
    /**Create THE MASK Image**/
    UIGraphicsBeginImageContext(CGSizeMake(SLIDER_SIZE, SLIDER_SIZE));
    CGContextRef imageCtx=UIGraphicsGetCurrentContext();
    
    CGContextAddArc(imageCtx, self.frame.size.width/2, self.frame.size.height/2, radius, 0, ToRad(self.angle), 0);
    [[UIColor redColor]set];
    
    //Use shadow to create the Blur effect
    CGContextSetShadowWithColor(imageCtx, CGSizeMake(0,0), self.angle/20, [UIColor blackColor].CGColor);
    
    
    //define the path
    CGContextSetLineWidth(imageCtx, LINE_WIDTH);
    CGContextDrawPath(imageCtx, kCGPathStroke);
    
    
    //save the context content into the image mask
    CGImageRef mask=CGBitmapContextCreateImage(UIGraphicsGetCurrentContext());
    UIGraphicsEndImageContext();
    
    
    /**Clip Context to the mask**/
    CGContextSaveGState(ctx);
    
    CGContextClipToMask(ctx, self.bounds, mask);
    CGImageRelease(mask);
    
    
    /**THE GRADIENT**/
    
    //list of omponents
    CGFloat components[8]={
      0.0,0.0,1.0,1.0,
      1.0,0.0,1.0,1.0
    };
    CGColorSpaceRef baseSpace=CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient=CGGradientCreateWithColorComponents(baseSpace, components, NULL, 2);
    CGColorSpaceRelease(baseSpace);
    baseSpace=NULL;
    
    
    //gradient the direction
    CGPoint startPoint=CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
    CGPoint endPoint=CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
    
    //draw the gradient
    CGContextDrawLinearGradient(ctx, gradient, startPoint, endPoint, 0);
    CGGradientRelease(gradient);
    gradient=NULL;
    CGContextRestoreGState(ctx);
    
    /**Add some ligt reflection effects on the background circle**/
    
    CGContextSetLineWidth(ctx,1);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    
    
    //draw the outside light
    CGContextBeginPath(ctx);
    CGContextAddArc(ctx, self.frame.size.width/2, self.frame.size.height/2, radius+BACKGROUND_WIDTH/2, 0, ToRad(-self.angle), 1);
    [[UIColor colorWithWhite:1.0 alpha:0.05]set];
    CGContextDrawPath(ctx, kCGPathStroke);
    
    
    //draw the inner light
    CGContextBeginPath(ctx);
    CGContextAddArc(ctx, self.frame.size.width/2, self.frame.size.height/2, radius-BACKGROUND_WIDTH/2, 0, ToRad(-self.angle), 1);
    [[UIColor colorWithWhite:1.0 alpha:0.05]set];
    CGContextDrawPath(ctx, kCGPathStroke);
    
    /** Draw the handle **/
    [self drawTheHandle:ctx];
}
-(void)drawTheHandle:(CGContextRef)ctx
{
    CGContextSaveGState(ctx);
    
    //Re:I Love Shadows
    CGContextSetShadowWithColor(ctx, CGSizeMake(0, 0), 3, [UIColor blackColor].CGColor);
    
    //Get the handle position
    CGPoint handleCenter=[self pointFromAngle:self.angle];
    
    //Draw it
    [[UIColor colorWithWhite:1.0 alpha:0.7]set];
    CGContextFillEllipseInRect(ctx, CGRectMake(handleCenter.x, handleCenter.y, LINE_WIDTH, LINE_WIDTH));
    
    CGContextRestoreGState(ctx);
}
-(void)movehandle:(CGPoint)lastPoint
{
    CGPoint centerPoint=CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    float currentAngle=AngleFromNorth(centerPoint,lastPoint,NO);
    int angleInt=floor(currentAngle);
    
    self.angle=360-angleInt;
    textField.text=[NSString stringWithFormat:@"%d",self.angle];
    
    //Reddraw
    [self setNeedsDisplay];
    
}
/** Given the angle,get the point position oncircumference**/
-(CGPoint)pointFromAngle:(int)angleInt
{
    //Circle center
    CGPoint centerPoint=CGPointMake(self.frame.size.width/2-LINE_WIDTH/2, self.frame.size.height/2-LINE_WIDTH/2);
    
    //The point position on the circumference
    CGPoint result;
    result.y=roundf(centerPoint.y+radius*sin(ToRad(-angleInt)));
    result.x=round(centerPoint.x+radius*cos(ToRad(-angleInt)));
    
    return result;
}

//Sourcecode from Apple example clockControl
//Calculate the direction in degrees from a center point to an arbitrary position
static inline float AngleFromNorth(CGPoint p1,CGPoint p2,BOOL flipped)
{
    CGPoint v=CGPointMake(p2.x-p1.x, p2.y-p1.y);
    float vmag=sqrt(SQR(v.x)+SQR(v.y)),result=0;
    v.x/=vmag;
    v.y/=vmag;
    double radians=atan2(v.y,v.x);
    result=ToDeg(radians);
    return (result >=0? result:result+360.0);
}


@end
