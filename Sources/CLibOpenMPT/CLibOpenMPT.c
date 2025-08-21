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