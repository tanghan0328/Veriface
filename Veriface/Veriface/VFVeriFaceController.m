//
//  VFVeriFaceController.m
//  Veriface
//
//  Created by tang tang on 2017/11/24.
//  Copyright © 2017年 tang tang. All rights reserved.
//

#import "VFVeriFaceController.h"
#import "VFEmployeeViewController.h"
#import "NSDate+VFDate.h"
#import "NSTimer+VFUsingTimer.h"
#import "UIImage+Crop.h"

@interface VFVeriFaceController ()<UIGestureRecognizerDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property (nonatomic, strong) AVCaptureSession* session;
@property (nonatomic, strong) AVCaptureDeviceInput* videoInput;
@property (nonatomic, strong) AVCaptureStillImageOutput* stillImageOutput;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer* previewLayer;
@property (nonatomic, assign) CGFloat beginGestureScale;
@property (nonatomic, assign) CGFloat effectiveScale;
@property (nonatomic, strong) AVCaptureConnection *stillImageConnection;
@property (nonatomic, strong) NSData  *jpegData;
@property (nonatomic, assign) CFDictionaryRef attachments;
@property (nonatomic, strong) UIView *toolView;
@property (nonatomic, strong) UIView *editorView;
@property (nonatomic, strong) UIImagePickerController *imgPicker;
@property (nonatomic, strong) UILabel *noteLabel;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *titleLable;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) UIBarButtonItem *leftItem;
@property (nonatomic, strong) UIBarButtonItem *rightItem;

@end

@implementation VFVeriFaceController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:19],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithWhite:0 alpha:0.8]] forBarMetrics:UIBarMetricsDefault];
    _leftItem =[[UIBarButtonItem alloc]initWithTitle:[NSDate nowdateToString] style:UIBarButtonItemStylePlain target:self action:nil];
    self.navigationItem.leftBarButtonItem = _leftItem;
    _rightItem =  [[UIBarButtonItem alloc]initWithTitle:@"图像录入" style:UIBarButtonItemStylePlain target:self action:@selector(imagePoint)];
    self.navigationItem.rightBarButtonItem = _rightItem;
    
    [_leftItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateNormal];
    [_rightItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateNormal];

    [self initHeader];
    [self initAVCaptureSession];
    [self createdTool];
    
    __weak typeof(self) weakSelf = self;
    _timer = [NSTimer tw_scheduledTimerWithTimeInterval:1.0 block:^{
        __strong typeof(self) strongSelf = weakSelf;
        strongSelf.navigationItem.title = [NSDate nowdateHHToString];
        strongSelf.leftItem.title = [NSDate nowdateToString];
    } repeats:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.title = [NSDate nowdateToString];
    if (self.session) {
        [self.session startRunning];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:YES];
    if (self.session) {
        [self.session stopRunning];
    }
}
//创建头部信息
- (void)initHeader
{
    self.noteLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    self.noteLabel.backgroundColor = [UIColor colorWithRed:57.0f/255.0f green:133.0f/255.0f blue:201.0f/255.0f alpha:1];
    self.noteLabel.text = @"您好，请目视前方";
    self.noteLabel.textAlignment = NSTextAlignmentCenter;
    self.noteLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:self.noteLabel];
    
    [self.noteLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.view).with.offset(64);
        make.height.mas_equalTo(50);
    }];
}
//创建下部拍照
- (void)createdTool
{
    self.toolView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 120, SCREEN_WIDTH, 120)];
    self.toolView.backgroundColor = [UIColor blackColor];
    self.toolView.alpha = 0.8;
    [self.view addSubview:self.toolView];
    
    UIButton *cameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cameraBtn.frame = CGRectMake((SCREEN_WIDTH - 50)/2.0, (120 - 50)/ 2.0, 50, 50);
    [cameraBtn setImage:[UIImage imageNamed:@"takePhoto"] forState:UIControlStateNormal];
    [cameraBtn addTarget:self action:@selector(takePhotoButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.toolView addSubview:cameraBtn];
    //没有闪光灯
//    UIButton *lampBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    lampBtn.frame = CGRectMake(((SCREEN_WIDTH / 2.0) - 30)/2.0 + (SCREEN_WIDTH /2.0), ((120) - 30)/ 2.0, 30, 30);
//    [lampBtn setImage:[UIImage imageNamed:@"openFlish"] forState:UIControlStateSelected];
//    [lampBtn setImage:[UIImage imageNamed:@"closeFlish"] forState:UIControlStateNormal];
//    [lampBtn addTarget:self action:@selector(flashButtonClick:) forControlEvents:UIControlEventTouchUpInside];
//    [self.toolView addSubview:lampBtn];
}

