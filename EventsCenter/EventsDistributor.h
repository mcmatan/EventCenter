
//
// Created by Matan Cohen on 2/22/15.
 
//

#import <Foundation/Foundation.h>
@protocol STEvent;
@protocol EventsDistributor

- (void)subscribe:(id)observer forClassEvent:(Class)classEvent withSelector:(SEL)selector;

- (void)subscribe:(id)observer forClassEvent:(Class)classEvent withKey:(NSString *)key withSelector:(SEL)selector;

- (void)subscribeMoveToMainThread:(id)observer forClassEvent:(Class <STEvent>)classEvent withKey:(NSString *)key withSelector:(SEL)selector;

- (void)unsubscribe:(id)observer forClassEvent:(Class)classEvent;

- (void)fireEvent:(id <STEvent>)event;

- (void)fireEventOnMainThread:(id <STEvent>)event;

@end