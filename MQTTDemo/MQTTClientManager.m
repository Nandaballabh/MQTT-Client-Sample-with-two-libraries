//
//  MQTTClientManager.m
//  MQTTDemo
//
//  Created by Nanda Ballabh on 4/17/15.
//  Copyright (c) 2015 Nanda Ballabh. All rights reserved.
//

#import "MQTTClientManager.h"

// Connect Callbacks
@interface ConnectCallbacks : NSObject <InvocationComplete>

- (void) onSuccess:(NSObject*) invocationContext;
- (void) onFailure:(NSObject*) invocationContext errorCode:(int) errorCode errorMessage:(NSString*) errorMessage;
@end

@implementation ConnectCallbacks

- (void) onSuccess:(NSObject*) invocationContext
{
    NSLog(@"%s:%d - invocationContext=%@", __func__, __LINE__, invocationContext);
    MQTTClientManager * manager = (MQTTClientManager *) invocationContext;
    [[MQTTClientManager mqttManager]saveToDefault:[NSString stringWithFormat:@"Connection success:%@",manager.clientID]];
    NSLog(@"%s:%d - invocationContext=%@", __func__, __LINE__, invocationContext);

    // After connecting subscribe to topic
    dispatch_async(dispatch_get_main_queue(), ^{
        [[MQTTClientManager mqttManager] subscribe:kTopic qos:0];

    });

}

- (void) onFailure:(NSObject*) invocationContext errorCode:(int) errorCode errorMessage:(NSString*) errorMessage
{
    NSLog(@"%s:%d - invocationContext=%@  errorCode=%d  errorMessage=%@", __func__,
          __LINE__, invocationContext, errorCode, errorMessage);
}

@end


// Publish Callbacks
@interface PublishCallbacks : NSObject <InvocationComplete>
- (void) onSuccess:(NSObject*) invocationContext;
- (void) onFailure:(NSObject*) invocationContext errorCode:(int) errorCode errorMessage:(NSString *)errorMessage;
@end
@implementation PublishCallbacks
- (void) onSuccess:(NSObject *) invocationContext
{
    NSLog(@"PublishCallbacks - onSuccess");
    
}
- (void) onFailure:(NSObject *) invocationContext errorCode:(int) errorCode errorMessage:(NSString *)errorMessage
{
    NSLog(@"PublishCallbacks - onFailure");
}
@end


// Subscribe Callbacks
@interface SubscribeCallbacks : NSObject <InvocationComplete>

- (void) onSuccess:(NSObject*) invocationContext;
- (void) onFailure:(NSObject*) invocationContext errorCode:(int) errorCode errorMessage:(NSString*) errorMessage;
@end

@implementation SubscribeCallbacks

- (void) onSuccess:(NSObject*) invocationContext
{
    NSLog(@"SubscribeCallbacks - onSuccess");
    NSString *topic = (NSString *)invocationContext;
    NSLog(@"SubscribeCallbacks - onSuccess:%@",topic);
    [[MQTTClientManager mqttManager]saveToDefault:[NSString stringWithFormat:@"SubscribeCallbacks - onSuccess:%@",topic]];

}

- (void) onFailure:(NSObject*) invocationContext errorCode:(int) errorCode errorMessage:(NSString*) errorMessage
{
    NSLog(@"SubscribeCallbacks - onFailure");
    [[MQTTClientManager mqttManager]saveToDefault:[NSString stringWithFormat:@"SubscribeCallbacks - onFailure"]];

}

@end


// Unsubscribe Callbacks
@interface UnsubscribeCallbacks : NSObject <InvocationComplete>

- (void) onSuccess:(NSObject*) invocationContext;
- (void) onFailure:(NSObject*) invocationContext errorCode:(int) errorCode errorMessage:(NSString*) errorMessage;
@end

@implementation UnsubscribeCallbacks

- (void) onSuccess:(NSObject*) invocationContext
{
    NSLog(@"%s:%d - invocationContext=%@", __func__, __LINE__, invocationContext);
}

- (void) onFailure:(NSObject*) invocationContext errorCode:(int) errorCode errorMessage:(NSString*) errorMessage
{
    NSLog(@"%s:%d - invocationContext=%@  errorCode=%d  errorMessage=%@", __func__, __LINE__, invocationContext, errorCode, errorMessage);
}

@end


@interface GeneralCallbacks : NSObject <MqttCallbacks>