- (void)initAVCaptureSession{
    
    self.session = [[AVCaptureSession alloc] init];
    NSError *error;
    self.effectiveScale = 1.0;
    AVCaptureDevice *device = [self cameraWithPosition:AVCaptureDevicePositionFront];
    //更改这个设置的时候必须先锁定设备，修改完后再解锁，否则崩溃
    [device lockForConfiguration:nil];
    
    [device unlockForConfiguration];
    self.videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:device error:&error];
    if (error) {
        NSLog(@"%@",error);
    }
    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    //输出设置。AVVideoCodecJPEG   输出jpeg格式图片
    NSDictionary * outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey, nil];
    [self.stillImageOutput setOutputSettings:outputSettings];
    
    if ([self.session canAddInput:self.videoInput]) {
        [self.session addInput:self.videoInput];
    }
    if ([self.session canAddOutput:self.stillImageOutput]) {
        [self.session addOutput:self.stillImageOutput];
    }
    
    //初始化预览图层
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    [self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    self.previewLayer.frame = CGRectMake(0, 114,SCREEN_WIDTH, SCREEN_HEIGHT-114);
    self.view.layer.masksToBounds = YES;
    [self.view.layer addSublayer:self.previewLayer];
    
    [self resetFocusAndExposureModes];
}

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices )
        if ( device.position == position )
            return device;
    return nil ;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//照相
- (void)takePhotoButtonClick {
    _stillImageConnection = [self.stillImageOutput  connectionWithMediaType:AVMediaTypeVideo];
    UIDeviceOrientation curDeviceOrientation = [[UIDevice currentDevice] orientation];
    AVCaptureVideoOrientation avcaptureOrientation = [self avOrientationForDeviceOrientation:curDeviceOrientation];
    [_stillImageConnection setVideoOrientation:avcaptureOrientation];
    [_stillImageConnection setVideoScaleAndCropFactor:self.effectiveScale];
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:_stillImageConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        NSData *jpegData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        //向服务器发送请求
//        [[NetManager sharedManager]requestAuthFaceWithData:jpegData complete:^(id object, NSError *error) {
//            if(error){
//                //TODO  错误显示
//            }
//        }];
        //向打卡用户确认
        [self showAlert];
    }];
}

- (void)showAlert
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提醒" message:@"工号ID10000姓名糖糖打卡成功" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *wrongAlert = [UIAlertAction actionWithTitle:@"打卡错误" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        //TODO  网络请求打卡确认
        //[self requestConfrimResult:NO];
    }];
    UIAlertAction *rightAlert = [UIAlertAction actionWithTitle:@"确认无误" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //TODO  网络请求打卡确认
        //[self requestConfrimResult:YES];
    }];
    [alert addAction:wrongAlert];
    [alert addAction:rightAlert];

    UIPopoverPresentationController *popPresenter = [alert popoverPresentationController];
    popPresenter.sourceView = self.view;
    popPresenter.sourceRect = CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, 1, 1);
    [self presentViewController:alert animated:YES completion:nil];
}
//最后请求确认打卡
- (void)requestConfrimResult:(BOOL)confrim
{
    [[NetManager sharedManager]requestAuthFaceWithResult:confrim complete:^(id object, NSError *error) {
        
    }];
}

