//
//  BSBDoorwaySegue.m
//  DoorwayTransition
//
//  Created by Benjamin Schuster-Boeckler on 08/02/2014.
//
//

#import "BSBDoorwaySegue.h"
#import <QuartzCore/QuartzCore.h>


CGFloat degreeToRadian(CGFloat degree)
{
    return degree * M_PI / 180.0f;
}

@interface BSBDoorwaySegue ()
@property (nonatomic, strong) CALayer *doorLayerLeft;
@property (nonatomic, strong) CALayer *doorLayerRight;
@property (nonatomic, strong) CALayer *nextViewLayer;
@property (nonatomic, strong) UIView *view;
@property (nonatomic, strong) UIView *nextView;

- (CAAnimation *)openDoorAnimationWithRotationDegree:(CGFloat)degree;
- (CAAnimation *)zoomInAnimation;
@end

@implementation BSBDoorwaySegue

- (id)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    if (self = [super initWithIdentifier:identifier source:source destination:destination])
    {
        self.view = source.view;
        self.nextView=destination.view;
    }
    
    return self;
}

- (void)perform
{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGRect leftDoorRect = CGRectMake(0.0f, 0.0f, screenSize.width / 2.0f, screenSize.height);
    CGRect rightDoorRect = CGRectMake(screenSize.width / 2.0f, 0.0f, screenSize.width / 2.0f, screenSize.height);
    
    self.doorLayerLeft = [CALayer layer];
    self.doorLayerLeft.anchorPoint = CGPointMake(0.0f, 0.5f);
    self.doorLayerLeft.frame  = leftDoorRect;
    CATransform3D leftTransform = self.doorLayerLeft.transform;
    leftTransform.m34 = 1.0f / -420.0f;
    self.doorLayerLeft.transform = leftTransform;
    self.doorLayerLeft.shadowOffset = CGSizeMake(5.0f, 5.0f);
    
    self.doorLayerRight = [CALayer layer];
    self.doorLayerRight.anchorPoint = CGPointMake(1.0f, 0.5f);
    self.doorLayerRight.frame = rightDoorRect;
    CATransform3D rightTransform = self.doorLayerRight.transform;
    rightTransform.m34 = 1.0f / -420.0f;
    self.doorLayerRight.transform = rightTransform;
    self.doorLayerRight.shadowOffset = CGSizeMake(5.0f, 5.0f);
    
    self.nextViewLayer = [CALayer layer];
    self.nextViewLayer.anchorPoint = CGPointMake(0.5f, 0.5f);
    self.nextViewLayer.frame = CGRectMake(0.0f, 0.0f, screenSize.width, screenSize.height);
    CATransform3D nextViewTransform = self.nextViewLayer.transform;
    nextViewTransform.m34 = 1.0f / -420.0f;
    self.nextViewLayer.transform = nextViewTransform;
    
    // Left door image
    self.doorLayerLeft.contents = (id)[[self class] clipImageFromLayer:self.view.layer size:leftDoorRect.size offsetX:0.0f];
    
    // Right door image
    self.doorLayerRight.contents = (id)[[self class] clipImageFromLayer:self.view.layer size:rightDoorRect.size offsetX:-leftDoorRect.size.width];
    
    // Next view image
    self.nextViewLayer.contents = (id)[[self class] clipImageFromLayer:self.nextView.layer size:screenSize offsetX:0.0f];
    
    [self.view.superview.layer addSublayer:self.doorLayerLeft];
    [self.view.superview.layer addSublayer:self.doorLayerRight];
    [self.view.superview.layer addSublayer:self.nextViewLayer];
    
    CAAnimation *leftDoorAnimation = [self openDoorAnimationWithRotationDegree:90.0f];
    leftDoorAnimation.delegate = self;
    [self.doorLayerLeft addAnimation:leftDoorAnimation forKey:@"doorAnimationStarted"];
    
    CAAnimation *rightDoorAnimation = [self openDoorAnimationWithRotationDegree:-90.0f];
    rightDoorAnimation.delegate = self;
    [self.doorLayerRight addAnimation:rightDoorAnimation forKey:@"doorAnimationStarted"];
    
    CAAnimation *nextViewAnimation = [self zoomInAnimation];
    nextViewAnimation.delegate = self;
    [self.nextViewLayer addAnimation:nextViewAnimation forKey:@"NextViewAnimationStarted"];
    [self.view removeFromSuperview];
}

//------------------------------------------------------------------------------
#pragma - Animation delegate
#
//- (void)animationDidStart:(CAAnimation *)anim
//{
//    [self.originalView removeFromSuperview];
//}
//
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if(flag) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [self.doorLayerLeft removeFromSuperlayer];
            [self.doorLayerRight removeFromSuperlayer];
            [self.nextView removeFromSuperview];
            [(UIViewController *)self.sourceViewController presentViewController:self.destinationViewController
                                                                        animated:NO
                                                                      completion:^{
                                                                          
                                                                      }];
        });
    }
}

//------------------------------------------------------------------------------
#pragma - Image utility
#
+ (CGImageRef)clipImageFromLayer:(CALayer *)layer size:(CGSize)size offsetX:(CGFloat)offsetX
{
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, offsetX, 0.0f);
    [layer renderInContext:context];
    UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snapshot.CGImage;
}

//------------------------------------------------------------------------------
#pragma - Animation set
#
- (CAAnimation *)zoomInAnimation
{
    CAAnimationGroup *animGroup = [CAAnimationGroup animation];
    
    CABasicAnimation *zoomInAnim = [CABasicAnimation animationWithKeyPath:@"transform.translation.z"];
    zoomInAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    zoomInAnim.fromValue = [NSNumber numberWithFloat:-500.0f];
    zoomInAnim.toValue = [NSNumber numberWithFloat:0.0f];
    
    CABasicAnimation *fadeInAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeInAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    fadeInAnim.fromValue = [NSNumber numberWithFloat:0.0f];
    fadeInAnim.toValue = [NSNumber numberWithFloat:1.0f];
    
    animGroup.animations = [NSArray arrayWithObjects:zoomInAnim, fadeInAnim, nil];
    animGroup.duration = 0.5f;
    
    return animGroup;
}

- (CAAnimation *)openDoorAnimationWithRotationDegree:(CGFloat)degree
{
    CAAnimationGroup *animGroup = [CAAnimationGroup animation];
    
    CABasicAnimation *openAnim = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
    openAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    openAnim.fromValue = [NSNumber numberWithFloat:degreeToRadian(0.0f)];
    openAnim.toValue = [NSNumber numberWithFloat:degreeToRadian(degree)];
    
    CABasicAnimation *zoomInAnim = [CABasicAnimation animationWithKeyPath:@"transform.translation.z"];
    zoomInAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    zoomInAnim.fromValue = [NSNumber numberWithFloat:0.0f];
    zoomInAnim.toValue = [NSNumber numberWithFloat:300.0f];
    
    animGroup.animations = [NSArray arrayWithObjects:openAnim, zoomInAnim, nil];
    animGroup.duration = 0.5f;
    
    return animGroup;
}

@end
