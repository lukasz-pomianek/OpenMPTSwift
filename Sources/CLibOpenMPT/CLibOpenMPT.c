// CLibOpenMPT.c
// This file is required by SPM for the C target
// It provides a bridge to the XCFramework and stub implementations for missing codecs

#include "libopenmpt.h"

// Dummy function to ensure this C target produces an object file
// This is required for Xcode to properly link the target
void clibopenmpt_ensure_linkage(void) {
    // This function exists only to satisfy the linker
    // All actual libopenmpt functionality comes from the XCFramework
}

// Stub implementations for missing codec support
// These are only called if the library was built without codec support

#ifdef __cplusplus
extern "C" {
#endif

// MP3 support stub (if NO_MP3 is defined)
int _ZN7OpenMPT10CSoundFile13ReadMP3SampleEtRNS_6detail10FileReaderIN3mpt14mpt_libopenmpt2IO24FileCursorTraitsFileDataENS5_24FileCursorFilenameTraitsINS4_15BasicPathStringINS4_14Utf8PathTraitsELb0EEEEEEEbb(void) {
    // MP3 support not available - return false
    return 0;
}

// Opus support stub (if NO_OPUS is defined)
int _ZN7OpenMPT10CSoundFile14ReadOpusSampleEtRNS_6detail10FileReaderIN3mpt14mpt_libopenmpt2IO24FileCursorTraitsFileDataENS5_24FileCursorFilenameTraitsINS4_15BasicPathStringINS4_14Utf8PathTraitsELb0EEEEEE(void) {
    // Opus support not available - return false
    return 0;
}

// Opus support stub with reference parameter (alternative signature)
int _ZN7OpenMPT10CSoundFile14ReadOpusSampleEtRNS_6detail10FileReaderIN3mpt14mpt_libopenmpt2IO24FileCursorTraitsFileDataENS5_24FileCursorFilenameTraitsINS4_15BasicPathStringINS4_14Utf8PathTraitsELb0EEEEEEER(void) {
    // Opus support not available - return false
    return 0;
}

// Vorbis support stub (if NO_VORBIS is defined)
int _ZN7OpenMPT10CSoundFile16ReadVorbisSampleEtRNS_6detail10FileReaderIN3mpt14mpt_libopenmpt2IO24FileCursorTraitsFileDataENS5_24FileCursorFilenameTraitsINS4_15BasicPathStringINS4_14Utf8PathTraitsELb0EEEEEE(void) {
    // Vorbis support not available - return false
    return 0;
}

// Vorbis support stub with reference parameter (alternative signature)
int _ZN7OpenMPT10CSoundFile16ReadVorbisSampleEtRNS_6detail10FileReaderIN3mpt14mpt_libopenmpt2IO24FileCursorTraitsFileDataENS5_24FileCursorFilenameTraitsINS4_15BasicPathStringINS4_14Utf8PathTraitsELb0EEEEEEER(void) {
    // Vorbis support not available - return false
    return 0;
}

// XM format support stub (if NO_XM is defined)
int _ZN7OpenMPT10CSoundFile6ReadXMERNS_6detail10FileReaderIN3mpt14mpt_libopenmpt2IO24FileCursorTraitsFileDataENS5_24FileCursorFilenameTraitsINS4_15BasicPathStringINS4_14Utf8PathTraitsELb0EEEEEEENS0_15ModLoadingFlagsE(void) {
    // XM format support not available - return false
    return 0;
}

// MO3 format support stub (if NO_MO3 is defined)
int _ZN7OpenMPT10CSoundFile7ReadMO3ERNS_6detail10FileReaderIN3mpt14mpt_libopenmpt2IO24FileCursorTraitsFileDataENS5_24FileCursorFilenameTraitsINS4_15BasicPathStringINS4_14Utf8PathTraitsELb0EEEEEEENS0_15ModLoadingFlagsE(void) {
    // MO3 format support not available - return false
    return 0;
}

// XM probe stub - returns nullptr (no probe info)
void* _ZN7OpenMPT10CSoundFile16ProbeFileHeaderXMENS_6detail10FileReaderIN3mpt14mpt_libopenmpt2IO24FileCursorTraitsMemoryENS5_33FileCursorFilenameTraitsNoneEEEEPKy(void) {
    // XM probe support not available - return nullptr
    return 0;
}

// MO3 probe stub - returns nullptr (no probe info)
void* _ZN7OpenMPT10CSoundFile17ProbeFileHeaderMO3ENS_6detail10FileReaderIN3mpt14mpt_libopenmpt2IO24FileCursorTraitsMemoryENS5_33FileCursorFilenameTraitsNoneEEEEPKy(void) {
    // MO3 probe support not available - return nullptr
    return 0;
}

// Media Foundation support stub (Windows-specific, not needed on iOS/macOS)
int _ZN7OpenMPT10CSoundFile26ReadMediaFoundationSampleEtRNS_6detail10FileReaderIN3mpt14mpt_libopenmpt2IO24FileCursorTraitsFileDataENS5_24FileCursorFilenameTraitsINS4_15BasicPathStringINS4_14Utf8PathTraitsELb0EEEEEEEb(void) {
    // Media Foundation support not available on iOS/macOS - return false
    return 0;
}

// Alternative Media Foundation signature (25 instead of 26)
int _ZN7OpenMPT10CSoundFile25ReadMediaFoundationSampleEtRNS_6detail10FileReaderIN3mpt14mpt_libopenmpt2IO24FileCursorTraitsFileDataENS5_24FileCursorFilenameTraitsINS4_15BasicPathStringINS4_14Utf8PathTraitsELb0EEEEEEEb(void) {
    // Media Foundation support not available on iOS/macOS - return false
    return 0;
}

// Additional XM probe stub (alternative signature)
void* _ZN7OpenMPT10CSoundFile17ProbeFileHeaderXMENS_6detail10FileReaderIN3mpt14mpt_libopenmpt2IO22FileCursorTraitsMemoryENS5_28FileCursorFilenameTraitsNoneEEEPKy(void) {
    // XM probe support not available - return nullptr
    return 0;
}

// Additional XM probe stub (18 variant)
void* _ZN7OpenMPT10CSoundFile18ProbeFileHeaderXMFENS_6detail10FileReaderIN3mpt14mpt_libopenmpt2IO22FileCursorTraitsMemoryENS5_28FileCursorFilenameTraitsNoneEEEPKy(void) {
    // XM probe support not available - return nullptr
    return 0;
}

// Additional MO3 probe stub (18 variant)
void* _ZN7OpenMPT10CSoundFile18ProbeFileHeaderMO3ENS_6detail10FileReaderIN3mpt14mpt_libopenmpt2IO22FileCursorTraitsMemoryENS5_28FileCursorFilenameTraitsNoneEEEPKy(void) {
    // MO3 probe support not available - return nullptr
    return 0;
}

#ifdef __cplusplus
}
#endif