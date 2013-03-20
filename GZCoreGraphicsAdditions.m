#import "GZCoreGraphicsAdditions.h"

typedef unsigned char byte;
typedef unsigned int uint;

#define F2CC(x) ((byte)(255 * x))
#define RGBAF(r,g,b,a) (F2CC(r) << 24 | F2CC(g) << 16 | F2CC(b) << 8 | F2CC(a))
#define RGBA(r,g,b,a) ((byte)r << 24 | (byte)g << 16 | (byte)b << 8 | (byte)a)

#define RGBA_R(c) ((uint)c >> 24 & 255)
#define RGBA_G(c) ((uint)c >> 16 & 255)
#define RGBA_B(c) ((uint)c >> 8 & 255)
#define RGBA_A(c) ((uint)c >> 0 & 255)

static inline byte blerp(byte a, byte b, float w)
{
	return a + w * (b - a);
}

static inline int lerp(int a, int b, float w)
{
	return RGBA(blerp(RGBA_R(a), RGBA_R(b), w),
				blerp(RGBA_G(a), RGBA_G(b), w),
				blerp(RGBA_B(a), RGBA_B(b), w),
				blerp(RGBA_A(a), RGBA_A(b), w));
}

@implementation UIImage (DrawingBlock)

+ (UIImage *)imageWithSize:(CGSize)size drawing:(void(^)(CGContextRef, CGRect))drawingBlock
{
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
    drawingBlock(UIGraphicsGetCurrentContext(), (CGRect) {CGPointZero, size});
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end

void CGContextDrawConicalGradientWithDictionary(CGContextRef context, CGRect rect, NSDictionary *colorsForLocations)
{
	// Assuming dictionary was previously populated with NSNumber values.
	// Sort the keys
	NSArray *orderedKeys = [[colorsForLocations allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
		if ([obj1 floatValue] > [obj2 floatValue]) {
			return (NSComparisonResult) NSOrderedDescending;
		}
		if ([obj1 floatValue] < [obj2 floatValue]) {
			return (NSComparisonResult) NSOrderedAscending;
		}
		return (NSComparisonResult) NSOrderedSame;
	}];
	
	// Then populate values based on ordered keys
	NSMutableArray *values = [[NSMutableArray alloc] initWithCapacity:orderedKeys.count];
	for ( NSUInteger i=0; i<orderedKeys.count; ++i ) {
		[values addObject:[colorsForLocations objectForKey:orderedKeys[i]]];
	}
	
	// Hand this off to draw conical gradient
	CGContextDrawConicalGradient(context, rect, [values copy], orderedKeys);
}

void CGContextDrawConicalGradient(CGContextRef context, CGRect rect, NSArray *colorArray, NSArray *locationArray)
{
	// The arrays must match in size
	if ( [colorArray count] != [locationArray count] ) {
		NSLog(@"The amount of colors much must the number of locations");
		return;
	}
	
	// The arrays must also be non-empty
	if ( [colorArray count] == 0 ) {
		NSLog(@"The amount of colors and locations must not be 0.");
		return;
	}
	
	// Create mutable arrays from given arrays
	NSMutableArray *locations = [[NSMutableArray alloc] initWithArray:locationArray];
	NSMutableArray *colors = [[NSMutableArray alloc] initWithArray:colorArray];
	
	BOOL hasEnd = NO;
	BOOL hasBegin = NO;
	
	NSUInteger firstLocationIndex = 0;
	NSUInteger lastLocationIndex = locations.count-1;
	
	// See if it has an end and/or begin point
	if ( [locations[locations.count-1] isEqual:@1.00f] ) {
		hasEnd = YES;
	}
	if ( [locations[0] isEqual:@0.00f] ) {
		hasBegin = YES;
	}
	
	// If it has an end or beginning, set the other to be the same
	if ( !hasEnd && hasBegin ) {
		[locations addObject:@1.00f];
		[colors addObject:[colors objectAtIndex:firstLocationIndex]];
	} else if ( hasEnd && !hasBegin ) {
		[locations insertObject:@0.00f atIndex:0];
		[colors insertObject:[colors objectAtIndex:lastLocationIndex] atIndex:0];
	} else if ( !hasEnd && !hasBegin ) {
		// Need to calculate the end and begin points
		
		NSNumber *firstLocation = locations[firstLocationIndex];
		NSNumber *lastLocation = locations[lastLocationIndex];
		
		float end = [@1.0f floatValue] - [lastLocation floatValue];
		float begin = [firstLocation floatValue];
		
		// Find weighting of each point to the begin/end points
		float total = end + begin;
		float beginWeight = 1 - (begin / total);
		float endWeight = 1 - (end / total);
		
		// Get the colors at the points
		float r, g, b, a, w;
		if ( [colors[firstLocationIndex] getWhite:&w alpha:&a] ) {
			r = w;
			g = w;
			b = w;
		} else {
			[colors[firstLocationIndex] getRed:&r green:&g blue:&b alpha:&a];
		}
		
		float R, G, B, A, W;
		if ( [colors[lastLocationIndex] getWhite:&W alpha:&A] ) {
			R = W;
			G = W;
			B = W;
		} else {
			[colors[lastLocationIndex] getRed:&R green:&G blue:&B alpha:&A];
		}
		
		// Create the color that's the weighted average of the two points
		UIColor *stopColor = [UIColor colorWithRed:(r*beginWeight)+(R*endWeight)
											 green:(g*beginWeight)+(G*endWeight)
											  blue:(b*beginWeight)+(B*endWeight)
											 alpha:(a*beginWeight)+(A*endWeight)];
		
		// Add the color to the beginning and end of the arrays
		[locations insertObject:@0.00f atIndex:0];
		[colors insertObject:stopColor atIndex:0];
		
		[locations addObject:@1.00f];
		[colors addObject:stopColor];
	}
	
	int w = CGRectGetWidth(rect);
	int h = CGRectGetHeight(rect);
    
	int bitsPerComponent = 8;
	int bpp = 4 * bitsPerComponent / 8;
	int byteCount = w * h * bpp;
    
	int colorCount = colors.count;
	int locationCount = 0;
	int* _colors = NULL;
	float* _locations = NULL;
    
	if ( colorCount > 0 ) {
		_colors = calloc(colorCount, bpp);
		int *p = _colors;
        
		for ( id c in colors ) {
			float r, g, b, a;
            
			if ( ![c getRed:&r green:&g blue:&b alpha:&a] ) {
				if ( ![c getWhite:&r alpha:&a] ) {
					continue;
				}
				g = b = r;
			}
			*p++ = RGBAF(r, g, b, a);
		}
	}
    
	if ( locations.count > 0 && locations.count == colorCount ) {
		locationCount = locations.count;
		_locations = calloc(locationCount, sizeof(_locations[0]));
        
		float *p = _locations;
		for ( NSNumber *n in locations ) {
			*p++ = [n floatValue];
		}
	}
    
	byte *data = malloc(byteCount);
    if ( colorCount > 0 && locationCount > 0 && locationCount == colorCount ) {
        int *p = (int *) data;
        float centerX = (float) w / 2;
        float centerY = (float) h / 2;
        
        for ( int y = 0; y < h; y++ ) {
            for (int x = 0; x < w; x++) {
                float dirX = x - centerX;
                float dirY = y - centerY;
                float angle = atan2f(dirY, dirX);
                
                if ( dirY < 0 ) {
                    angle += 2 * M_PI;
				}
                angle /= 2 * M_PI;
                
                int index = 0, nextIndex = 0;
                float t = 0;
                
                if ( locationCount > 0 ) {
                    for ( index = locationCount - 1; index >= 0; index-- ) {
                        if ( angle >= _locations[index] ) {
                            break;
						}
                    }
                    
                    if ( index >= locationCount ) {
                        index = locationCount - 1;
					}
                    nextIndex = index + 1;
                    if ( nextIndex >= locationCount ) {
                        nextIndex = locationCount - 1;
					}
                    
                    float ld = _locations[nextIndex] - _locations[index];
                    t = ld <= 0 ? 0 : (angle - _locations[index]) / ld;
                } else {
                    t = angle * (colorCount - 1);
                    index = t;
                    t -= index;
                    
                    nextIndex = index + 1;
                    if ( nextIndex >= colorCount ) {
                        nextIndex = colorCount - 1;
					}
                }
                
                int lc = _colors[index];
                int rc = _colors[nextIndex];
                int color = lerp(lc, rc, t);
                
                *p++ = color;
            }
		}
    }
    
	if ( _colors ) {
		free(_colors);
	}
    if ( _locations ) {
		free(_locations);
	}
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Little;
    
    CGContextRef ctx = CGBitmapContextCreate(data, w, h, bitsPerComponent, w * bpp, colorSpace, bitmapInfo);
    CGImageRef img = CGBitmapContextCreateImage(ctx);
    
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(ctx);
    free(data);
    
    CGContextDrawImage(context, rect, img);
    CGImageRelease(img);
}

void CGContextApplyNoise(CGContextRef context, CGRect rect, CGFloat opacity)
{
    NSUInteger width = 128;
    NSUInteger height = 128;
    
    NSUInteger size = width * height;
    char *rgba = (char *) malloc(size);
    srand(124);
    
    for ( NSUInteger i=0; i < size; ++i ) {
        rgba[i] = rand() % 256;
	}
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapContext = CGBitmapContextCreate(rgba, width, height, 8, width, colorSpace, kCGImageAlphaNone);
    CGImageRef image = CGBitmapContextCreateImage(bitmapContext);
    
    CFRelease(bitmapContext);
    CGColorSpaceRelease(colorSpace);
    free(rgba);
    
    
    CGContextSaveGState(context);
    CGContextClipToRect(context, rect);
    CGContextSetAlpha(context, opacity);
    CGContextSetBlendMode(context, kCGBlendModeScreen);
    
    CGRect imageRect = (CGRect) {CGPointZero, CGImageGetWidth(image), CGImageGetHeight(image)};
    CGContextDrawTiledImage(context, imageRect, image);
    
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGContextRestoreGState(context);
    CGImageRelease(image);
}
