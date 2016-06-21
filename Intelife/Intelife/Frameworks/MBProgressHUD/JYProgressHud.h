//
//  JYProgressHud.h
//  JY_SmartGuard
//
//  Created by 刘斌 on 15-5-21.
//  Copyright (c) 2015年 liubin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"
#import "SynthesizeSingleton.h"

@interface JYProgressHud : NSObject <MBProgressHUDDelegate>
{
    MBProgressHUD *HUD;
}

SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(JYProgressHud);

- (void) ShowTips:(NSString*)strTips  delayTime:(NSTimeInterval)delay atView:(UIView*)pView;

- (void) showWaiting:(NSString*)strTips WhileExecuting:(SEL)method onTarget:(id)target withObject:(id)object animated:(BOOL)animated  atView:(UIView*)pView;

- (void) showProgress:(NSString*)strTips WhileExecuting:(SEL)method onTarget:(id)target withObject:(id)object animated:(BOOL)animated  atView:(UIView*)pView;

- (void) updateProgress:(float)progress;
- (void)hideCurrentHudView;
- (void)hideHudView:(MBProgressHUD *)hud;

@end
