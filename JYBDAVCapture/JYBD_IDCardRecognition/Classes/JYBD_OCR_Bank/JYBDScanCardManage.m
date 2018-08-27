//
//  JYBDScanCardManage.m
//  JYBDAVCapture
//
//  Created by tianxiuping on 2018/7/26.
//  Copyright © 2018年 XP. All rights reserved.
//

#import "JYBDScanCardManage.h"
#import "IDCardRectManager.h"
#import "UIImage+IDCardExtend.h"
#import "exbankcard.h"
#import "excards.h"
#import "commondef.h"
#import "exbankcardcore.h"
#import "JYBDBankCardSearch.h"
#import "JYBDBankCardInfo.h"
#import "JYBDCardIDInfo.h"
@interface JYBDScanCardManage ()

@end

@implementation JYBDScanCardManage

- (BOOL)configBankScanManager {
    self.scanType = JYBDBankScanType;
    return [self configSession];
}

- (BOOL)configIDScanManager {
    [self configIDScan];
    self.verify = YES;
    self.scanType = JYBDIDScanType;
    return [self configSession];
}

- (BOOL)configSession
{
    [self resetConfig];
    dispatch_queue_t captureQueue = dispatch_queue_create("www.captureQue.com", NULL);
    self.captureSession.sessionPreset = AVCaptureSessionPreset1280x720;
    
    if (![self configInPutAtQue:captureQueue] || ![self configOutPutAtQue:captureQueue]) {
        return NO;
    }
    [self configConnection];
    
    AVCaptureDevice *device = [self activeCamera];
    
    if(YES == [device lockForConfiguration:NULL]) {
        
        if([device respondsToSelector:@selector(setSmoothAutoFocusEnabled:)] && [device isSmoothAutoFocusSupported]) {
            [device setSmoothAutoFocusEnabled:YES];
        }
        AVCaptureFocusMode currentMode = [device focusMode];
        if(currentMode == AVCaptureFocusModeLocked) {
            
            currentMode = AVCaptureFocusModeAutoFocus;
        }
        if([device isFocusModeSupported:currentMode]) {
            
            [device setFocusMode:currentMode];
        }
        [device unlockForConfiguration];
    }
    [self.captureSession commitConfiguration];
    
    return YES;
}

- (void)doRec:(CVImageBufferRef)imageBuffer {
    @synchronized(self) {
        self.isInProcessing = YES;
        if (self.isHasResult) {
            return;
        }
        CVBufferRetain(imageBuffer);
        if(CVPixelBufferLockBaseAddress(imageBuffer, 0) == kCVReturnSuccess) {
            switch (self.scanType) {
                case JYBDIDScanType: {
                    [self parseIDScanImageBuffer:imageBuffer];
                }
                    break;
                    
                case JYBDBankScanType: {
                    [self parseBankImageBuffer:imageBuffer];
                }
                    break;
                default:
                    break;
            }
        }
        CVBufferRelease(imageBuffer);
    }
}


- (void)startSession {
    if (![self.captureSession isRunning]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.captureSession startRunning];
        });
    }
}

- (void)stopSession {
    if ([self.captureSession isRunning]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.captureSession stopRunning];
        });
    }
}

- (void)resetConfig {
    self.isInProcessing = NO;
    self.isHasResult = NO;
}

- (void)resetParams {
    self.isInProcessing = NO;
    self.isHasResult = NO;
    if ([self.captureSession canAddOutput:self.videoDataOutput]) {
        [self.captureSession addOutput:self.videoDataOutput];
        NSLog(@"captureSession addOutput");
    }
}

- (void)doSomethingWhenWillDisappear {
    if ([self.captureSession isRunning]) {
        [self stopSession];
        [self resetParams];
    }
}

- (void)doSomethingWhenWillAppear {
    if (![self.captureSession isRunning]) {
        [self startSession];
        [self resetParams];
    }
}

