//
//  HomeCollectionCell.m
//  EducationPlayer
//
//  Created by zzy on 7/27/16.
//  Copyright © 2016 zzy. All rights reserved.
//

#import "HomeCollectionCell.h"

@interface HomeCollectionCell()
@property (nonatomic, weak)UIButton *btn;
@end

@implementation HomeCollectionCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.backgroundColor = CustomColor(20, 118, 224);
        btn.userInteractionEnabled = NO;
        [self addSubview:btn];
        self.btn = btn;
    }
    return self;
}

- (void)layoutSubviews {

    self.btn.frame = self.contentView.frame;
    
}

- (void)setTitle:(NSString *)title {

    [self.btn setTitle:title forState:UIControlStateNormal];
}

@end
