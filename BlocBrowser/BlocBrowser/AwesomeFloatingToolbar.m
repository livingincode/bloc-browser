//
//  AwesomeFloatingToolbar.m
//  BlocBrowser
//
//  Created by Dean Laurea on 6/14/15.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import "AwesomeFloatingToolbar.h"

@interface AwesomeFloatingToolbar ()

@property (nonatomic, strong) NSArray *currentTitles;
@property (nonatomic, strong) NSArray *colors;
@property (nonatomic, strong) NSArray *buttons;
@property (nonatomic, weak) UIButton *currentButton;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGesture;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGesture;

@end

@implementation AwesomeFloatingToolbar

- (instancetype) initWithFourTitles:(NSArray *)titles {
        // First, call the superclass (UIView)'s initializer, to make sure we do all that setup first.
        self = [super init];
    
        if (self) {
        
                // Save the titles, and set the 4 colors
                self.currentTitles = titles;
                self.colors = @[[UIColor colorWithRed:199/255.0 green:158/255.0 blue:203/255.0 alpha:1],
                [UIColor colorWithRed:255/255.0 green:105/255.0 blue:97/255.0 alpha:1],
                [UIColor colorWithRed:222/255.0 green:165/255.0 blue:164/255.0 alpha:1],
                [UIColor colorWithRed:255/255.0 green:179/255.0 blue:71/255.0 alpha:1]];
        
                NSMutableArray *buttonsArray = [[NSMutableArray alloc] init];
        
                // Make the 4 buttons
                for (NSString *currentTitle in self.currentTitles) {
                        UIButton *button = [[UIButton alloc] init];
                        button.userInteractionEnabled = NO;
                        button.alpha = 0.25;
            
                        NSUInteger currentTitleIndex = [self.currentTitles indexOfObject:currentTitle]; // 0 through 3
                        NSString *titleForThisButton = [self.currentTitles objectAtIndex:currentTitleIndex];
                        UIColor *colorForThisButton = [self.colors objectAtIndex:currentTitleIndex];
            
                        button.textAlignment = NSTextAlignmentCenter;
                        button.font = [UIFont systemFontOfSize:10];
                        button.text = titleForThisLabel;
                        button.backgroundColor = colorForThisLabel;
                        button.textColor = [UIColor whiteColor];
            
                        [buttonsArray addObject:button];
                    }
        
                self.buttons = buttonsArray;
        
                for (UIButton *thisButton in self.buttons) {
                        [self addSubview:thisButton];
                    }
            
                // #1
                self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFired:)];
                // #2
                [self addGestureRecognizer:self.tapGesture];
            
                self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panFired:)];
                [self addGestureRecognizer:self.panGesture];
            
            self.pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchFired:)];
            [self addGestureRecognizer:self.pinchGesture];
            
            self.longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(pressFired:)];
            [self addGestureRecognizer:self.longPressGesture];
            
        }
    
        return self;
    }


- (void) layoutSubviews {
        // set the frames for the 4 buttons
    
        for (UIButton *thisbutton in self.buttons) {
                NSUInteger currentButtonIndex = [self.buttons indexOfObject:thisbutton];
        
                CGFloat buttonHeight = CGRectGetHeight(self.bounds) / 2;
                CGFloat buttonWidth = CGRectGetWidth(self.bounds) / 2;
                CGFloat buttonX = 0;
                CGFloat buttonY = 0;
        
                // adjust buttonX and buttonY for each button
                if (currentButtonIndex < 2) {
                        // 0 or 1, so on top
                        buttonY = 0;
                    } else {
                            // 2 or 3, so on bottom
                            buttonY = CGRectGetHeight(self.bounds) / 2;
                        }
        
                if (currentButtonIndex % 2 == 0) { // is currentButtonIndex evenly divisible by 2?
                        // 0 or 2, so on the left
                        buttonX = 0;
                    } else {
                            // 1 or 3, so on the right
                            buttonX = CGRectGetWidth(self.bounds) / 2;
                        }
        
                thisbutton.frame = CGRectMake(buttonX, buttonY, buttonWidth, buttonHeight);
            }
    }



#pragma mark - Button Enabling

- (void) setEnabled:(BOOL)enabled forButtonWithTitle:(NSString *)title {
        NSUInteger index = [self.currentTitles indexOfObject:title];
    
        if (index != NSNotFound) {
                UIButton *button = [self.buttons objectAtIndex:index];
                button.userInteractionEnabled = enabled;
                button.alpha = enabled ? 1.0 : 0.25;
            }
    }


- (void) tapFired:(UITapGestureRecognizer *)recognizer {
        if (recognizer.state == UIGestureRecognizerStateRecognized) { // #3
                CGPoint location = [recognizer locationInView:self]; // #4
                UIView *tappedView = [self hitTest:location withEvent:nil]; // #5
        
                if ([self.buttons containsObject:tappedView]) { // #6
                if ([self.delegate respondsToSelector:@selector(floatingToolbar:didSelectButtonWithTitle:)]) {
                [self.delegate floatingToolbar:self didSelectButtonWithTitle:((UILabel *)tappedView).text];
                   
                }
                
            }
        }
    }


- (void) panFired:(UIPanGestureRecognizer *)recognizer {
      if (recognizer.state == UIGestureRecognizerStateChanged) {
            CGPoint translation = [recognizer translationInView:self];
        
            NSLog(@"New translation: %@", NSStringFromCGPoint(translation));
        
            if ([self.delegate respondsToSelector:@selector(floatingToolbar:didTryToPanWithOffset:)]) {
                [self.delegate floatingToolbar:self didTryToPanWithOffset:translation];
                    }
        
             [recognizer setTranslation:CGPointZero inView:self];
 
      }

}

- (void) pinchFired:(UIPinchGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateChanged) {
                CGFloat scale = [recognizer scale];
        
                NSLog(@"New scale: %f", scale);
        
                if ([self.delegate respondsToSelector:@selector(floatingToolbar:didPinchToResize:)]) {
                        [self.delegate floatingToolbar:self didPinchToResize:scale];
           
                }
        
        }
    
}
    
    
- (void) floatingToolbar:(AwesomeFloatingToolbar *)toolbar didTryToPinch:(CGFloat)scale {
    CGPoint startingPoint = toolbar.frame.origin;
    
        CGFloat newWidth = CGRectGetWidth(toolbar.frame) * scale;
        CGFloat newHeight = CGRectGetHeight(toolbar.frame) * scale;
    
        NSLog(@"old width: %lf", CGRectGetWidth(toolbar.frame));
        NSLog(@"new width: %lf", newWidth);
    
    
        CGRect potentialNewFrame = CGRectMake(startingPoint.x, startingPoint.y, newWidth, newHeight);
    
        if (CGRectContainsRect(self.view.bounds, potentialNewFrame)) {
                toolbar.frame = potentialNewFrame;
        
        }

}

- (void) pressFired:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateRecognized) {
        CGPoint location = [recognizer locationInView:self];
        UIView *pressedView = [self hitTest:location withEvent:nil];
        
        if ([self.buttons containsObject:pressedView]) {
            if ([self.delegate respondsToSelector:@selector(floatingToolbar:didTryToPressButtonWithTitle:)]) {
                [self.delegate floatingToolbar:self didTryToPressButtonWithTitle:((UIButton *)pressedView).text];
                
            }
        }
    }
}

@end
