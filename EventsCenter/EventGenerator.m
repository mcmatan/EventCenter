//
//  EventGenerator.m

//
//  Created by Matan Cohen on 11/5/14.

//

#import "EventGenerator.h"

#define SEPERATOR @"_____"

@implementation EventGenerator

+(NSString *) generatEventName: (NSString *) eventName
                        forKey: (NSString *) key {
    
        
        if (!key) {
            return nil;
        }
        
        return [NSString stringWithFormat:@"%@%@%@", eventName,SEPERATOR, key];
        
        
}

+(NSString *) generatEventNameToNonKey: (NSString *) eventName {

    NSRange pos = [eventName rangeOfString:SEPERATOR];
    if (pos.location != NSNotFound) {
        NSString *prefix = [eventName substringToIndex:pos.location];
        return prefix;
    }
    
    
    return eventName;
    
    
}

@end
