MTZTiltShadowView
=================

`MTZTiltShadowView` is a `UIView` subclass with a shadow which adjusts its appearances based on the positional attitude of the device. The movement of the shadow when re-orientating the device should be *subtle* (depending on your configuration, of course) - it's meant to simulate a single source of light hitting an object and creating a shadow.

![Left Shadow](https://github.com/mdznr/TLTiltHighlightView/raw/master/images/shadow_left.png)
![Right shadow](https://github.com/mdznr/TLTiltHighlightView/raw/master/images/shadow_right.png)

How to Use
-----------------------

Drag `MTZTiltShadowView.h` and `MTZTiltShadowView.m` into your project.Make sure to [add](http://stackoverflow.com/questions/3352664/how-to-add-existing-frameworks-in-xcode-4) QuartzCore and CoreMotion to the list of libraries you link against.

Create an instance of `MTZTiltShadowView` and it to a view hierarchy.

    MTZTiltShadowView *shadowView = [[MTZTiltShadowView alloc] initWithFrame:CGRectMake(40, 40, 40, 40)];
    [self.view addSubview:shadowView];
    
You can also change the background colour and the shadow colours.

    shadowView.backgroundColor = [UIColor redColor];
    shadowView.shadowColor = [UIColor blueColor];

Alternatively to instantiating the class programmatically, you can also use Interface Builder by selecting the Identity Inspector and changing the class of a view.

![Interface Builder](https://github.com/mdznr/TLTiltHighlightView/raw/master/images/interface_builder2.png)

The `MTZTiltShadowView` class supports all four interface orientations of iPhones and iPads.

TLTiltHighlightView
===================

`TLTiltHighlightView` is a `UIView` subclass with a horizontal gradient which adjusts its appearance based on the positional attitude of the device. The movement of the gradient when re-orientating the device is *subtle* – it's meant to augment keylines. This mimics the iOS 6 Music app (notice the gradient keylines at the very top and bottom of the images).

![Left highlight](https://github.com/mdznr/TLTiltHighlightView/raw/master/images/highlight_left.png)
![Right highlight](https://github.com/mdznr/TLTiltHighlightView/raw/master/images/highlight_right.png)

How to Use
-----------------------

Drag `TLTiltHighlightView.h` and `TLTiltHighlightView.m` into your project. Make sure to [add](http://stackoverflow.com/questions/3352664/how-to-add-existing-frameworks-in-xcode-4) QuartzCore and CoreMotion to the list of libraries you link against.

Create an instance of `TLTiltHighlightView` and add it to a view hierarchy. Optimal size is any width and 2pt tall (the keyline will always sit at the bottom of the `TLTiltHighlightView`).

    TLTiltHighlightView *highlightView = [[TLTiltHighlightView alloc] initWithFrame:CGRectMake(0, 44, CGRectGetWidth(self.view.bounds), 2)];
    [self.view addSubview:highlightView];
    
![Our implementation](https://github.com/mdznr/TLTiltHighlightView/raw/master/images/implementation.png)
    
You can also change the background colour and the highlight colours. 
    
    highlightView.highlightColor = [UIColor redColor];
    highlightView.backgroundColor = [UIColor clearColor];
    
Alternatively to instantiating the class programmatically, you can also use Interface Builder by selecting the Identity Inspector and changing the class of a view.

![Interface Builder](https://github.com/mdznr/TLTiltHighlightView/raw/master/images/interface_builder.png)

The `TLTiltHighlightView` class supports all four interface orientations of iPhones and iPads. 

Requirements
-----------------------

You must link with QuartzCore and CoreMotion. This project requires ARC and has been tested on iOS 6. It should work on iOS 5, but it has not been rigorously tested. If you use it successfully on iOS 5, please let us know!
