//
//  JMJRecordController.m
//  录音小demo
//
//  Created by HUST on 2021/1/21.
//

#import "JMJRecordController.h"
#import <Masonry.h>
#import <LGAlertView.h>
@interface JMJRecordController ()<AVAudioRecorderDelegate>

@property(nonatomic,strong)UIButton * startButton;
@property(nonatomic,strong)UIButton * pauseButton;
@property(nonatomic,strong)UILabel * timeLabel;
@property(nonatomic,strong)NSTimer *timer;
@property(nonatomic,strong)AVAudioRecorder * audioRecorder;
@property (nonatomic,copy)NSURL* recordUrl;
@property(nonatomic)int recordSec;

@end

@implementation JMJRecordController

-(void) initRecorder
{
    //删除上次生成的文件，保留最新文件
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //默认就是wav格式，是无损的
    if ([fileManager fileExistsAtPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"recordAudio.wav"]]) {
        [fileManager removeItemAtPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"recordAudio.wav"] error:nil];
    }
    //录音设置
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    //设置录音格式 AVFormatIDKey==kAudioFormatLinearPCM
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
    //设置录音采样率(Hz) 如：AVSampleRateKey==8000/44100/96000（影响音频的质量）, 采样率必须要设为11025才能使转化成mp3格式后不会失真
    [recordSetting setValue:[NSNumber numberWithFloat:16000] forKey:AVSampleRateKey];
    //录音通道数 1 或 2 ，要转换成mp3格式必须为双通道
    [recordSetting setValue:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
    //线性采样位数 8、16、24、32
    [recordSetting setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    //录音的质量
    [recordSetting setValue:[NSNumber numberWithInt:AVAudioQualityHigh] forKey:AVEncoderAudioQualityKey];
    // 设置录制音频采用高位优先的记录格式
    [recordSetting setValue:[NSNumber numberWithBool:YES] forKey:AVLinearPCMIsBigEndianKey];
    // 设置采样信号采用浮点数
    [recordSetting setValue:[NSNumber numberWithBool:YES] forKey:AVLinearPCMIsFloatKey];
    //存储录音文件
    _recordUrl = [NSURL URLWithString:[NSTemporaryDirectory()stringByAppendingPathComponent:@"recordAudio.wav"]];
    //初始化录音对象
    NSError * error;
    _audioRecorder = [[AVAudioRecorder alloc] initWithURL:_recordUrl settings:recordSetting error:&error];
    if (error) {
        NSLog(@"%@",error.description);
        return;
    }
    _audioRecorder.delegate = self;
    //开启音量检测
    _audioRecorder.meteringEnabled = YES;
    

}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initRecorder];
    _startButton = [[UIButton alloc]init];
    _startButton.userInteractionEnabled = YES;
    _startButton.mas_key=@"startButton";
    _startButton.layer.cornerRadius=5;
    _startButton.layer.masksToBounds = YES;
    [_startButton setBackgroundColor:[UIColor greenColor]];
    [_startButton setTitle:@"开始录制" forState:UIControlStateNormal];
    [_startButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view addSubview:_startButton];
    [_startButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(150.f);
        make.centerX.equalTo(self.view.mas_centerX);
        make.width.equalTo(@150);
        make.height.equalTo(@30);
    }];
    
    [_startButton addTarget:self action:@selector(startRecording) forControlEvents:UIControlEventTouchUpInside];
    
    _pauseButton = [[UIButton alloc]init];
    _pauseButton.userInteractionEnabled = NO;
    _pauseButton.mas_key= @"pauseButton";
    _pauseButton.layer.cornerRadius=5;
    _pauseButton.layer.masksToBounds = YES;
    [_pauseButton setBackgroundColor:[UIColor yellowColor]];
    [_pauseButton setTitle:@"暂停录制" forState:UIControlStateNormal];
    [_pauseButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view addSubview:_pauseButton];
    [_pauseButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_startButton.mas_bottom).offset(50.f);
        make.centerX.equalTo(self.view.mas_centerX);
        make.width.equalTo(@150);
        make.height.equalTo(@30);
    }];
    
    _timeLabel = [[UILabel alloc]init];
    _timeLabel.text = @"00:00";
    _timeLabel.textAlignment=NSTextAlignmentCenter;
    [self.view addSubview:_timeLabel];
    [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_pauseButton.mas_bottom).offset(50.f);
        make.centerX.equalTo(self.view.mas_centerX);
        make.width.equalTo(@150);
        make.height.equalTo(@30);
    }];
    
    [_pauseButton addTarget:self action:@selector(pauseRecording) forControlEvents:UIControlEventTouchUpInside];
    [self checkPermission];
}

