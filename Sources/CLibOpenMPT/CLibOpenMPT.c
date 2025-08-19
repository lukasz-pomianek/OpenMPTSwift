// CLibOpenMPT.c
// This file is required by SPM for the C target
// It provides a bridge to the XCFramework

#include "libopenmpt.h"

// Dummy function to ensure this C target produces an object file
// This is required for Xcode to properly link the target
void clibopenmpt_ensure_linkage(void) {
    // This function exists only to satisfy the linker
    // All actual libopenmpt functionality comes from the XCFramework
}