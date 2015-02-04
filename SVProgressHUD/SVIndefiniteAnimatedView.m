//
//  SVIndefiniteAnimatedView.m
//  SVProgressHUD
//
//  Created by Guillaume Campagna on 2014-12-05.
//
//

#import "SVIndefiniteAnimatedView.h"

#pragma mark SVIndefiniteAnimatedView

@interface SVIndefiniteAnimatedView ()

@property (nonatomic, strong) CAShapeLayer *indefiniteAnimatedLayer;
@property (nonatomic, strong) UIImageView *gifAnimatedInfinityView;
@property (nonatomic, strong) UIImageView *gifAnimatedStartView;

@end

@implementation SVIndefiniteAnimatedView

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (newSuperview) {
        [self layoutGifAnimated];
    } else {
//        [_indefiniteAnimatedLayer removeFromSuperlayer];
//        _indefiniteAnimatedLayer = nil;
        [_gifAnimatedInfinityView removeFromSuperview];
        [_gifAnimatedStartView removeFromSuperview];
        _gifAnimatedInfinityView = nil;
    }
}

//- (void)layoutAnimatedLayer {
//    CALayer *layer = self.indefiniteAnimatedLayer;
//
//    [self.layer addSublayer:layer];
//    layer.position = CGPointMake(CGRectGetWidth(self.bounds) - CGRectGetWidth(layer.bounds) / 2, CGRectGetHeight(self.bounds) - CGRectGetHeight(layer.bounds) / 2);
//}

- (void)layoutGifAnimated {
    UIView *layer = self.gifAnimatedInfinityView;
    [self addSubview:layer];
    layer.center = CGPointMake(CGRectGetWidth(self.bounds) - CGRectGetWidth(layer.bounds) / 2, CGRectGetHeight(self.bounds) - CGRectGetHeight(layer.bounds) / 2);

    layer = self.gifAnimatedStartView;
    [self addSubview:layer];
    layer.center = CGPointMake(CGRectGetWidth(self.bounds) - CGRectGetWidth(layer.bounds) / 2, CGRectGetHeight(self.bounds) - CGRectGetHeight(layer.bounds) / 2);
    _gifAnimatedStartView.hidden = NO;
    _gifAnimatedInfinityView.hidden = YES;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _gifAnimatedInfinityView.hidden = NO;
        _gifAnimatedStartView.hidden = YES;
        [_gifAnimatedInfinityView startAnimating];
    });
}

- (CAShapeLayer*)indefiniteAnimatedLayer {
    if(!_indefiniteAnimatedLayer) {
        CGPoint arcCenter = CGPointMake(self.radius+self.strokeThickness/2+5, self.radius+self.strokeThickness/2+5);
        CGRect rect = CGRectMake(0.0f, 0.0f, arcCenter.x*2, arcCenter.y*2);
        
        UIBezierPath* smoothedPath = [UIBezierPath bezierPathWithArcCenter:arcCenter
                                                                    radius:self.radius
                                                                startAngle:M_PI*3/2
                                                                  endAngle:M_PI/2+M_PI*5
                                                                 clockwise:YES];
        
        _indefiniteAnimatedLayer = [CAShapeLayer layer];
        _indefiniteAnimatedLayer.contentsScale = [[UIScreen mainScreen] scale];
        _indefiniteAnimatedLayer.frame = rect;
        _indefiniteAnimatedLayer.fillColor = [UIColor clearColor].CGColor;
        _indefiniteAnimatedLayer.strokeColor = self.strokeColor.CGColor;
        _indefiniteAnimatedLayer.lineWidth = self.strokeThickness;
        _indefiniteAnimatedLayer.lineCap = kCALineCapRound;
        _indefiniteAnimatedLayer.lineJoin = kCALineJoinBevel;
        _indefiniteAnimatedLayer.path = smoothedPath.CGPath;
        
        CALayer *maskLayer = [CALayer layer];
        maskLayer.contents = (id)[[UIImage imageNamed:@"SVProgressHUD.bundle/angle-mask"] CGImage];
        maskLayer.frame = _indefiniteAnimatedLayer.bounds;
        _indefiniteAnimatedLayer.mask = maskLayer;
        
        NSTimeInterval animationDuration = 1;
        CAMediaTimingFunction *linearCurve = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        animation.fromValue = 0;
        animation.toValue = [NSNumber numberWithFloat:M_PI*2];
        animation.duration = animationDuration;
        animation.timingFunction = linearCurve;
        animation.removedOnCompletion = NO;
        animation.repeatCount = INFINITY;
        animation.fillMode = kCAFillModeForwards;
        animation.autoreverses = NO;
        [_indefiniteAnimatedLayer.mask addAnimation:animation forKey:@"rotate"];
        
        CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
        animationGroup.duration = animationDuration;
        animationGroup.repeatCount = INFINITY;
        animationGroup.removedOnCompletion = NO;
        animationGroup.timingFunction = linearCurve;
        
        CABasicAnimation *strokeStartAnimation = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
        strokeStartAnimation.fromValue = @0.015;
        strokeStartAnimation.toValue = @0.515;
        
        CABasicAnimation *strokeEndAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        strokeEndAnimation.fromValue = @0.485;
        strokeEndAnimation.toValue = @0.985;
        
        animationGroup.animations = @[strokeStartAnimation, strokeEndAnimation];
        [_indefiniteAnimatedLayer addAnimation:animationGroup forKey:@"progress"];
        
    }
    return _indefiniteAnimatedLayer;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    if (self.superview) {
        [self layoutGifAnimated];
    }
}