-(void)startRecording
{
    //如果不是正在录音
    if (![_audioRecorder isRecording]) {
        AVAudioSession * audioSession = [AVAudioSession sharedInstance];//得到音频会话单例对象
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];//设置类别,表示该应用同时支持播放和录音
        [audioSession setActive:YES error:nil];//激活当前应用的音频会话,此时会阻断后台音乐的播放.
        [_audioRecorder prepareToRecord];//准备录音
        [_audioRecorder record];//开始录音
        _pauseButton.userInteractionEnabled = YES;
        [self startTimer];
        [_startButton setTitle:@"结束录制" forState:UIControlStateNormal];
        [_startButton setTintColor:[UIColor redColor]];
    }else{
        _pauseButton.userInteractionEnabled = NO;
        [self resetTimer];
        [_audioRecorder stop];
        [_startButton setTitle:@"开始录制" forState:UIControlStateNormal];
    }
}

-(void)pauseRecording
{
    if (![_audioRecorder isRecording]) {
        [self continueTimer];
        [_pauseButton setTitle:@"暂停录制" forState:UIControlStateNormal];
        [_audioRecorder record];
    }else{
        [self pauseTimer];
        [_pauseButton setTitle:@"继续录制" forState:UIControlStateNormal];
        [_audioRecorder pause];
    }
}

- (BOOL)checkPermission{
    
//    AVAudioSessionRecordPermission permission = [[AVAudioSession sharedInstance] recordPermission];
//    return permission == AVAudioSessionRecordPermissionGranted;
    __block BOOL bCanRecord = YES;
    if ([[[UIDevice currentDevice]systemVersion]floatValue] >= 7.0) {
        AVAuthorizationStatus videoAuthStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
         if (videoAuthStatus == AVAuthorizationStatusNotDetermined) {// 未询问用户是否授权
             AVAudioSession *audioSession = [AVAudioSession sharedInstance];
             if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
                 [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
                     if (granted) {
                         bCanRecord = YES;
                     } else {
                         bCanRecord = NO;
                     }
                 }];
             }
         } else if(videoAuthStatus == AVAuthorizationStatusRestricted || videoAuthStatus == AVAuthorizationStatusDenied) {
            // 未授权
             NSLog(@"未授权");
            [self showSetAlertView];
        }
        else{
            // 已授权
            NSLog(@"已授权");
        }
    }
    return bCanRecord;
}

//提示用户进行麦克风使用授权
- (void)showSetAlertView {
    LGAlertView* alert= [LGAlertView alertViewWithTitle:@"麦克风权限未开启" message:@"麦克风权限未开启,请进入系统【设置】>【隐私】>【麦克风】中打开开关,开启麦克风功能" style:LGAlertViewStyleAlert buttonTitles:@[] cancelButtonTitle:@"取消" destructiveButtonTitle:@"去设置"];
    [alert setDestructiveHandler:^(LGAlertView * _Nonnull alertView) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
    }];
    [alert showAnimated];
};

//定时器有关函数
-(void)startTimer
{
    _recordSec=0;
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:true block:^(NSTimer * _Nonnull timer) {
        self->_recordSec+=1;
        [self updateTimeLabel];
    }];
    [_timer fire];
}

-(void)updateTimeLabel
{
    int seconds = _recordSec%60;
    int minutes = (_recordSec/60)%60;
    _timeLabel.text = [NSString stringWithFormat:@"%02d:%02d",minutes,seconds];
}

-(void)resetTimer
{
    [_timer invalidate];
    _recordSec=0;
    [self updateTimeLabel];
}

-(void)pauseTimer
{
    [_timer setFireDate:[NSDate distantFuture]];
}

-(void)continueTimer
{
    [_timer setFireDate:[NSDate date]];
}
@end
