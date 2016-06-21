//
//  SceneInfoModel.h
//  JY_SmartHomeIphone
//
//  Created by 刘斌 on 14-9-17.
//  Copyright (c) 2014年 JY_SmartHome. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SceneInfoModel : NSObject
{
    int sceneID;
    int roomID;
    int imageID;
    NSString *sceneName;
}

@property (nonatomic) int sceneID;
@property (nonatomic) int roomID;
@property (nonatomic) int imageID;
@property (strong, nonatomic) NSString *sceneName;

@end
