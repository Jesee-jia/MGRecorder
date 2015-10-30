//
//  RecorderView.m
//  Recorder
//
//  Created by MaShuai on 15/10/15.
//  Copyright © 2015年 MaShuai. All rights reserved.
//

#import "RecorderView.h"
#import <AVFoundation/AVFoundation.h>

#define LIGHT_RED_COLOR [UIColor colorWithRed:239.0/255.0f green:86.0/255.0f blue:70.0/255.0f alpha:1.0f]
#define LIGHT_GREEN_COLOR [UIColor colorWithRed:83.0/255.0f green:181.0/255.0f blue:70.0/255.0f alpha:1.0f]

#define COUNT 30

@interface RecorderView ()
{
    UIImageView *_microphone;//麦克风视图
    UIImageView *_microphoneInside;//麦克风内部视图
    AVAudioRecorder *_recorder;//录音器
    NSTimer *_listenAveragePowerTimer;//监听录音的平均力度的定时器
    NSString *_tempPath;//语音缓存路径
    UILabel *_countLabel;//倒计时标签
    NSTimer *_countTimer;//倒计时计时器
    int _count;
}
@end

@implementation RecorderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        
        UIImage *microphoneImage = [UIImage imageNamed:@"lp_microphone"];
        _microphone = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, microphoneImage.size.width, microphoneImage.size.height)];
        _microphone.center = self.center;
        [_microphone setImage:microphoneImage];
        [self addSubview:_microphone];
        
        UIImage *microphoneInsideImage = [UIImage imageNamed:@"lp_microphone_inside1"];
        _microphoneInside = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, microphoneInsideImage.size.width, microphoneInsideImage.size.height)];
        _microphoneInside.center = CGPointMake(_microphone.bounds.size.width/2, _microphone.bounds.size.height/2-10);
        [_microphoneInside setImage:microphoneInsideImage];
        [_microphone addSubview:_microphoneInside];
        
        _countLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, self.bounds.size.width, 80)];
        [_countLabel setFont:[UIFont boldSystemFontOfSize:80]];
        [_countLabel setTextAlignment:NSTextAlignmentCenter];
        [_countLabel setTextColor:LIGHT_GREEN_COLOR];
        [_countLabel setText:[NSString stringWithFormat:@"%d",COUNT]];
        [self addSubview:_countLabel];
    }
    return self;
}

//显示
- (void)showInView:(UIView *)view
{
    //开始录音
    [self startRecording];
    
    [view addSubview:self];
    [UIView animateWithDuration:0.4f
                     animations:^{
                         [self setBackgroundColor:[UIColor colorWithWhite:0.0f alpha:0.2]];
                     } completion:nil];
}

//隐藏
- (void)hide
{

    if (_recorder.isRecording) {
        //结束录音
        [self stopRecording];
    }
    

    [UIView animateWithDuration:0.4f
                     animations:^{
                         [self setBackgroundColor:[UIColor clearColor]];
                     } completion:^(BOOL finished) {
                         if (self.superview) {
                             [self removeFromSuperview];
                         }
     
                     }];


}