- (void)setRadius:(CGFloat)radius {
    _radius = radius;
    
    [_indefiniteAnimatedLayer removeFromSuperlayer];
    _indefiniteAnimatedLayer = nil;
    
    if (self.superview) {
        [self layoutGifAnimated];
    }
}

- (void)setStrokeColor:(UIColor *)strokeColor {
    _strokeColor = strokeColor;
    _indefiniteAnimatedLayer.strokeColor = strokeColor.CGColor;
}

- (void)setStrokeThickness:(CGFloat)strokeThickness {
    _strokeThickness = strokeThickness;
    _indefiniteAnimatedLayer.lineWidth = _strokeThickness;
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake((self.radius+self.strokeThickness/2+5)*2, (self.radius+self.strokeThickness/2+5)*2);
}

#pragma mark - Custom Animation
- (UIImageView*)gifAnimatedStartView
{
    if (!_gifAnimatedStartView) {
        NSArray *imgs = [self loadAnimationImagesWithFirstFrame:0 andLastFrame:14];
        _gifAnimatedStartView = [[UIImageView alloc] initWithImage:imgs[14]];
        _gifAnimatedStartView.animationImages = imgs;
        _gifAnimatedStartView.animationDuration = 0.4f;
        _gifAnimatedStartView.animationRepeatCount = 1;
        _gifAnimatedStartView.hidden = NO;

        [_gifAnimatedStartView startAnimating];
    }
    return _gifAnimatedStartView;
}

- (UIImageView*)gifAnimatedInfinityView
{
    if (!_gifAnimatedInfinityView) {
        NSArray *imgs = [self loadAnimationImagesWithFirstFrame:14 andLastFrame:29];
        _gifAnimatedInfinityView = [[UIImageView alloc] initWithImage:imgs[14]];
        _gifAnimatedInfinityView.animationImages = imgs;
        _gifAnimatedInfinityView.animationRepeatCount = 0;
        _gifAnimatedInfinityView.animationDuration = 0.7f;
        _gifAnimatedInfinityView.hidden = YES;
//        [_gifAnimatedInfinityView startAnimating];
    }
    return _gifAnimatedInfinityView;
}

- (NSArray*)loadAnimationImagesWithFirstFrame:(NSUInteger)aFirstFrame andLastFrame:(NSUInteger)aLastFrame
{
    NSMutableArray *arrAnimImgs = [@[] mutableCopy];
    for (int i=aFirstFrame; i<aLastFrame+1; i++) {
        NSString *imgName = [self frameName:i withPrefix:@"loader_"];
        [arrAnimImgs addObject:[UIImage imageNamed:imgName]];
    }
    return arrAnimImgs;
}

- (NSString*)frameName:(NSUInteger)aFrameNum withPrefix:(NSString*)aPrefix
{
    NSString *format = @"%@%05d";
    return [NSString stringWithFormat:format, aPrefix, aFrameNum];
}

@end
