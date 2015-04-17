//
//  MQTT1ViewController.m
//  MQTTDemo
//
//  Created by Nanda Ballabh on 4/15/15.
//  Copyright (c) 2015 Nanda Ballabh. All rights reserved.
//

#import "MQTT1ViewController.h"
#import "MQTTKit.h"

@interface MQTT1ViewController ()
@property (nonatomic, strong) MQTTClient *client;

@property (weak, nonatomic) IBOutlet UITextView *textView;
@end

@implementation MQTT1ViewController

- (void)viewDidLoad {

    [super viewDidLoad];

}


- (IBAction)connectButtonTapped:(id)sender {
    [sender setEnabled:NO];
    // create the MQTT client with an unique identifier
    NSString *clientID = [UIDevice currentDevice].identifierForVendor.UUIDString;
    self.client = [[MQTTClient alloc] initWithClientId:clientID];
    
    // define the handler that will be called when MQTT messages are received by the client
    __block __weak MQTT1ViewController * weakSelf = self;
    [self.client setMessageHandler:^(MQTTMessage *message) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSLog(@"%@",message.payloadString);
            __strong MQTT1ViewController * strongSelf = weakSelf;
            [strongSelf saveToDefault:message.payloadString];
            [[AppDelegate sharedInstance] raiseLocalNotification:message.payloadString];
        });
    }];
    
    // connect the MQTT client
    [self.client connectToHost:kMQTTServerHost completionHandler:^(MQTTConnectionReturnCode code) {
        if (code == ConnectionAccepted) {
            // The client is connected when this completion handler is called
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"client is connected with id %@", clientID);
                [self saveToDefault:[NSString stringWithFormat:@"client is connected with id %@", clientID]];
            });
            // Subscribe to the topic
            [self.client subscribe:kTopic withQos:2 completionHandler:^(NSArray *grantedQos) {
                // The client is effectively subscribed to the topic when this completion handler is called
                dispatch_async(dispatch_get_main_queue(), ^{

                    NSLog(@"subscribed to topic %@", kTopic);
                    [self saveToDefault:[NSString stringWithFormat:@"subscribed to topic %@", kTopic]];
                });
            }];
        } else {
            NSLog(@"Fail is connected with id %@", clientID);
            
        }
    }];
}




- (void) saveToDefault:(NSString *) message {
  
    NSString * allMessage = [[NSUserDefaults standardUserDefaults] objectForKey:@"message"];
    if(allMessage.length == 0)
        allMessage = message;
    else
        allMessage =[allMessage stringByAppendingString:[NSString stringWithFormat:@"\n%@",message]];
    [[NSUserDefaults standardUserDefaults] setObject:allMessage forKey:@"message"];
    [[NSUserDefaults standardUserDefaults]synchronize];

}
- (IBAction)showLogsTapped:(id)sender {

    NSString * allMessage = [[NSUserDefaults standardUserDefaults] objectForKey:@"message"];
    self.textView.text = allMessage;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
