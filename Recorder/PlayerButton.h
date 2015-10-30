//
//  PlayerButton.h
//  Recorder
//
//  Created by MaShuai on 15/10/16.
//  Copyright © 2015年 MaShuai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayerButton : UIButton

//开始动画
- (void)startAnimating;
//结束动画
- (void)stopAnimating;
//设置秒数
- (void)setSecond:(int)second;

@end
