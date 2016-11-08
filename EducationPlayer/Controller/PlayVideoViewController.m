//
//  PlayVideoViewController.m
//  EducationPlayer
//
//  Created by zzy on 8/7/16.
//  Copyright © 2016 zzy. All rights reserved.
//

#import "PlayVideoViewController.h"
#import "CYVideoPlayerView.h"
#import <AVFoundation/AVFoundation.h>
#import "CYFullViewController.h"

@interface PlayVideoViewController ()<CYVideoPlayerDelegate>

@property (nonatomic,strong) CYVideoPlayerView *playerView;

@property (nonatomic,strong) CYFullViewController *fullViewController;
/** <##> */
@property (nonatomic, copy)NSString *url;
/** <##> */
@property(assign,nonatomic)NSInteger playType;
@end

@implementation PlayVideoViewController

- (instancetype)initWithUrl:(NSString *)url playType:(NSInteger)playType
{
    self = [super init];
    if (self) {
        
        self.url = url;
        self.playType = playType;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playStateChange:) name:@"PlayStateChange" object:nil];
    self.playerView = [[CYVideoPlayerView alloc] init];
    self.playerView.delegate = self;
    [self.view addSubview:self.playerView];
    self.playerView.frame = CGRectMake(0, 64, ScreenW, self.view.bounds.size.width * 9 / 16);
    
    NSURL *videoURL = nil;
    if (self.playType == 0) {
        
        videoURL = [NSURL fileURLWithPath:self.url];
    }else {
    
        videoURL = [NSURL URLWithString:self.url];
    }
    // 传一个 AVPlayerItem 如果能够播放视频就会调用play方法
    [self.playerView replaceAVPlayerItem:[[AVPlayerItem alloc] initWithURL:videoURL]];
    
    self.fullViewController = [[CYFullViewController alloc] init];
    [self.fullViewController.view addSubview:self.playerView];
    
    
    [self.playerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.removeExisting = YES;
    }];
    
    [self.playerView mas_updateConstraints:^(MASConstraintMaker *make) {
        
        make.left.right.equalTo(self.fullViewController.view);
        make.top.equalTo(self.fullViewController.view).with.offset(20);
        make.bottom.equalTo(self.fullViewController.view).with.offset(-64);
    }];
    [self presentViewController:self.fullViewController animated:NO completion:nil];
    
//    UIView *backview = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenW, 64)];
//    backview.alpha = 0.5;
//    backview.backgroundColor = CustomColor(109, 109, 121);
//    [self.fullViewController.view addSubview:backview];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setImage:[UIImage imageNamed:@"nav_back_icon"] forState:UIControlStateNormal];
    backBtn.frame = CGRectMake(0, 10, 80, 60);
    [backBtn addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
    [self.fullViewController.view addSubview:backBtn];
    
    NSArray *titleArr = @[@"后退4s",@"前进",@"暂停"];
    CGFloat btnW = 100;
    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn1.frame = CGRectMake(20, self.fullViewController.view.height - 40, btnW, 40);
    [btn1 setTitle:titleArr[0] forState:UIControlStateNormal];
    btn1.backgroundColor = CustomColor(207, 209, 208);
    [btn1 setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    btn1.titleLabel.font = [UIFont systemFontOfSize:12];
    [btn1 addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    btn1.tag = 1;
    [self.fullViewController.view addSubview:btn1];
    
    UIButton *btn3 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn3.frame = CGRectMake(self.fullViewController.view.width - 10 - btnW, self.fullViewController.view.height - 40, btnW, 40);
    [btn3 setTitle:titleArr[2] forState:UIControlStateNormal];
    btn3.backgroundColor = CustomColor(207, 209, 208);
    [btn3 setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    btn3.titleLabel.font = [UIFont systemFontOfSize:12];
    [btn3 addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    btn3.tag = 3;
    [self.fullViewController.view addSubview:btn3];
    
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn2.frame = CGRectMake(CGRectGetMinX(btn3.frame) - 15 - btnW, self.fullViewController.view.height - 40, btnW, 40);
    [btn2 setTitle:titleArr[1] forState:UIControlStateNormal];
    btn2.backgroundColor = CustomColor(207, 209, 208);
    [btn2 setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    btn2.titleLabel.font = [UIFont systemFontOfSize:12];
    [btn2 addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    btn2.tag = 2;
    [self.fullViewController.view addSubview:btn2];
}
#pragma mark - CYVideoPlayerDelegate
/** <是否全屏播放视频> */
- (void)cyVideoToolBarView:(CYVideoToolBar *)cyVideoToolBar shouldFullScreen:(BOOL)isFull
{
    if (isFull) {
        self.fullViewController = [[CYFullViewController alloc] init];
        [self.fullViewController.view addSubview:self.playerView];
        
        [self.playerView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.removeExisting = YES;
        }];
        
        [self.playerView mas_updateConstraints:^(MASConstraintMaker *make) {
            
             make.left.right.top.equalTo(self.view);
             make.bottom.equalTo(self.view).with.offset(-100);
        }];
        [self presentViewController:self.fullViewController animated:NO completion:nil];
        
    }else {
        [self.fullViewController dismissViewControllerAnimated:NO completion:^{
            [self.view addSubview:self.playerView];
            self.fullViewController = nil;
            [self.playerView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.view).with.offset(64);
                make.left.right.equalTo(self.view);
                make.height.mas_equalTo(self.view.bounds.size.width * 9 / 16 - 50);
            }];
        }];
    }
}

- (void)btnClick:(UIButton *)sender {

    
    if (sender.tag == 1) {
        
        [self.playerView backPlay];
        
    }else if (sender.tag == 2) {
    
        [self.playerView goForwardPlay];
        
    }else {
    
        if (sender.selected) {
            
            [self.playerView cyVideoToolBarView:YES];
            [sender setTitle:@"暂停" forState:UIControlStateNormal];
            
        }else {
        
            [self.playerView cyVideoToolBarView:NO];
            [sender setTitle:@"开始" forState:UIControlStateNormal];
        }
        sender.selected = !sender.selected;
        
    }
}

- (void)backClick {

    [self.fullViewController dismissViewControllerAnimated:NO completion:^{
        
        [self.navigationController popViewControllerAnimated:NO];
    }];
    
}

- (void)playStateChange:(NSNotification *)sender {

    NSString *flag = sender.object;
    UIButton *btn = (UIButton *)[self.fullViewController.view viewWithTag:3];
    btn.selected = ![flag isEqualToString:@"1"];
    [self btnClick:btn];
}

- (void)viewWillDisappear:(BOOL)animated {

    [super viewWillDisappear:animated];
    [self.playerView playerEndPlay];
}


- (UIStatusBarStyle)preferredStatusBarStyle {
    
    return UIStatusBarStyleLightContent;
}


@end