#pragma mark--扫描身份证--
- (void)parseIDScanImageBuffer:(CVImageBufferRef)imageBuffer
{
    size_t width_t= CVPixelBufferGetWidth(imageBuffer);
    size_t height_t = CVPixelBufferGetHeight(imageBuffer);
    CVPlanarPixelBufferInfo_YCbCrBiPlanar *planar = CVPixelBufferGetBaseAddress(imageBuffer);
    size_t offset = NSSwapBigIntToHost(planar->componentInfoY.offset);
    size_t rowBytes = NSSwapBigIntToHost(planar->componentInfoY.rowBytes);
    unsigned char* baseAddress = (unsigned char *)CVPixelBufferGetBaseAddress(imageBuffer);
    unsigned char* pixelAddress = baseAddress + offset;
    
    static unsigned char *buffer = NULL;
    if (buffer == NULL) {
        buffer = (unsigned char *)malloc(sizeof(unsigned char) * width_t * height_t);
    }
    
    memcpy(buffer, pixelAddress, sizeof(unsigned char) * width_t * height_t);
    
    unsigned char pResult[1024];
    int ret = EXCARDS_RecoIDCardData(buffer, (int)width_t, (int)height_t, (int)rowBytes, (int)8, (char*)pResult, sizeof(pResult));
    if (ret <= 0) {
        NSLog(@"ret=[%d]", ret);
    } else {
        NSLog(@"ret=[%d]", ret);
        char ctype;
        char content[256];
        int xlen;
        int i = 0;
        
        JYBDCardIDInfo *iDInfo = [[JYBDCardIDInfo alloc] init];
        
        ctype = pResult[i++];
        
        while(i < ret){
            ctype = pResult[i++];
            for(xlen = 0; i < ret; ++i){
                if(pResult[i] == ' ') { ++i; break; }
                content[xlen++] = pResult[i];
            }
            
            content[xlen] = 0;
            
            if(xlen) {
                NSStringEncoding gbkEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
                if(ctype == 0x21) {
                    iDInfo.num = [NSString stringWithCString:(char *)content encoding:gbkEncoding];
                } else if(ctype == 0x22) {
                    iDInfo.name = [NSString stringWithCString:(char *)content encoding:gbkEncoding];
                } else if(ctype == 0x23) {
                    iDInfo.gender = [NSString stringWithCString:(char *)content encoding:gbkEncoding];
                } else if(ctype == 0x24) {
                    iDInfo.nation = [NSString stringWithCString:(char *)content encoding:gbkEncoding];
                } else if(ctype == 0x25) {
                    iDInfo.address = [NSString stringWithCString:(char *)content encoding:gbkEncoding];
                } else if(ctype == 0x26) {
                    iDInfo.issue = [NSString stringWithCString:(char *)content encoding:gbkEncoding];
                } else if(ctype == 0x27) {
                    iDInfo.valid = [NSString stringWithCString:(char *)content encoding:gbkEncoding];
                }
            }
        }
        
        if (iDInfo)
        {// 读取到身份证信息，实例化出IDInfo对象后，截取身份证的有效区域，获取到图像
            NSLog(@"\n正面\n姓名：%@\n性别：%@\n民族：%@\n住址：%@\n公民身份证号码：%@\n\n反面\n签发机关：%@\n有效期限：%@",iDInfo.name,iDInfo.gender,iDInfo.nation,iDInfo.address,iDInfo.num,iDInfo.issue,iDInfo.valid);
            
            self.isHasResult = YES;
            if ([self.captureSession isRunning]) {
                [self.captureSession stopRunning];
            }
            UIImage *image = [UIImage getImageStream:imageBuffer];
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //  [self.bankScanSuccess sendNext:model];
                if (self.finish)
                {
                    self.finish(iDInfo, image);
                }
            });
        }
    }
    
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    self.isInProcessing = NO;
}

