//
//  STNotificationCenter.m

//
//  Created by Matan Cohen on 11/5/14.

//
#import "EventCenter.h"
#import "STSubscriberCallback.h"
#import "EventGenerator.h"
#import "STEvent.h"

@interface _MANotificationCenterDictionaryKey : NSObject
@property (nonatomic, strong)  NSString *name;
@property (nonatomic, assign) NSUInteger object;

+ (_MANotificationCenterDictionaryKey *)keyForName: (NSString *)name object: (id)obj;

@end

@implementation _MANotificationCenterDictionaryKey

- (id)_initWithName: (NSString *)name object: (id)obj
{
    if((self = [self init]))
    {
        _name = [name copy];
        _object = [obj hash];
    }
    return self;
}



+ (_MANotificationCenterDictionaryKey *)keyForName: (NSString *)name object: (id)obj
{
    return [[self alloc] _initWithName: name object: obj];
}

static BOOL Equal(id a, id b)
{
    if(!a && !b)
        return YES;
    else if(!a || !b)
        return NO;
    else
        return [a isEqual: b];
}

- (BOOL)isEqual: (id)other
{
    if(![other isKindOfClass: [_MANotificationCenterDictionaryKey class]])
        return NO;
    
    _MANotificationCenterDictionaryKey *otherKey = other;
    return Equal(_name, otherKey->_name) && _object == otherKey->_object;
}

- (NSUInteger)hash
{
    return [_name hash] ^ (uintptr_t)_object;
}

- (id)copyWithZone: (NSZone *)zone
{
    return self;
}

@end

@implementation EventCenter


- (id)init
{
    if((self = [super init]))
    {
        _map = [[NSMutableDictionary alloc] init];
    }
    return self;
}


- (id)subscribeFor: (NSString *)eventName object: (id)object block: (void (^)(STEventObj *note))block
{
    return [self addObserverForEventName:eventName observer:nil forSelector:nil withObject:object block:block];
}

- (id)subscribeFor: (NSString *) eventName observer:(id) observer forSelector: (SEL) selector  withObject: (id) object {

    return [self addObserverForEventName:eventName observer:observer forSelector:selector withObject:object block:nil];
}

- (id)addObserverForEventName: (NSString *) eventName observer:(id) observer forSelector: (SEL) selector  withObject: (id) object block: (void (^)(STEventObj *note))block{
    
    _MANotificationCenterDictionaryKey *key = [_MANotificationCenterDictionaryKey keyForName: eventName object: object];
    
    NSMutableSet *observerBlocks = _map[key];
    if(!observerBlocks)
    {
        observerBlocks = [NSMutableSet set];
        _map[(id)key] = observerBlocks;
    }
    
    void (^copiedBlock)(STEventObj *note);
    
    copiedBlock = [object copy];
    
    STSubscriberCallback *callback = [STSubscriberCallback new];
    callback.observer = observer;
    callback.selector = selector;
    callback.blockReturn = copiedBlock;

    
    [observerBlocks addObject: callback];
    
    
    void (^removalBlock)(void) = ^{
        [observerBlocks removeObject: callback];
        if([observerBlocks count] == 0)
            [self.map removeObjectForKey: key];
    };
    
    return [removalBlock copy];
    
}

- (void)_postNotification: (id <STEvent>)note name: (NSString *)name object: (id)object
{
    _MANotificationCenterDictionaryKey *key = [_MANotificationCenterDictionaryKey keyForName: name object: object];
    if (![_map objectForKey: key]) {
        return;
    }
    NSSet *observerBlocks = [_map objectForKey: key];
    if (!observerBlocks) {
        return;
    }
        for(STSubscriberCallback *callback in observerBlocks)
            if (callback.blockReturn) {
                callback.blockReturn(note);
            } else {
                if (callback.observer) {
                    if (callback.selector && note) {
                                    [callback.observer performSelectorOnMainThread:callback.selector withObject:note waitUntilDone:YES];
                    }
                }
            }
}


#pragma mark - Interface:


-(void) subscribe: (id) observer forClassEvent: (Class <STEvent>) classEvent withSelector: (SEL) selector {

    [self checkIfMainThreadWithClassEvent:classEvent withKey:nil withSelector:selector];
    
    NSString *eventName = NSStringFromClass(classEvent);
    [self subscribeFor:eventName observer:observer forSelector:selector withObject:nil];
}

-(void) subscribe: (id) observer forClassEvent: (Class <STEvent>) classEvent withKey:(NSString *) key withSelector: (SEL) selector {

    [self checkIfMainThreadWithClassEvent:classEvent withKey:key withSelector:selector];

    NSString *eventName = NSStringFromClass(classEvent);
    NSString*topic = [EventGenerator generatEventName:eventName forKey:key];
    [self subscribeFor:topic observer:observer forSelector:selector withObject:nil];
}

-(void) subscribeMoveToMainThread: (id) observer forClassEvent: (Class <STEvent>) classEvent withKey:(NSString *) key
                     withSelector: (SEL) selector
{

    dispatch_async(dispatch_get_main_queue(), ^{

        [self checkIfMainThreadWithClassEvent:classEvent withKey:key withSelector:selector];
        [self subscribe:observer forClassEvent:classEvent withKey:key withSelector:selector];

    });

}



-(void) unsubscribe: (id) observer forClassEvent: (Class) classEvent {

                for (_MANotificationCenterDictionaryKey *key in _map.allKeys) {
                    //Find if key:
                    NSString *eventNameNoKey = [EventGenerator generatEventNameToNonKey:key.name];
                    if ([eventNameNoKey isEqualToString:NSStringFromClass(classEvent)]) {
                        
                        //Find if value:
                        NSMutableOrderedSet *observerBlocks = _map[key];
                        
                        
                        for(STSubscriberCallback *callback in observerBlocks) {
                            
                                    if ([observer isEqual:callback.observer]) {
                                        [observerBlocks removeObject:callback];
                                        break;
                                    }

                        }
              
                        break;
                    }
                }
    
}


- (void) fireEvent: (id <STEvent> ) event {

    [self checkIfMainThreadWithClassEvent:[event class] withKey:nil withSelector:nil];

    NSString* eventName = NSStringFromClass([event class]);
    
    if ([event conformsToProtocol:@protocol(STEvent)]) {
        NSString* subscriptionKey = event.key;
        NSString* topic = [EventGenerator generatEventName:eventName forKey:subscriptionKey];
        if (topic) {
                    [self _postNotification:event name:topic object:nil];
        }
        
    }
   
    [self _postNotification:event name:eventName object:nil];
    
}

- (void) fireEventOnMainThread: (id <STEvent> ) event {

    dispatch_async(dispatch_get_main_queue(), ^{

        [self fireEvent:event];
    });
}



-(void) checkIfMainThreadWithClassEvent: (Class <STEvent>) classEvent withKey:(NSString *) key withSelector: (SEL)selector {

    if ( (![NSThread isMainThread]) ) {

        NSString *reason = [NSString stringWithFormat:@"Calling subscribe to event %@ not on main thread",
                        NSStringFromClass(classEvent)];
        @throw [NSException exceptionWithName:@"Not on main thread!" reason:reason
                                     userInfo:nil];
    }

}

@end
