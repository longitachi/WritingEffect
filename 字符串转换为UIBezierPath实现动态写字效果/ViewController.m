//
//  ViewController.m
//  字符串转换为UIBezierPath实现动态写字效果
//
//  Created by long on 16/2/24.
//  Copyright © 2016年 long. All rights reserved.
//

#import "ViewController.h"
#import <CoreText/CoreText.h>

@interface ViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *btnStart;
@property (weak, nonatomic) IBOutlet UIView *displayView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

#pragma mark - UIButton Action
- (IBAction)btnStartDraw_Click:(id)sender
{
    [self.displayView.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    if (self.textField.text.length > 0) {
        UIBezierPath *bezierPath = [self transformToBezierPath:self.textField.text];
        
        CAShapeLayer *layer = [CAShapeLayer layer];
        layer.bounds = CGPathGetBoundingBox(bezierPath.CGPath);
        layer.position = CGPointMake(self.view.bounds.size.width/2, 50);
        layer.geometryFlipped = YES;
        layer.path = bezierPath.CGPath;
        layer.fillColor = [UIColor clearColor].CGColor;
        layer.lineWidth = 1;
        layer.strokeColor = [UIColor blackColor].CGColor;
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        animation.fromValue = @(0);
        animation.toValue = @(1);
        animation.duration = layer.bounds.size.width/20;
        [layer addAnimation:animation forKey:nil];
        [self.displayView.layer addSublayer:layer];
        
        
        UIImage *penImage = [UIImage imageNamed:@"pencil.png"];
        CALayer *penLayer = [CALayer layer];
        penLayer.contents = (id)penImage.CGImage;
        penLayer.anchorPoint = CGPointZero;
        penLayer.frame = CGRectMake(0.0f, 0.0f, penImage.size.width, penImage.size.height);
        [layer addSublayer:penLayer];
        
        CAKeyframeAnimation *penAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
        penAnimation.duration = animation.duration;
        penAnimation.path = layer.path;
        penAnimation.calculationMode = kCAAnimationPaced;
        penAnimation.removedOnCompletion = NO;
        penAnimation.fillMode = kCAFillModeForwards;
        [penLayer addAnimation:penAnimation forKey:@"position"];
        
        [penLayer performSelector:@selector(removeFromSuperlayer) withObject:nil afterDelay:penAnimation.duration+.2];
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return [textField resignFirstResponder];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.textField resignFirstResponder];
}

- (UIBezierPath *)transformToBezierPath:(NSString *)string
{
    CGMutablePathRef paths = CGPathCreateMutable();
    CFStringRef fontNameRef = CFSTR("SnellRoundhand");
    CTFontRef fontRef = CTFontCreateWithName(fontNameRef, 18, nil);
    
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:string attributes:@{(__bridge NSString *)kCTFontAttributeName: (__bridge UIFont *)fontRef}];
    CTLineRef lineRef = CTLineCreateWithAttributedString((CFAttributedStringRef)attrString);
    CFArrayRef runArrRef = CTLineGetGlyphRuns(lineRef);
    
    for (int runIndex = 0; runIndex < CFArrayGetCount(runArrRef); runIndex++) {
        const void *run = CFArrayGetValueAtIndex(runArrRef, runIndex);
        CTRunRef runb = (CTRunRef)run;
        
        const void *CTFontName = kCTFontAttributeName;
        
        const void *runFontC = CFDictionaryGetValue(CTRunGetAttributes(runb), CTFontName);
        CTFontRef runFontS = (CTFontRef)runFontC;
        
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        
        int temp = 0;
        CGFloat offset = .0;
        
        for (int i = 0; i < CTRunGetGlyphCount(runb); i++) {
            CFRange range = CFRangeMake(i, 1);
            CGGlyph glyph = 0;
            CTRunGetGlyphs(runb, range, &glyph);
            CGPoint position = CGPointZero;
            CTRunGetPositions(runb, range, &position);
            
            CGFloat temp3 = position.x;
            int temp2 = (int)temp3/width;
            CGFloat temp1 = 0;
            
            if (temp2 > temp1) {
                temp = temp2;
                offset = position.x - (CGFloat)temp;
            }
            
            CGPathRef path = CTFontCreatePathForGlyph(runFontS, glyph, nil);
            CGFloat x = position.x - (CGFloat)temp*width - offset;
            CGFloat y = position.y - (CGFloat)temp * 80;
            CGAffineTransform transform = CGAffineTransformMakeTranslation(x, y);
            CGPathAddPath(paths, &transform, path);
            
            CGPathRelease(path);
        }
        CFRelease(runb);
        CFRelease(runFontS);
    }
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:CGPointZero];
    [bezierPath appendPath:[UIBezierPath bezierPathWithCGPath:paths]];
    
    CGPathRelease(paths);
    CFRelease(fontNameRef);
    CFRelease(fontRef);
    
    return bezierPath;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