#pragma mark--扫描银行卡--
- (void)parseBankImageBuffer:(CVImageBufferRef)imageBuffer {
    size_t width_t= CVPixelBufferGetWidth(imageBuffer);
    size_t height_t = CVPixelBufferGetHeight(imageBuffer);
    CVPlanarPixelBufferInfo_YCbCrBiPlanar *planar = CVPixelBufferGetBaseAddress(imageBuffer);
    size_t offset = NSSwapBigIntToHost(planar->componentInfoY.offset);

    unsigned char* baseAddress = (unsigned char *)CVPixelBufferGetBaseAddress(imageBuffer);
    unsigned char* pixelAddress = baseAddress + offset;

    size_t cbCrOffset = NSSwapBigIntToHost(planar->componentInfoCbCr.offset);
    uint8_t *cbCrBuffer = baseAddress + cbCrOffset;

    CGSize size = CGSizeMake(width_t, height_t);
    CGRect effectRect = [IDCardRectManager getEffectImageRect:size];
    CGRect rect = [IDCardRectManager getGuideFrame:effectRect];

    int width = ceilf(width_t);
    int height = ceilf(height_t);

    unsigned char result [512];
    int resultLen = BankCardNV12(result, 512, pixelAddress, cbCrBuffer, width, height, rect.origin.x, rect.origin.y, rect.origin.x+rect.size.width, rect.origin.y+rect.size.height);

    if(resultLen > 0) {

        int charCount = [IDCardRectManager docode:result len:resultLen];
        if(charCount > 0) {
         //   CGRect subRect = [IDCardRectManager getCorpCardRect:width height:height guideRect:rect charCount:charCount];
        
            self.isHasResult = YES;
            if ([self.captureSession isRunning]) {
                [self.captureSession stopRunning];
            }
            UIImage *image = [UIImage getImageStream:imageBuffer];
           // __block UIImage *subImg = [UIImage getSubImage:subRect inImage:image];

            char *numbers = [IDCardRectManager getNumbers];

            NSString *numberStr = [NSString stringWithCString:numbers encoding:NSASCIIStringEncoding];
            NSString *bank = [JYBDBankCardSearch getBankNameByBin:numbers count:charCount];

             NSLog(@"\n卡号%@\n银行类型%@",numberStr,bank);

            JYBDBankCardInfo *model = [JYBDBankCardInfo new];

            model.bankNumber = numberStr;
            model.bankName = bank;
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            dispatch_async(dispatch_get_main_queue(), ^{
            
                if (self.finish)
                {
                    self.finish(model, image);
                }
            });
        }
    }
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    self.isInProcessing = NO;
}

//选择前置和后置
- (BOOL)switchCameras {
    if (![self canSwitchCameras]) {
        return NO;
    }
    NSError *error;
    AVCaptureDevice *videoDevice = [self inactiveCamera];
    
    AVCaptureDeviceInput *videoInput =
    [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
    
    if (videoInput) {
        [self.captureSession beginConfiguration];
        
        [self.captureSession removeInput:self.activeVideoInput];
        
        if ([self.captureSession canAddInput:videoInput]) {
            [self.captureSession addInput:videoInput];
            self.activeVideoInput = videoInput;
        }
        else {
            [self.captureSession addInput:self.activeVideoInput];
        }
        
        [self.captureSession commitConfiguration];
    }
    else {
       // [self.scanError sendNext:error];
        return NO;
    }
    return YES;
}

- (void)setFlashMode:(AVCaptureFlashMode)flashMode {
    AVCaptureDevice *device = [self activeCamera];
    
    if (device.flashMode != flashMode &&
        [device isFlashModeSupported:flashMode]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            device.flashMode = flashMode;
            [device unlockForConfiguration];
        }
        else {
          //  错误
        }
    }
}

- (void)setTorchMode:(AVCaptureTorchMode)torchMode {
    AVCaptureDevice *device = [self activeCamera];
    
    if (device.torchMode != torchMode &&
        [device isTorchModeSupported:torchMode]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            device.torchMode = torchMode;
            [device unlockForConfiguration];
        }
        else {
           
          //  错误
        }
    }
}

- (void)focusAtPoint:(CGPoint)point {
    AVCaptureDevice *device = [self activeCamera];
    
    if (device.isFocusPointOfInterestSupported &&
        [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            device.focusPointOfInterest = point;
            device.focusMode = AVCaptureFocusModeAutoFocus;
            [device unlockForConfiguration];
        }
        else {
         //  错误
        }
    }
}