- (void) onConnectionLost:(NSObject*)invocationContext errorMessage:(NSString*)errorMessage;

- (void) onMessageArrived:(NSObject*)invocationContext message:(MqttMessage*)msg;

- (void) onMessageDelivered:(NSObject*)invocationContext messageId:(int)msgId;

@end

@implementation GeneralCallbacks

- (void) onConnectionLost:(NSObject*)invocationContext errorMessage:(NSString*)errorMessage
{
}

- (void) onMessageArrived:(NSObject*)invocationContext message:(MqttMessage*)msg
{
    NSString *payload = [[NSString alloc] initWithBytes:msg.payload length:msg.payloadLength encoding:NSASCIIStringEncoding];
    NSLog(@"GeneralCallbacks - onMessageArrived!: %@",payload);
    [[MQTTClientManager mqttManager] saveToDefault:payload];
    [[AppDelegate sharedInstance] raiseLocalNotification:payload];

}

- (void) onMessageDelivered:(NSObject*)invocationContext messageId:(int)msgId
{
    NSLog(@"GeneralCallbacks - onMessageDelivered!");
}

@end



@implementation MQTTClientManager

static id _instance = nil;

+(instancetype) mqttManager {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc]init];
    });
    return _instance;
    
}

- (id)init {
    if (self = [super init]) {
        self.client = [MqttClient alloc];
        self.clientID = nil;
        self.client.callbacks = [[GeneralCallbacks alloc] init];
        self.logMessages = [[NSMutableArray alloc] init];
        self.subscriptionData = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)connectWithHost:(NSString *)host port:(NSString *)port clientId:(NSString *)clientId
{
    
    self.client = [self.client initWithHost:host port:port.intValue clientId:clientId];
    ConnectOptions *opts = [[ConnectOptions alloc] init];
    opts.timeout = 3600;
    opts.cleanSession = NO;
    opts.keepAliveInterval = 30;
    NSLog(@"%s:%d host=%@, port=%@, clientId=%@", __func__, __LINE__, host, port, self.client);
    [self.client connectWithOptions:opts invocationContext:self onCompletion:[[ConnectCallbacks alloc] init]];
}

- (void)disconnectWithTimeout:(int)timeout {
    DisconnectOptions *opts = [[DisconnectOptions alloc] init];
    [opts setTimeout:timeout];
    
    [[self subscriptionData] removeAllObjects];
    [self.client disconnectWithOptions:opts invocationContext:self onCompletion:[[ConnectCallbacks alloc] init]];
}

- (void)publish:(NSString *)topic payload:(NSString *)payload qos:(int)qos retained:(BOOL)retained
{
    NSString *retainedStr = retained ? @" [retained]" : @"";
    NSString *logStr = [NSString stringWithFormat:@"[%@] %@%@", topic, payload, retainedStr];
    NSLog(@"%s:%d - %@", __func__, __LINE__, logStr);
    
    MqttMessage *msg = [[MqttMessage alloc] initWithMqttMessage:topic payload:(char*)[payload UTF8String] length:(int)payload.length qos:qos retained:retained duplicate:NO];
    [self.client send:msg invocationContext:self onCompletion:[[PublishCallbacks alloc] init]];
}

- (void)subscribe:(NSString *)topicFilter qos:(int)qos
{
    NSLog(@"%s:%d topicFilter=%@, qos=%d", __func__, __LINE__, topicFilter, qos);
    [self.client subscribe:topicFilter qos:qos invocationContext:topicFilter onCompletion:[[SubscribeCallbacks alloc] init]];
    
}

- (void)unsubscribe:(NSString *)topicFilter
{
    NSLog(@"%s:%d topicFilter=%@", __func__, __LINE__, topicFilter);
    [self.client unsubscribe:topicFilter invocationContext:topicFilter onCompletion:[[UnsubscribeCallbacks alloc] init]];
    
}

- (void) saveToDefault:(NSString *) message {
    
    NSString * allMessage = [[NSUserDefaults standardUserDefaults] objectForKey:@"MQTT-2message"];
    if(allMessage.length == 0)
        allMessage = message;
    else
        allMessage =[allMessage stringByAppendingString:[NSString stringWithFormat:@"\n%@",message]];
    [[NSUserDefaults standardUserDefaults] setObject:allMessage forKey:@"MQTT-2message"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
}

@end
