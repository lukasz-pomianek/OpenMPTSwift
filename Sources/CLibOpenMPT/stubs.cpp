// stubs.cpp  
// Weak symbol implementations for missing libopenmpt codec functions
// These will be linked into the final binary to resolve missing symbols

// Create weak symbol implementations using extern "C" to avoid name mangling issues
extern "C" {
    
    // Weak implementations that return "format not supported"
    // These match the missing symbols reported by the linker
    
    __attribute__((weak))
    bool _ZN7OpenMPT10CSoundFile13ReadMP3SampleEtRNS_6detail10FileReaderIN3mpt15mpt_libopenmpt2IO24FileCursorTraitsFileDataENS5_23FileCursorFilenameTraitsINS4_15BasicPathStringINS4_14Utf8PathTraitsELb0EEEEEEEbb() {
        return false; // MP3 not supported
    }
    
    __attribute__((weak))  
    bool _ZN7OpenMPT10CSoundFile15ReadOpusSampleEtRNS_6detail10FileReaderIN3mpt15mpt_libopenmpt2IO24FileCursorTraitsFileDataENS5_23FileCursorFilenameTraitsINS4_15BasicPathStringINS4_14Utf8PathTraitsELb0EEEEEEE() {
        return false; // Opus not supported
    }
    
    __attribute__((weak))
    bool _ZN7OpenMPT10CSoundFile17ReadVorbisSampleEtRNS_6detail10FileReaderIN3mpt15mpt_libopenmpt2IO24FileCursorTraitsFileDataENS5_23FileCursorFilenameTraitsINS4_15BasicPathStringINS4_14Utf8PathTraitsELb0EEEEEEE() {
        return false; // Vorbis not supported  
    }
    
    __attribute__((weak))
    bool _ZN7OpenMPT10CSoundFile26ReadMediaFoundationSampleEtRNS_6detail10FileReaderIN3mpt15mpt_libopenmpt2IO24FileCursorTraitsFileDataENS5_23FileCursorFilenameTraitsINS4_15BasicPathStringINS4_14Utf8PathTraitsELb0EEEEEEEb() {
        return false; // Media Foundation not supported on iOS/macOS
    }
    
    __attribute__((weak))
    bool _ZN7OpenMPT10CSoundFile18ProbeFileHeaderXMENS_6detail10FileReaderIN3mpt15mpt_libopenmpt2IO22FileCursorTraitsMemoryENS4_24FileCursorFilenameTraitsNoneEEEPKy() {
        return false; // XM format probing not supported
    }
    
    __attribute__((weak))
    bool _ZN7OpenMPT10CSoundFile19ProbeFileHeaderMO3ENS_6detail10FileReaderIN3mpt15mpt_libopenmpt2IO22FileCursorTraitsMemoryENS4_24FileCursorFilenameTraitsNoneEEEPKy() {
        return false; // MO3 format probing not supported  
    }
    
    __attribute__((weak))
    bool _ZN7OpenMPT10CSoundFile6ReadXMERNS_6detail10FileReaderIN3mpt15mpt_libopenmpt2IO24FileCursorTraitsFileDataENS5_23FileCursorFilenameTraitsINS4_15BasicPathStringINS4_14Utf8PathTraitsELb0EEEEEENS0_14ModLoadingFlagsE() {
        return false; // XM format reading not supported
    }
    
    __attribute__((weak))
    bool _ZN7OpenMPT10CSoundFile7ReadMO3ERNS_6detail10FileReaderIN3mpt15mpt_libopenmpt2IO24FileCursorTraitsFileDataENS5_23FileCursorFilenameTraitsINS4_15BasicPathStringINS4_14Utf8PathTraitsELb0EEEEEENS0_14ModLoadingFlagsE() {
        return false; // MO3 format reading not supported
    }
    
    // Placeholder to ensure this file generates object code
    __attribute__((weak))
    void __openmpt_codec_stubs_placeholder() {
        // This ensures the object file is created and linked
    }
}