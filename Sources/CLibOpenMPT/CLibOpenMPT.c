// CLibOpenMPT.c
// This file is required by SPM for the C target
// It provides a bridge to the XCFramework

#include "libopenmpt.h"

// Test function that uses OpenMPT to verify linking
// This forces the linker to include the XCFramework
int clibopenmpt_test_linking(void) {
    // This will only work if the XCFramework is properly linked
    // Return the library version as a test
    return (int)openmpt_get_library_version();
}

// Ensure all OpenMPT symbols are available by creating a reference table
// This should force the linker to include all necessary symbols
static void* _openmpt_symbol_table[] = {
    (void*)openmpt_get_library_version,
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
    (void*)openmpt_module_set_repeat_count,
    0
};

// Function to ensure symbol table is referenced
__attribute__((used))
void* clibopenmpt_get_symbol_table(void) {
    return _openmpt_symbol_table;
}