//
//  MQTTClientManager.h
//  MQTTDemo
//
//  Created by Nanda Ballabh on 4/17/15.
//  Copyright (c) 2015 Nanda Ballabh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MqttOCClient.h"
#import "AppDelegate.h"

@interface MQTTClientManager : NSObject
@property (nonatomic, strong) MqttClient *client;
@property (nonatomic, strong) NSString *clientID;
@property NSMutableArray *logMessages;
@property NSMutableArray *subscriptionData;


+(instancetype) mqttManager;
- (void)connectWithHost:(NSString *)host port:(NSString *)port clientId:(NSString *)clientId;

- (void)publish:(NSString *)topic payload:(NSString *)payload qos:(int)qos retained:(BOOL)retained;

- (void)subscribe:(NSString *)topicFilter qos:(int)qos;

- (void)unsubscribe:(NSString *)topicFilter;

- (void)disconnectWithTimeout:(int)timeout;
- (void) saveToDefault:(NSString *) message;


@end
