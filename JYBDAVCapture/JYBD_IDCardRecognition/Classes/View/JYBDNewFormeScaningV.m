//
//  JYBDNewFormeScaningV.m
//  Pods
//
//  Created by tianxiuping on 2018/7/9.
//

#import "JYBDNewFormeScaningV.h"
#import "IDCardRectManager.h"

@interface JYBDNewFormeScaningV ()

@property (nonatomic,strong)UIImageView *bgImageView;
@property (nonatomic,strong)UIImageView *scanImageView;
@property (nonatomic,strong)UIButton *turnOnOrOffBtn;
@property (nonatomic,strong)UILabel *scanLab;
@property (nonatomic,strong)UILabel *turnOnOrOffLab;
@property (nonatomic,strong)UIView *turnOnOrOffView;

@end

@implementation JYBDNewFormeScaningV

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor clearColor];
        [self creatUI];
    }
    
    return self;
}

- (void)dealloc
{
    [self removeAnimation];
}

- (void)creatUI
{
    [self addSubview:self.scanLab];
    [self addSubview:self.bgImageView];
    [self.bgImageView addSubview:self.scanImageView];
    //[self.bgImageView addSubview:self.userImageView];
    
    [self addSubview:self.turnOnOrOffView];
    [self.turnOnOrOffView addSubview:self.turnOnOrOffBtn];
    [self.turnOnOrOffView addSubview:self.turnOnOrOffLab];
    
    self.scanLab.frame = CGRectMake(10, 0, 20, self.frame.size.height);
    
    self.bgImageView.frame = CGRectMake(40, 0, self.frame.size.width-80, self.frame.size.height);
    
    
    UIImage *img = [UIImage imageNamed:@"scaningline" inBundle:[IDCardRectManager getImageBundle] compatibleWithTraitCollection:nil];
    self.scanImageView.frame = CGRectMake(self.bgImageView.frame.size.width-20, 30, img.size.width, self.bgImageView.frame.size.height-60);
    
    [self.scanImageView.layer addAnimation:[self animation] forKey:nil];
    
    self.turnOnOrOffView.frame = CGRectMake(self.bgImageView.frame.origin.x+self.bgImageView.frame.size.width, 0, 50, self.frame.size.height);
    
    CGSize size = [self getLabelSizeWithStr:self.turnOnOrOffLab.text font:self.turnOnOrOffLab.font];
    
    self.turnOnOrOffBtn.frame = CGRectMake((self.turnOnOrOffView.frame.size.height-50-size.width)/2, 0, 50, 50);
    self.turnOnOrOffLab.frame = CGRectMake(self.turnOnOrOffBtn.frame.origin.x+50, 0, size.width, 50);
}

- (UIImageView *)bgImageView
{
    if (_bgImageView == nil)
    {
        _bgImageView = [[UIImageView alloc]init];
        UIImage *imag = [UIImage imageNamed:@"scaningbgimage" inBundle:[IDCardRectManager getImageBundle] compatibleWithTraitCollection:nil];
        
        _bgImageView.image = imag;
      //  _bgImageView.contentMode = UIViewContentModeCenter;
    }
    return _bgImageView;
}

- (UIImageView *)scanImageView
{
    if (_scanImageView == nil)
    {
        _scanImageView = [[UIImageView alloc]init];
        UIImage *imag = [UIImage imageNamed:@"scaningline" inBundle:[IDCardRectManager getImageBundle] compatibleWithTraitCollection:nil];
        
        _scanImageView.image = imag;
       // _scanImageView.contentMode = UIViewContentModeCenter;
    }
    return _scanImageView;
}

- (UIButton *)turnOnOrOffBtn
{
    if (_turnOnOrOffBtn == nil)
    {
        _turnOnOrOffBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *imag = [UIImage imageNamed:@"flashlightscan" inBundle:[IDCardRectManager getImageBundle] compatibleWithTraitCollection:nil];
        
        [_turnOnOrOffBtn setImage:imag forState:UIControlStateNormal];
        _turnOnOrOffBtn.showsTouchWhenHighlighted = YES;
        [_turnOnOrOffBtn addTarget:self action:@selector(turnOnOrOffClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _turnOnOrOffBtn;
}

- (UILabel *)scanLab
{
    if (_scanLab == nil)
    {
        _scanLab = [[UILabel alloc]init];
        _scanLab.font = [UIFont systemFontOfSize:17];
        _scanLab.text = @"扫描身份证";
        _scanLab.textAlignment = NSTextAlignmentCenter;
        _scanLab.textColor = [UIColor whiteColor];
        _scanLab.transform = CGAffineTransformMakeRotation(M_PI * 0.5);
    }
    return _scanLab;
}

- (UILabel *)turnOnOrOffLab
{
    if (_turnOnOrOffLab == nil)
    {
        _turnOnOrOffLab = [[UILabel alloc]init];
        _turnOnOrOffLab.font = [UIFont systemFontOfSize:15];
        _turnOnOrOffLab.text = @"  环境太暗看不清？打开手电筒";
        _turnOnOrOffLab.textColor = [UIColor whiteColor];
       // _turnOnOrOffLab.transform = CGAffineTransformMakeRotation(M_PI * 0.5);
    }
    return _turnOnOrOffLab;
}

- (UIView *)turnOnOrOffView
{
    if (_turnOnOrOffView == nil)
    {
        _turnOnOrOffView = [[UIView alloc]init];
        _turnOnOrOffView.backgroundColor = [UIColor clearColor];
        _turnOnOrOffView.transform = CGAffineTransformMakeRotation(M_PI * 0.5);
    }
    return _turnOnOrOffView;
}
/**
 *  动画
 */
- (CABasicAnimation *)animation{
    CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:@"position"];
    animation.duration = 3;
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.repeatCount = MAXFLOAT;
    
    animation.fromValue = [NSValue valueWithCGPoint:self.scanImageView.layer.position];
    animation.toValue = [NSValue valueWithCGPoint:CGPointMake(30, self.bgImageView.center.y)];
    return animation;
}

/**
 *  移除动画
 */
- (void)removeAnimation{
    [self.scanImageView.layer removeAllAnimations];
}

- (CGSize)getLabelSizeWithStr:(NSString *)str font:(UIFont *)font{
    CGSize size = [str sizeWithAttributes:@{NSFontAttributeName:font}];
    return size;
}

- (void)setScanType:(JYBDScaningType)scanType
{
    _scanType = scanType;
    if (scanType == JYBD_IDScanType)
    {
        self.scanLab.text = @"扫描身份证";
    }
    else if (scanType == JYBD_BankScanType)
    {
        self.scanLab.text = @"扫描银行卡";
    }
}
- (void)turnOnOrOffClick:(UIButton *)btn
{
    btn.selected = !btn.selected;
    if (self.turnOnOrOffClick)
    {
        self.turnOnOrOffClick(btn.selected);
    }
}

@end
