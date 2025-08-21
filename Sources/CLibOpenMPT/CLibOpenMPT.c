// CLibOpenMPT.c
// This file is required by SPM for the C target
// It provides a bridge to the XCFramework

#include "libopenmpt.h"

// Dummy function to ensure this C target produces an object file
// This is required for Xcode to properly link the target
void clibopenmpt_ensure_linkage(void) {
    // This function exists only to satisfy the linker
    // All actual libopenmpt functionality comes from the XCFramework
    // libOpenMPT 0.8.2 includes full codec support
}

// Force symbol resolution by referencing XCFramework symbols
// This ensures the linker can find all OpenMPT functions
__attribute__((used)) static void force_symbol_resolution(void) {
    // Reference key functions to ensure they're accessible
    // These will be resolved at link time from the XCFramework
    void *symbols[] = {
        (void*)openmpt_module_create_from_memory2,
        (void*)openmpt_module_destroy,
        (void*)openmpt_module_get_current_order,
        (void*)openmpt_module_get_current_pattern,
        (void*)openmpt_module_get_current_row,
        (void*)openmpt_module_get_current_speed,
        (void*)openmpt_module_get_current_tempo2,
        (void*)openmpt_module_get_duration_seconds,
        (void*)openmpt_module_get_instrument_name,
        (void*)openmpt_module_get_metadata,
        (void*)openmpt_module_get_num_channels,
        (void*)openmpt_module_get_num_instruments,
        (void*)openmpt_module_get_num_patterns,
        (void*)openmpt_module_get_num_samples,
        (void*)openmpt_module_get_position_seconds,
        (void*)openmpt_module_get_sample_name,
        (void*)openmpt_module_read_interleaved_float_stereo,
        (void*)openmpt_module_set_position_seconds,
        (void*)openmpt_module_set_repeat_count
    };
    (void)symbols; // Suppress unused variable warning
}