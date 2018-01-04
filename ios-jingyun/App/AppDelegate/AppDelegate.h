//
//  AppDelegate.h
//  ios-jingyun-test
//
//  Created by conwin on 2017/12/11.
//  Copyright © 2017年 conwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

