//
//  EventGenerator.h

//
//  Created by Matan Cohen on 11/5/14.

//

#import <Foundation/Foundation.h>

@interface EventGenerator : NSObject

+(NSString *) generatEventName: (NSString *) eventName
                           forKey: (NSString *) key;

+(NSString *) generatEventNameToNonKey: (NSString *) eventName;
@end
