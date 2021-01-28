//
//  JMJPlayController.m
//  录音小demo
//
//  Created by HUST on 2021/1/21.
//

#import "JMJPlayController.h"
#import <Masonry.h>
@interface JMJPlayController ()

@property(nonatomic,strong)UIButton * startButton;
@property(nonatomic,strong)UIButton * pauseButton;
@property(nonatomic,strong)AVAudioPlayer *player;
@property (nonatomic,copy)NSURL* recordUrl;


@end

@implementation JMJPlayController


-(void)initPlayer
{
    NSError *error;
        AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:_recordUrl error:&error];
    if (player) {
        _player = player;
        player.numberOfLoops = 1; // loop indefinitely
        player.enableRate = YES;
        player.volume = 1.0;
        [player prepareToPlay];
    } else {
        NSLog(@"Error creating player: %@", [error localizedDescription]);
    }
    //设置播放模式
    [[AVAudioSession sharedInstance]overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _recordUrl = [NSURL URLWithString:[NSTemporaryDirectory()stringByAppendingPathComponent:@"recordAudio.wav"]];
    
    [self initPlayer];
    _startButton = [[UIButton alloc]init];
    _startButton.userInteractionEnabled = YES;
    _startButton.mas_key=@"startButton";
    _startButton.layer.cornerRadius=5;
    _startButton.layer.masksToBounds = YES;
    [_startButton setBackgroundColor:[UIColor cyanColor]];
    [_startButton setTitle:@"开始播放" forState:UIControlStateNormal];
    [_startButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view addSubview:_startButton];
    [_startButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(150.f);
        make.centerX.equalTo(self.view.mas_centerX);
        make.width.equalTo(@150);
        make.height.equalTo(@30);
    }];
    [_startButton addTarget:self action:@selector(startPlaying) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    _pauseButton = [[UIButton alloc]init];
    _pauseButton.userInteractionEnabled = NO;
    _pauseButton.mas_key= @"pauseButton";
    _pauseButton.layer.cornerRadius=5;
    _pauseButton.layer.masksToBounds = YES;
    [_pauseButton setBackgroundColor:[UIColor yellowColor]];
    [_pauseButton setTitle:@"暂停播放" forState:UIControlStateNormal];
    [_pauseButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view addSubview:_pauseButton];
    [_pauseButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_startButton.mas_bottom).offset(50.f);
        make.centerX.equalTo(self.view.mas_centerX);
        make.width.equalTo(@150);
        make.height.equalTo(@30);
    }];
    
}


-(void)startPlaying
{
    if(_player){
        if(!_player.isPlaying){
            [_player play];
            [_startButton setBackgroundColor:[UIColor redColor]];
            [_startButton setTitle:@"结束播放" forState:UIControlStateNormal];
            _pauseButton.userInteractionEnabled = YES;
        }else{
            [_player stop];
            [_startButton setBackgroundColor:[UIColor cyanColor]];
            [_startButton setTitle:@"开始播放" forState:UIControlStateNormal];
            _pauseButton.userInteractionEnabled = NO;
        }
    }
}

-(void)pausePlaying
{
    if(_player){
        if(!_player.isPlaying){
            [_player play];
            [_startButton setBackgroundColor:[UIColor yellowColor]];
            [_startButton setTitle:@"暂停播放" forState:UIControlStateNormal];
        }else{
            [_player pause];
            [_startButton setBackgroundColor:[UIColor orangeColor]];
            [_startButton setTitle:@"继续播放" forState:UIControlStateNormal];
        }
    }
}


@end
