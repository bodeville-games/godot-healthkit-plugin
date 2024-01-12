#ifndef IN_APP_STORE_H
#define IN_APP_STORE_H

#include "core/version.h"
#include "core/object/class_db.h"

class HealthKit : public Object {

    GDCLASS(HealthKit, Object);

    static HealthKit *instance;
    static void _bind_methods();

public:

    // This gets the steps walked so far today.
    int get_today_steps_walked();
    
    // Gets the total steps walked since our arbitrary epoch of 1/1/2024. This date is
    // just used as an anchor point so we have a continuously increasing step count.
    int get_total_steps_walked();

    // Run the query to get steps walked today. The result returns asynchronously
    // and can be grabbed via get_today_steps_walked().
    void run_today_steps_walked_query();
    
    // Run the query which gets total steps walked since our arbitrary epoch, 1/1/2024.
    // The result is asynchronous, and can be fetched via get_total_steps_walked.
    void run_total_steps_walked_query();
    
    static HealthKit *get_singleton();

    HealthKit();
    ~HealthKit();
};

#endif
