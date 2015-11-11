//
//  STSubscriber.h
//  Stox
//
//  Created by Matan Cohen on 11/5/14.

//

#import <Foundation/Foundation.h>
#import "STEventObj.h"
typedef void (^block)(STEventObj *note);
@interface STSubscriberCallback : NSObject

@property (nonatomic, weak  ) block blockReturn;
@property (nonatomic, weak  ) id    observer;
@property (nonatomic, assign) SEL   selector;
@property (nonatomic, strong) NSString *key;
@end