//开始录音
- (void)startRecording
{
    //开始录音时 倒计时重置
    _count = COUNT;
    [_countLabel setText:[NSString stringWithFormat:@"%d",_count]];
    [_countLabel setTextColor:LIGHT_GREEN_COLOR];
    
    if (!_tempPath) {
        //语音存储路径
        NSString *tempPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/tempPath"];
        NSLog(@"tempPath %@", tempPath);
        if (![[NSFileManager defaultManager] fileExistsAtPath:tempPath]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:tempPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        tempPath = [tempPath stringByAppendingPathComponent:@"tempAudio.m4a"];
        //给录音缓存路径赋值
        _tempPath = tempPath;
    }
    
    if (!_recorder) {
        
        //真机测试解决无法录音
        if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending)
        {
            //7.0第一次运行会提示，是否允许使用麦克风
            AVAudioSession *session = [AVAudioSession sharedInstance];
            NSError *sessionError;
            //AVAudioSessionCategoryPlayAndRecord用于录音和播放
            [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
            if(session == nil)
                NSLog(@"Error creating session: %@", [sessionError description]);
            else
                [session setActive:YES error:nil];
        }
        
        
        NSURL *tempPathURL = [NSURL fileURLWithPath:_tempPath];
        
        //录音设置字典，设置录音格式为m4a，设置采样频率为22050.0，设置音频通道为1，设置录音质量为最低
        NSMutableDictionary* recordSetting = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                              [NSNumber numberWithInt:kAudioFormatMPEG4AAC], AVFormatIDKey,
                                              [NSNumber numberWithFloat:22050.0], AVSampleRateKey,
                                              [NSNumber numberWithInt:1], AVNumberOfChannelsKey,
                                              [NSNumber numberWithInt:AVAudioQualityMin], AVEncoderAudioQualityKey,
                                              [NSNumber numberWithInt:AVAudioQualityMin], AVSampleRateConverterAudioQualityKey,
                                              [NSNumber numberWithInt:8], AVLinearPCMBitDepthKey,
                                              [NSNumber numberWithInt:8],
                                              AVEncoderBitDepthHintKey,
                                              nil];
        
        _recorder = [[AVAudioRecorder alloc] initWithURL:tempPathURL settings:recordSetting error:nil];
    }
    
    [_recorder prepareToRecord];
    [_recorder setMeteringEnabled:YES];
    [_recorder record];
    
    if (!_listenAveragePowerTimer) {
        _listenAveragePowerTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(listenAveragePower) userInfo:nil repeats:YES];
    }
    //开启定时器
    [_listenAveragePowerTimer setFireDate:[NSDate  distantPast]];
    
    if (!_countTimer) {
        _countTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(countDown) userInfo:nil repeats:YES];
    }
    //开启倒计时定时器
    [_countTimer setFireDate:[NSDate distantPast]];
}

//结束录音
- (void)stopRecording
{
    //录音时间
    _recordSecond = _recorder.currentTime;
    
    if (!_myNewPath) {
        NSString *newPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/newPath"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:newPath]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:newPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        newPath = [newPath stringByAppendingPathComponent:@"newAudio.m4a"];
        //给语音新路径赋值
        _myNewPath = newPath;
    }
    
    //结束录音
    [_recorder stop];
    //关闭定时器
    [_listenAveragePowerTimer setFireDate:[NSDate distantFuture]];
    //关闭倒计时定时器
    [_countTimer setFireDate:[NSDate distantFuture]];
    
    //判断录音时间是否大于1秒
    if (_recordSecond>1.0f) {
        //把新路径里的内容清空
        [[NSFileManager defaultManager] removeItemAtPath:_myNewPath error:nil];
        //把时长大于1秒的语音移动到新路径
        [[NSFileManager defaultManager] moveItemAtPath:_tempPath toPath:_myNewPath error:nil];
    } else {
        //删除录音
        [_recorder deleteRecording];
    }
}


//监听录音的平均力度
- (void)listenAveragePower
{
    [_recorder updateMeters];
    CGFloat average = [_recorder averagePowerForChannel:0];
    NSLog(@"average %f",average);
    int imageIndex;
    if (average<= - 50.543) {
        imageIndex = 1;
    } else if ( - 50.543 <average && average<= - 46.686) {
        imageIndex = 1;
    } else if ( - 46.686 <average && average<= - 42.829) {
        imageIndex = 1;
    } else if ( - 42.829 <average && average<= - 38.982) {
        imageIndex = 1;
    } else if ( - 38.982 <average && average<= - 35.135) {
        imageIndex = 2;
    } else if ( - 35.135 <average && average<= - 31.288) {
        imageIndex = 3;
    } else if ( - 31.288 <average && average<= - 27.441) {
        imageIndex = 4;
    } else if ( - 27.441 <average && average<= - 23.594) {
        imageIndex = 5;
    } else if ( - 23.594 <average && average<= - 19.747) {
        imageIndex = 6;
    } else if ( - 19.747 <average && average<= - 15.900) {
        imageIndex = 7;
    } else if ( - 15.900 <average && average<= - 12.053) {
        imageIndex = 8;
    } else if ( - 12.053 <average && average<= - 8.206) {
        imageIndex = 9;
    } else if ( - 8.206 <average && average<= - 4.359) {
        imageIndex = 9;
    } else if ( - 4.359 <average && average<= 0) {
        imageIndex = 9;
    } else {
        imageIndex = 9;
    }
    
    UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"lp_microphone_inside%d",imageIndex]];
    [_microphoneInside setImage:image];
}

//倒计时
- (void)countDown
{
    if (_count <= 10) {
        [_countLabel setTextColor:LIGHT_RED_COLOR];
    }
    if (_count == 0) {
        [self hide];
    } else {
        [_countLabel setText:[NSString stringWithFormat:@"%d",_count]];
        _count -= 1;

    }
}

@end
