//
//  BSBDoorwaySegue.h
//  DoorwayTransition
//
//  Created by Benjamin Schuster-Boeckler on 08/02/2014.
//
//

#import <UIKit/UIKit.h>

CGFloat degreeToRadian(CGFloat degree);

@interface BSBDoorwaySegue : UIStoryboardSegue

+ (CGImageRef)clipImageFromLayer:(CALayer *)layer size:(CGSize)size offsetX:(CGFloat)offsetX;

@end
