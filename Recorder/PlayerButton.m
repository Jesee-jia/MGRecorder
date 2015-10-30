//
//  PlayerButton.m
//  Recorder
//
//  Created by MaShuai on 15/10/16.
//  Copyright © 2015年 MaShuai. All rights reserved.
//

#import "PlayerButton.h"

@implementation PlayerButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundImage:[UIImage imageNamed:@"lp_audioplay_button"] forState:UIControlStateNormal];
        [self setBackgroundImage:[UIImage imageNamed:@"lp_audioplay_button"] forState:UIControlStateHighlighted];
        [self setImage:[UIImage imageNamed:@"lp_bugle3"] forState:UIControlStateNormal];
        
        //设置标题标签的属性
        [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self setTitle:@"0\"" forState:UIControlStateNormal];
        
        //设置图片视图的属性
        NSMutableArray *imageArray = [NSMutableArray array];
        for (int i=1; i<4; i++) {
            UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"lp_bugle%d.png",i]];
            [imageArray addObject:image];
        }
        self.imageView.animationImages = imageArray;
        self.imageView.animationDuration = 1;
        self.imageView.animationRepeatCount = 0;
        
    }
    return self;
}

- (void)startAnimating
{
    [self.imageView startAnimating];
}

- (void)stopAnimating
{
    [self.imageView stopAnimating];
}

- (void)setSecond:(int)second
{
    if (second>1.0f) {
        [self setTitle:[NSString stringWithFormat:@"%d\"",second] forState:UIControlStateNormal];
    }
    
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    return CGRectMake(self.bounds.size.width-18-15, (self.bounds.size.height-16)/2, 18, 16);
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect
{
    return CGRectMake(10, (self.bounds.size.height-20)/2, 40, 20);
}

@end
