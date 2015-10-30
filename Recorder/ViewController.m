//
//  ViewController.m
//  Recorder
//
//  Created by MaShuai on 15/10/15.
//  Copyright © 2015年 MaShuai. All rights reserved.
//

#import "ViewController.h"
#import "RecorderView.h"
#import "PlayerButton.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()<AVAudioPlayerDelegate>
{
    RecorderView *_recorderView;
    PlayerButton *_playerButton;
    AVAudioPlayer *_player;//播放器
}

@property (weak, nonatomic) IBOutlet UIImageView *recordImageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [_recordImageView addGestureRecognizer:longPressGesture];
    
    _recorderView = [[RecorderView alloc] initWithFrame:self.view.frame];
    
    _playerButton = [[PlayerButton alloc] initWithFrame:CGRectMake(100, 100, 81, 31)];
    [_playerButton addTarget:self action:@selector(play) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_playerButton];
}

- (void)play
{
    if (!_recorderView.myNewPath) return;
    
    //如果正在播放 则停止播放
    if (_player.isPlaying) {
        [_player stop];
        [_playerButton stopAnimating];
    //否则重头播放
    } else {
        _player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:_recorderView.myNewPath] error:nil];
        _player.delegate = self;
        
        [_player prepareToPlay];
        [_player play];
        
        [_playerButton startAnimating];
    }
   
}

- (void)longPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        NSLog(@"UIGestureRecognizerStateBegan");
        [_recorderView showInView:self.view];
        if (_player.isPlaying) {
            [_player stop];
            [_playerButton stopAnimating];
        }
    } else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        NSLog(@"UIGestureRecognizerStateChanged");
    } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        NSLog(@"UIGestureRecognizerStateEnded");
       
        [_recorderView hide];

        [_playerButton setSecond:_recorderView.recordSecond+0.5];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [_playerButton stopAnimating];
}

@end
