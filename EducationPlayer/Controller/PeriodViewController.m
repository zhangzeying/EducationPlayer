//
//  PeriodViewController.m
//  EducationPlayer
//
//  Created by zzy on 7/29/16.
//  Copyright © 2016 zzy. All rights reserved.
//

#import "PeriodViewController.h"
#import "CustomLabel.h"
#import "VideoViewController.h"
#import "CourseModel.h"

@interface PeriodViewController ()<UIScrollViewDelegate>
/** 类别数组 */
@property(nonatomic,strong)NSMutableArray *categoryArr;
/** 类别标题scrollView */
@property (nonatomic, weak)UIScrollView *categoryScrollView;
/** 类别内容scrollView */
@property (nonatomic, weak)UIScrollView *contentScrollView;
/** <##> */
@property (nonatomic, copy)NSString *gradeId;
@end

@implementation PeriodViewController

- (instancetype)initWithGradeId:(NSString *)gradeId {
    self = [super init];
    if (self) {
        
        self.gradeId = gradeId;
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.navigationItem.title = @"教育视频";
    self.view.backgroundColor = CustomColor(237, 236, 236);
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.categoryArr = [NSMutableArray arrayWithObjects:@"第一周期",@"第二周期",@"第三周期",@"第四周期",@"第五周期", nil];
    [self setupChildVC];
    [self setupCategory];
    // 默认显示第0个子控制器
    [self scrollViewDidEndScrollingAnimation:self.contentScrollView];
    NSLog(@"%@", NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES));
}

- (void)setupChildVC {
    
    for (int i = 0; i < self.categoryArr.count; i++) {
        
        VideoViewController *videoVC = [[VideoViewController alloc]init];
        
        [self addChildViewController:videoVC];
    }
}

#pragma mark --- CreateUI ---
- (void)setupCategory {
    
    //创建顶部的类别
    UIScrollView *categoryScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 64, ScreenW, 40)];
    categoryScrollView.backgroundColor = [UIColor whiteColor];
    categoryScrollView.showsVerticalScrollIndicator = NO;
    categoryScrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:categoryScrollView];
    CGFloat titleLblW = 80;
    CGFloat titleLblH = categoryScrollView.height;
    for (int i = 0; i < self.categoryArr.count; i++) {
        
        CustomLabel *titleLbl = [[CustomLabel alloc]init];
        titleLbl.textAlignment = NSTextAlignmentCenter;
        titleLbl.text = self.categoryArr[i];
        titleLbl.font = [UIFont systemFontOfSize:13];
        titleLbl.textColor = [UIColor lightGrayColor];
        titleLbl.userInteractionEnabled = YES;
        [titleLbl addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelClick:)]];
        titleLbl.tag = i;
        CGFloat titleLblX = i * titleLblW;
        titleLbl.frame = CGRectMake(titleLblX, 0, titleLblW, titleLblH);
        [categoryScrollView addSubview:titleLbl];
        if (i == 0) { // 最前面的label
            titleLbl.scale = 1.0;
        }
    }
    categoryScrollView.contentSize = CGSizeMake(self.categoryArr.count * titleLblW, 0);
    self.categoryScrollView = categoryScrollView;
    
    //创建顶部的类别内容
    CGFloat contentScrollViewY = CGRectGetMaxY(categoryScrollView.frame) + 10;
    UIScrollView *contentScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, contentScrollViewY, ScreenW, ScreenH - contentScrollViewY)];
    contentScrollView.backgroundColor = [UIColor clearColor];
    contentScrollView.showsVerticalScrollIndicator = NO;
    contentScrollView.showsHorizontalScrollIndicator = NO;
    contentScrollView.pagingEnabled = YES;
    contentScrollView.delegate = self;
    [self.view addSubview:contentScrollView];
    contentScrollView.contentSize = CGSizeMake(self.categoryArr.count * ScreenW, 0);
    self.contentScrollView = contentScrollView;
}

/**
 * 监听顶部label点击
 */
- (void)labelClick:(UITapGestureRecognizer *)tap
{
    // 取出被点击label的索引
    NSInteger index = tap.view.tag;
    
    // 让底部的内容scrollView滚动到对应位置
    CGPoint offset = self.contentScrollView.contentOffset;
    offset.x = index * self.contentScrollView.frame.size.width;
    [self.contentScrollView setContentOffset:offset animated:YES];
}

