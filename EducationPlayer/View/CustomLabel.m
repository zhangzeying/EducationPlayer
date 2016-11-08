//
//  CustomLabel.m
//  BathroomShopping
//
//  Created by zzy on 7/12/16.
//  Copyright © 2016 zzy. All rights reserved.
//

#import "CustomLabel.h"
#import "BathConst.h"

@implementation CustomLabel

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.font = [UIFont systemFontOfSize:15];
        self.textColor = [UIColor colorWithRed:BathRed green:BathGreen blue:BathBlue alpha:1.0];
        self.textAlignment = NSTextAlignmentCenter;
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)setScale:(CGFloat)scale
{
    _scale = scale;
    
    //      R G B
    // 默认：0.4 0.6 0.7
    // 红色：1   0   0
    
    CGFloat red = BathRed + (1 - BathRed) * scale;
    CGFloat green = BathGreen + (0 - BathGreen) * scale;
    CGFloat blue = BathBlue + (0 - BathBlue) * scale;
    self.textColor = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
    
    // 大小缩放比例
    CGFloat transformScale = 1 + scale * 0.3; // [1, 1.3]
    self.transform = CGAffineTransformMakeScale(transformScale, transformScale);
}

@end
