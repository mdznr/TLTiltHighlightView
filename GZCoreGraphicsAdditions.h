#import <UIKit/UIKit.h>

@interface UIImage (DrawingBlock)

// Draws an image within a block, with a given size,
// along with a supplied CGContextRef. A CGRect with
// the image-bounded rect is supplied for convenience.
+ (UIImage *)imageWithSize:(CGSize)size drawing:(void(^)(CGContextRef, CGRect))drawingBlock;

@end

// Applies light linear noise in a rectangle at a certain
// opacity. For a light noise, 0.1 - 0.2 is a good value.
extern void CGContextApplyNoise(CGContextRef context, CGRect rect, CGFloat opacity);

// Draws a conical gradient, a feature that Quartz does not natively support,
// in a given rectangle, defined by a dictionary of NSNumber locations for the
// gradient stops as keys and UIColor colors as values.
extern void CGContextDrawConicalGradientWithDictionary(CGContextRef context, CGRect rect, NSDictionary *colorsForLocations);

// Draws a conical gradient, a feature that Quartz does not
// natively support, in a given rectangle, defined by an
// array of UIColors, and an array of NSNumber locations for
// the gradient stops. The array counts must match up.
extern void CGContextDrawConicalGradient(CGContextRef context, CGRect rect, NSArray *colors, NSArray *locations);