#pragma mark --- UIScrollViewDelegate ---
/**
 * scrollView结束了滚动动画以后就会调用这个方法（比如- (void)setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated;方法执行的动画完毕后）
 */
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    
    // 一些临时变量
    CGFloat width = scrollView.frame.size.width;
    CGFloat height = scrollView.frame.size.height;
    CGFloat offsetX = scrollView.contentOffset.x;
    
    // 当前位置需要显示的控制器的索引
    NSInteger index = offsetX / width;
    
    // 让对应的顶部标题居中显示
    CustomLabel *label = self.categoryScrollView.subviews[index];
    CGPoint titleOffset = self.categoryScrollView.contentOffset;
    titleOffset.x = label.center.x - width * 0.5;
    // 左边超出处理
    if (titleOffset.x < 0) titleOffset.x = 0;
    // 右边超出处理
    CGFloat maxTitleOffsetX = self.categoryScrollView.contentSize.width - width;
    if (titleOffset.x > maxTitleOffsetX) titleOffset.x = maxTitleOffsetX;
    
    [self.categoryScrollView setContentOffset:titleOffset animated:YES];
    
    // 让其他label回到最初的状态
    for (CustomLabel *otherLabel in self.categoryScrollView.subviews) {
        if (otherLabel != label) otherLabel.scale = 0.0;
    }
    
    
    // 取出需要显示的控制器
    VideoViewController *willShowVc = self.childViewControllers[index];
    
    CustomLabel *titleLbl = self.categoryScrollView.subviews[index];
    
    // 如果当前位置的位置已经显示过了，就直接返回
    if ([willShowVc isViewLoaded]) return;
    
    // 添加控制器的view到contentScrollView中;
    willShowVc.view.frame = CGRectMake(offsetX, 0, width, height);
    [scrollView addSubview:willShowVc.view];
    BmobQuery *query = [BmobQuery queryWithClassName:@"CourseBean"];
    
    BmobObject *grade = [BmobObject objectWithoutDataWithClassName:@"GradeBean" objectId:self.gradeId];
    [query whereKey:@"gradeBean" equalTo:grade];
    [query whereKey:@"round" equalTo:titleLbl.text];
    [query orderByAscending:@"index"];
    [SVProgressHUD showWithStatus:@"加载中..."];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        [SVProgressHUD dismiss];
        if (error) {
            NSLog(@"%@",error);
        } else if (array){
            NSMutableArray *courseArr = [NSMutableArray array];
            for (BmobObject *obj in array) {
                
                CourseModel *model = [[CourseModel alloc]init];
                model.objectId = [obj objectForKey:@"objectId"];
                model.type = [[obj objectForKey:@"type"] integerValue];
                model.round = [obj objectForKey:@"round"];
                model.courseName = [obj objectForKey:@"courseName"];
                model.uri = [obj objectForKey:@"uri"];
                model.gradeModel = [obj objectForKey:@"gradeModel"];
                model.index = [[obj objectForKey:@"index"] integerValue];
                [courseArr addObject:model];
             }
            
            willShowVc.dataArr = courseArr;
        }
    }];
}

/**
 * 手指松开scrollView后，scrollView停止减速完毕就会调用这个
 */
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    [self scrollViewDidEndScrollingAnimation:scrollView];
}

/**
 * 只要scrollView在滚动，就会调用
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat scale = scrollView.contentOffset.x / scrollView.frame.size.width;
    if (scale < 0 || scale > self.categoryScrollView.subviews.count - 1) return;
    
    // 获得需要操作的左边label
    NSInteger leftIndex = scale;
    CustomLabel *leftLabel = self.categoryScrollView.subviews[leftIndex];
    
    // 获得需要操作的右边label
    NSInteger rightIndex = leftIndex + 1;
    CustomLabel *rightLabel = (rightIndex == self.categoryScrollView.subviews.count) ? nil : self.categoryScrollView.subviews[rightIndex];
    
    // 右边比例
    CGFloat rightScale = scale - leftIndex;
    // 左边比例
    CGFloat leftScale = 1 - rightScale;
    
    // 设置label的比例
    leftLabel.scale = leftScale;
    rightLabel.scale = rightScale;
}

- (BOOL)shouldAutorotate {
    
    return NO;
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}


@end
