
#import <Foundation/Foundation.h>
#import "EventsDistributor.h"

@interface EventCenter : NSObject < EventsDistributor >
@property (nonatomic, strong) NSMutableDictionary *map;
- (instancetype)init;

@end
