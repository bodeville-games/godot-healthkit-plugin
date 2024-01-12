
#import "health_kit.h"
#include <Foundation/NSDate.h>
#include <HealthKit/HealthKit.h>

HealthKit *HealthKit::instance = NULL;
HKHealthStore *health_store = NULL;

int today_steps_walked = 0;
int total_steps_walked = 0;

void HealthKit::_bind_methods() {
    ClassDB::bind_method(D_METHOD("run_today_steps_query"), &HealthKit::run_today_steps_walked_query);
    ClassDB::bind_method(D_METHOD("run_total_steps_query"), &HealthKit::run_total_steps_walked_query);
    ClassDB::bind_method(D_METHOD("get_today_steps_walked"), &HealthKit::get_today_steps_walked);
    ClassDB::bind_method(D_METHOD("get_total_steps_walked"), &HealthKit::get_total_steps_walked);
    
}

HealthKit *HealthKit::get_singleton() {
    NSLog(@"Getting HealthKit Singleton");
    return instance;
}

HealthKit::HealthKit() {
    NSLog(@"In HealthKit constructor");
    ERR_FAIL_COND(instance != NULL);
    instance = this;
    health_store = [[HKHealthStore alloc] init];
    
    NSLog(@"Is health data available: %i", [HKHealthStore isHealthDataAvailable]);
    
    [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    
    // we read, but never update (share).
    NSSet<HKSampleType*> *read_types = [NSSet setWithObject:
                                        [HKQuantityType quantityTypeForIdentifier: HKQuantityTypeIdentifierStepCount]];
    
    
    [health_store requestAuthorizationToShareTypes:NULL readTypes:read_types
                                        completion:^(BOOL success, NSError * _Nullable error) {
        NSLog(@"Is health data completion success: %i", success);
        run_today_steps_walked_query();
        run_total_steps_walked_query();
    }];
}

int HealthKit::get_today_steps_walked() {
    NSLog(@"In HealthKit get today walked");
    return today_steps_walked;
}

int HealthKit::get_total_steps_walked() {
    NSLog(@"In HealthKit get total steps walked");
    return total_steps_walked;
}


void HealthKit::run_today_steps_walked_query() {
    
    HKQuantityType *type = [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    
    NSDate *today = [NSDate date];
    
    NSDate *startOfDay = [[NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian] startOfDayForDate:[NSDate date]];
    
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:startOfDay endDate:today options:HKQueryOptionStrictStartDate];
    
    HKStatisticsQuery *query = [[HKStatisticsQuery alloc]
                                initWithQuantityType:type quantitySamplePredicate:predicate
                                options:HKStatisticsOptionCumulativeSum
                                completionHandler:^(HKStatisticsQuery * _Nonnull query, HKStatistics * _Nullable result, NSError * _Nullable error) {
        
        if (error != nil) {
            NSLog(@"Error with today's steps: %@", error);
        } else {
            double steps = [[result sumQuantity] doubleValueForUnit:[HKUnit countUnit]];
            NSLog(@"Today's steps: %f", steps);
            today_steps_walked = steps;
        }
    }];
    
    
    [health_store executeQuery:query];
}


// There's a Garden epoch - say 1/1/2024. All total steps are relative to that.
// Gardens and flowers are started at the step count since that epoch.
void HealthKit::run_total_steps_walked_query() {
    
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:1]; // Monday
    [components setMonth:1]; // May
    [components setYear:2024];
    [components setHour:0];
    [components setMinute:0];
    [components setSecond:0];
    [components setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    
    NSDate *start = [calendar dateFromComponents:components];
    NSDate *end = [NSDate date];
    
    HKQuantityType *type = [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:start endDate:end options:HKQueryOptionStrictStartDate];

    HKStatisticsQuery *query = [[HKStatisticsQuery alloc] initWithQuantityType:type quantitySamplePredicate:predicate options:HKStatisticsOptionCumulativeSum completionHandler:^(HKStatisticsQuery * _Nonnull query, HKStatistics * _Nullable result, NSError * _Nullable error) {
        
        if (error != nil) {
            NSLog(@"Error with total steps: %@", error);
        } else {
            double steps = [[result sumQuantity] doubleValueForUnit:[HKUnit countUnit]];
            NSLog(@"Total steps since epoch %f", steps);
            total_steps_walked = steps;
        }
    }];
    
    [health_store executeQuery:query];
}


HealthKit::~HealthKit() {
}