static const NSString *THCameraAdjustingExposureContext;

- (void)exposeAtPoint:(CGPoint)point {
    AVCaptureDevice *device = [self activeCamera];
    
    AVCaptureExposureMode exposureMode =
    AVCaptureExposureModeContinuousAutoExposure;
    
    if (device.isExposurePointOfInterestSupported &&
        [device isExposureModeSupported:exposureMode]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            device.exposurePointOfInterest = point;
            device.exposureMode = exposureMode;
            
            if ([device isExposureModeSupported:AVCaptureExposureModeLocked]) {
                [device addObserver:self
                         forKeyPath:@"adjustingExposure"
                            options:NSKeyValueObservingOptionNew
                            context:&THCameraAdjustingExposureContext];
            }
            [device unlockForConfiguration];
        }
        else {
           //  错误
        }
    }
}
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if (context == &THCameraAdjustingExposureContext) {
        AVCaptureDevice *device = (AVCaptureDevice *)object;
        
        if (!device.isAdjustingExposure &&
            [device isExposureModeSupported:AVCaptureExposureModeLocked]) {
            [object removeObserver:self
                        forKeyPath:@"adjustingExposure"
                           context:&THCameraAdjustingExposureContext];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError *error;
                if ([device lockForConfiguration:&error]) {
                    device.exposureMode = AVCaptureExposureModeLocked;
                    [device unlockForConfiguration];
                } else {
                   //  错误
                }
            });
        }
    }
    else {
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
    }
}

//重置曝光
- (void)resetFocusAndExposureModes {
    AVCaptureDevice *device = [self activeCamera];
    
    AVCaptureExposureMode exposureMode =
    AVCaptureExposureModeContinuousAutoExposure;
    
    AVCaptureFocusMode focusMode = AVCaptureFocusModeContinuousAutoFocus;
    
    BOOL canResetFocus = [device isFocusPointOfInterestSupported] &&
    [device isFocusModeSupported:focusMode];
    
    BOOL canResetExposure = [device isExposurePointOfInterestSupported] &&
    [device isExposureModeSupported:exposureMode];
    
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
    } else {
       //  错误
    }
}

static bool initFlag = NO;
- (void)configIDScan {
    if (!initFlag) {
        const char *thePath = [[[NSBundle mainBundle] resourcePath] UTF8String];
        int ret = EXCARDS_Init(thePath);
        if (ret != 0) {
            NSLog(@"初始化失败：ret=%d", ret);
        }
        initFlag = YES;
    }
}

- (BOOL)configOutPutAtQue:(dispatch_queue_t)queue
{
    [self.videoDataOutput setSampleBufferDelegate:self queue:queue];
    if ([self.captureSession canAddOutput:self.videoDataOutput]) {
        [self.captureSession addOutput:self.videoDataOutput];
    } else {
        return NO;
    }
    return YES;
}

- (BOOL)configInPutAtQue:(dispatch_queue_t)queue {
    NSError *error;
    AVCaptureDevice *videoDevice =
    [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *videoInput =
    [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
    if (videoInput) {
        if ([self.captureSession canAddInput:videoInput]) {
            [self.captureSession addInput:videoInput];
            self.activeVideoInput = videoInput;
        }
    } else {
        return NO;
    }
    if (error && error.description) {
        NSLog(@"%@", error.description);
        return NO;
    }
    return YES;
}

- (void)configConnection {
    AVCaptureConnection *videoConnection;
    for (AVCaptureConnection *connection in [self.videoDataOutput connections]) {
        for (AVCaptureInputPort *port in[connection inputPorts]) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo]) {
                videoConnection = connection;
            }
        }
    }
    if ([videoConnection isVideoStabilizationSupported]) {
        if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) {
            videoConnection.enablesVideoStabilizationWhenAvailable = YES;
        }
        else {
            videoConnection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
        }
    }
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
   // CVPixelBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    if ([captureOutput isEqual:self.videoDataOutput]) {
        if(self.isInProcessing == NO)
        {
            [self doRec:imageBuffer];
        }
    }
}


@end
