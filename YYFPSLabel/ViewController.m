//
//  ViewController.m
//  RealmDemo
//
//  Created by yehot on 16/3/24.
//  Copyright © 2016年 yehot. All rights reserved.
//

#import "ViewController.h"
#import "YYFPSLabel.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) YYFPSLabel *fpsLabel;

@end

@implementation ViewController {
    CADisplayLink *_link;
    NSUInteger _count;
    NSTimeInterval _lastTime;
    
    UILabel *label_;
    UITableView *table_;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITableView *table = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    table.delegate = self;
    table.dataSource = self;
    [self.view addSubview:table];
    table_ = table;
    [table registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    
//    Demo1: FPS label 用法
    [self testFPSLabel];
    
//    Demo2: 测试在子线程使用 timer
//    [self testSubThread];

}

#pragma mark - FPS demo

- (void)testFPSLabel {
    _fpsLabel = [YYFPSLabel new];
    _fpsLabel.frame = CGRectMake(200, 200, 50, 30);
    [_fpsLabel sizeToFit];
    [self.view addSubview:_fpsLabel];
    
    // 如果直接用 self 或者 weakSelf，都不能解决循环引用问题

    // 移除也不能使 label里的 timer invalidate
    //        [_fpsLabel removeFromSuperview];
}

#pragma mark - 子线程 timer demo

- (void)testSubThread {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(200, 200, 100, 50)];
    label_ = label;
    label.backgroundColor = [UIColor grayColor];
    [table_ addSubview:label];
    
    
    // 开启子线程，新建 runloop， 避免主线程 阻塞时， timer不能用
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        _link = [CADisplayLink displayLinkWithTarget:self selector:@selector(tick:)];
        
        // NOTE: 子线程的runloop默认不创建； 在子线程获取 currentRunLoop 对象的时候，就会自动创建RunLoop
        
        // 这里不加到 main loop，必须创建一个 runloop
        NSRunLoop *runloop = [NSRunLoop currentRunLoop];
        [_link addToRunLoop:runloop forMode:NSRunLoopCommonModes];
        
        // 必须 timer addToRunLoop 后，再run
        [runloop run];
    });
    
    // 模拟 主线程阻塞 （不应该模拟主线程卡死，模拟卡顿即可）
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        NSLog(@"即将阻塞");
        dispatch_sync(dispatch_get_main_queue(), ^{
            NSLog(@"同步阻塞主线程");
        });
        NSLog(@"不会执行");
    });
}

- (void)tick:(CADisplayLink *)link {
    if (_lastTime == 0) {
        _lastTime = link.timestamp;
        return;
    }
    
    _count++;
    NSTimeInterval delta = link.timestamp - _lastTime;
    if (delta < 1) return;
    _lastTime = link.timestamp;
    float fps = _count / delta;
    _count = 0;
    
    NSString *text = [NSString stringWithFormat:@"%d FPS",(int)round(fps)];

    // 尝试1：主线程阻塞， 这里就不能获取到主线程了
//    dispatch_async(dispatch_get_main_queue(), ^{
//        //  阻塞时，想通过 在主线程更新UI 来查看是不可行了
//        label_.text = text;
//    });
    
    // 尝试2：不在主线程操作 UI ，界面会发生变化
    label_.text = text;

    NSLog(@"%@", text);
}

#pragma mark - other

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text = @"卡不卡";
    return cell;
}

@end
