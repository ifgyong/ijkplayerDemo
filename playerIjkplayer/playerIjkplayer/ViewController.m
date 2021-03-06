//
//  ViewController.m
//  playerIjkplayer
//
//  Created by Charlie on 16/12/26.
//  Copyright © 2016年 www.fgyong.cn. All rights reserved.
//

#import "ViewController.h"



@interface ViewController ()
@property (atomic, strong) NSURL *url;
@property (atomic, retain) id <IJKMediaPlayback> player;
@property (weak, nonatomic) UIView *PlayerView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.url = [NSURL URLWithString:@"http://live.hkstv.hk.lxdns.com/live/hks/playlist.m3u8"];
 
    NSString * homePath = NSHomeDirectory();
    NSArray * paths =  NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSAllDomainsMask, YES);
    NSString * path=[NSString stringWithFormat:@"%@/1.MP4",paths[0]];
    self.url =[NSURL fileURLWithPath:path];
    NSLog(@"url:%@",paths[0]);
    _player = [[IJKFFMoviePlayerController alloc] initWithContentURL:self.url withOptions:nil];
    
    UIView *playerView = [self.player view];
    
    UIView *displayView = [[UIView alloc] initWithFrame:CGRectMake(0, 50, self.view.bounds.size.width, 180)];
    self.PlayerView = displayView;
    self.PlayerView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.PlayerView];
    
    playerView.frame = self.PlayerView.bounds;
    playerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self.PlayerView insertSubview:playerView atIndex:1];
    [_player setScalingMode:IJKMPMovieScalingModeAspectFill];
    [self installMovieNotificationObservers];
    
    UIButton * btn=[UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(50, 300, self.view.bounds.size.width - 100, 40);
    [btn setTitle:@"pause" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    btn .clipsToBounds = YES;
    btn.layer.cornerRadius = 3;
    btn.layer.borderColor = [UIColor blueColor].CGColor;
    btn.layer.borderWidth = 1;
    [self.view  addSubview:btn];
    
    [btn addTarget:self action:@selector(chagneStatus:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)chagneStatus:(UIButton *)sender{
    if ([self.player isPlaying]) {
        [self.player pause];
        [sender setTitle:@"play" forState:UIControlStateNormal];

    } else {
         [self.player prepareToPlay];
        [self.player play];
        [sender setTitle:@"pause" forState:UIControlStateNormal];
    }
}
-(void)viewWillAppear:(BOOL)animated{
    if (![self.player isPlaying]) {
        [self.player prepareToPlay];
    }
}
#pragma Selector func
- (void)loadStateDidChange:(NSNotification*)notification {
    IJKMPMovieLoadState loadState = _player.loadState;
    
    if ((loadState & IJKMPMovieLoadStatePlaythroughOK) != 0) {
        NSLog(@"LoadStateDidChange: IJKMovieLoadStatePlayThroughOK: %d\n",(int)loadState);
    }else if ((loadState & IJKMPMovieLoadStateStalled) != 0) {
        NSLog(@"loadStateDidChange: IJKMPMovieLoadStateStalled: %d\n", (int)loadState);
    } else {
        NSLog(@"loadStateDidChange: ???: %d\n", (int)loadState);
    }
}
- (void)moviePlayBackFinish:(NSNotification*)notification {
    int reason =[[[notification userInfo] valueForKey:IJKMPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
    switch (reason) {
        case IJKMPMovieFinishReasonPlaybackEnded:
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonPlaybackEnded: %d\n", reason);
            break;
            
        case IJKMPMovieFinishReasonUserExited:
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonUserExited: %d\n", reason);
            break;
            
        case IJKMPMovieFinishReasonPlaybackError:
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonPlaybackError: %d\n", reason);
            break;
            
        default:
            NSLog(@"playbackPlayBackDidFinish: ???: %d\n", reason);
            break;
    }
}
- (void)mediaIsPreparedToPlayDidChange:(NSNotification*)notification {
    NSLog(@"mediaIsPrepareToPlayDidChange\n");
}
- (void)moviePlayBackStateDidChange:(NSNotification*)notification {
    switch (_player.playbackState) {
        case IJKMPMoviePlaybackStateStopped:
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: stoped", (int)_player.playbackState);
            break;
            
        case IJKMPMoviePlaybackStatePlaying:
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: playing", (int)_player.playbackState);
            break;
            
        case IJKMPMoviePlaybackStatePaused:
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: paused", (int)_player.playbackState);
            break;
            
        case IJKMPMoviePlaybackStateInterrupted:
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: interrupted", (int)_player.playbackState);
            break;
            
        case IJKMPMoviePlaybackStateSeekingForward:
        case IJKMPMoviePlaybackStateSeekingBackward: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: seeking", (int)_player.playbackState);
            break;
        }
            
        default: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: unknown", (int)_player.playbackState);
            break;
        }
    }
}
#pragma Install Notifiacation
- (void)installMovieNotificationObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadStateDidChange:)
                                                 name:IJKMPMoviePlayerLoadStateDidChangeNotification
                                               object:_player];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackFinish:)
                                                 name:IJKMPMoviePlayerPlaybackDidFinishNotification
                                               object:_player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mediaIsPreparedToPlayDidChange:)
                                                 name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification
                                               object:_player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackStateDidChange:)
                                                 name:IJKMPMoviePlayerPlaybackStateDidChangeNotification
                                               object:_player];
    
}
- (void)removeMovieNotificationObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:IJKMPMoviePlayerLoadStateDidChangeNotification
                                                  object:_player];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:IJKMPMoviePlayerPlaybackDidFinishNotification
                                                  object:_player];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification
                                                  object:_player];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:IJKMPMoviePlayerPlaybackStateDidChangeNotification
                                                  object:_player];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)play_btn:(id)sender {
    if (![self.player isPlaying]) {
        [self.player play];
    }else{
        [self.player pause];
    }
}


@end
