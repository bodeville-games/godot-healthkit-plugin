#include "health_kit.h"
#include "core/version.h"
#include "core/config/engine.h"
#include "health_kit_module.h"

HealthKit *health_kit;

void init_healthkit_plugin() {
    health_kit = memnew(HealthKit);
    Engine::get_singleton()->add_singleton(Engine::Singleton("HealthKit", health_kit));
}

void deinit_healthkit_plugin() {
    if (health_kit) {
        memdelete(health_kit);
    }
}