//自动聚焦、曝光
- (BOOL)resetFocusAndExposureModes{
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureExposureMode exposureMode = AVCaptureExposureModeContinuousAutoExposure;
    AVCaptureFocusMode focusMode = AVCaptureFocusModeContinuousAutoFocus;
    BOOL canResetFocus = [device isFocusPointOfInterestSupported] && [device isFocusModeSupported:focusMode];
    BOOL canResetExposure = [device isExposurePointOfInterestSupported] && [device isExposureModeSupported:exposureMode];
    CGPoint centerPoint = CGPointMake(0.5f, 0.5f);
    NSError *error;
    if ([device lockForConfiguration:&error]) {
        if (canResetFocus) {
            device.focusMode = focusMode;
            device.focusPointOfInterest = centerPoint;
        }
        if (canResetExposure) {
            device.exposureMode = exposureMode;
            device.exposurePointOfInterest = centerPoint;
        }
        [device unlockForConfiguration];
        return YES;
    }
    else{
        NSLog(@"%@", error);
        return NO;
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = touches.anyObject;
    CGPoint point = [touch locationInView:self.view];
    [self focusAtPoint:point];
}
//聚焦
- (void)focusAtPoint:(CGPoint)point {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([self cameraSupportsTapToFocus] && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            device.focusPointOfInterest = point;
            device.focusMode = AVCaptureFocusModeAutoFocus;
            [device unlockForConfiguration];
        }else{
            NSLog(@"%@", error);
        }
    }
}

- (BOOL)cameraSupportsTapToFocus {
    return [[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo] isFocusPointOfInterestSupported];
}

//获取设备方向
-(AVCaptureVideoOrientation)avOrientationForDeviceOrientation:(UIDeviceOrientation)deviceOrientation
{
    AVCaptureVideoOrientation result = (AVCaptureVideoOrientation)deviceOrientation;
    if ( deviceOrientation == UIDeviceOrientationLandscapeLeft )
        result = AVCaptureVideoOrientationLandscapeRight;
    else if ( deviceOrientation == UIDeviceOrientationLandscapeRight )
        result = AVCaptureVideoOrientationLandscapeLeft;
    return result;
}

//打开闪光灯
- (void)flashButtonClick:(UIButton *)sender {
    
    sender.selected = !sender.selected;
    if (sender.isSelected == YES) { //打开闪光灯
        AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        NSError *error = nil;
        
        if ([captureDevice hasTorch]) {
            BOOL locked = [captureDevice lockForConfiguration:&error];
            if (locked) {
                captureDevice.torchMode = AVCaptureTorchModeOn;
                [captureDevice unlockForConfiguration];
            }
        }
    }else{//关闭闪光灯
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if ([device hasTorch]) {
            [device lockForConfiguration:nil];
            [device setTorchMode: AVCaptureTorchModeOff];
            [device unlockForConfiguration];
        }
    }
}
//添加手势代理
- (void)setUpGesture
{
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
    pinch.delegate = self;
    [self.view addGestureRecognizer:pinch];
}

//缩放手势 用于调整焦距
- (void)handlePinchGesture:(UIPinchGestureRecognizer *)recognizer{
    
    BOOL allTouchesAreOnThePreviewLayer = YES;
    NSUInteger numTouches = [recognizer numberOfTouches], i;
    for ( i = 0; i < numTouches; ++i ) {
        CGPoint location = [recognizer locationOfTouch:i inView:self.view];
        CGPoint convertedLocation = [self.previewLayer convertPoint:location fromLayer:self.previewLayer.superlayer];
        if ( ! [self.previewLayer containsPoint:convertedLocation] ) {
            allTouchesAreOnThePreviewLayer = NO;
            break;
        }
    }
    
    if ( allTouchesAreOnThePreviewLayer ) {
        self.effectiveScale = self.beginGestureScale * recognizer.scale;
        if (self.effectiveScale < 1.0){
            self.effectiveScale = 1.0;
        }
        NSLog(@"%f-------------->%f------------recognizerScale%f",self.effectiveScale,self.beginGestureScale,recognizer.scale);
        CGFloat maxScaleAndCropFactor = [[self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo] videoMaxScaleAndCropFactor];
        NSLog(@"%f",maxScaleAndCropFactor);
        if (self.effectiveScale > maxScaleAndCropFactor)
            self.effectiveScale = maxScaleAndCropFactor;
        [CATransaction begin];
        [CATransaction setAnimationDuration:.025];
        [self.previewLayer setAffineTransform:CGAffineTransformMakeScale(self.effectiveScale, self.effectiveScale)];
        [CATransaction commit];
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ( [gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]] ) {
        self.beginGestureScale = self.effectiveScale;
    }
    return YES;
}

//图像录入
- (void)imagePoint
{
    VFEmployeeViewController *front = [[VFEmployeeViewController alloc]init];
    [self.navigationController pushViewController:front animated:YES];
}

@end
