//
//  RecorderView.h
//  Recorder
//
//  Created by MaShuai on 15/10/15.
//  Copyright © 2015年 MaShuai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecorderView : UIView

@property (nonatomic, strong) NSString *myNewPath;//判断时长大于1秒的可用录音存储路径
@property (nonatomic, assign) CGFloat recordSecond;//录音时长

- (void)showInView:(UIView *)view;
- (void)hide;

@end
