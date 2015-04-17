//
//  AppDelegate.h
//  MQTTDemo
//
//  Created by Nanda Ballabh on 4/15/15.
//  Copyright (c) 2015 Nanda Ballabh. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kMQTTServerHost @"broker.mqtt-dashboard.com" // This is public broker url you can replace by your server url
#define kMQTTServerPort @"1883" // Port number
#define kTopic @"BK_Test" // This is your topic

//http://www.mqtt-dashboard.com/dashboard# You can use this public MQTT broker to test your app
// You can create topic here and publish then

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;


- (void)raiseLocalNotification:(NSString *) message;
+ (instancetype) sharedInstance ;
@end

