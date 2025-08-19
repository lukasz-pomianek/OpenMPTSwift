// stubs.cpp  
// Weak symbol implementations for missing libopenmpt codec functions
// These will be linked into the final binary to resolve missing symbols

// Forward declarations for types needed in function signatures
namespace mpt { 
    namespace mpt_libopenmpt {
        struct Utf8PathTraits;
        template<typename T, bool B> struct BasicPathString;
        namespace IO {
            struct FileCursorTraitsFileData;
            struct FileCursorTraitsMemory;
            struct FileCursorFilenameTraitsNone;
            template<typename T> struct FileCursorFilenameTraits;
        }
    }
}

namespace OpenMPT {
    namespace detail {
        template<typename T, typename U> struct FileReader;
    }
    struct CSoundFile {
        enum ModLoadingFlags : unsigned int;
    };
}

// Define the exact C++ function signatures and provide weak implementations
namespace OpenMPT {
    __attribute__((weak))
    bool CSoundFile::ReadMP3Sample(unsigned short, 
                                   detail::FileReader<mpt::mpt_libopenmpt::IO::FileCursorTraitsFileData, 
                                                    mpt::mpt_libopenmpt::IO::FileCursorFilenameTraits<mpt::mpt_libopenmpt::BasicPathString<mpt::mpt_libopenmpt::Utf8PathTraits, false>>>&, 
                                   bool, bool) {
        return false; // MP3 not supported
    }
    
    __attribute__((weak))
    bool CSoundFile::ReadOpusSample(unsigned short,
                                    detail::FileReader<mpt::mpt_libopenmpt::IO::FileCursorTraitsFileData, 
                                                     mpt::mpt_libopenmpt::IO::FileCursorFilenameTraits<mpt::mpt_libopenmpt::BasicPathString<mpt::mpt_libopenmpt::Utf8PathTraits, false>>>&) {
        return false; // Opus not supported
    }
    
    __attribute__((weak))
    bool CSoundFile::ReadVorbisSample(unsigned short,
                                      detail::FileReader<mpt::mpt_libopenmpt::IO::FileCursorTraitsFileData, 
                                                       mpt::mpt_libopenmpt::IO::FileCursorFilenameTraits<mpt::mpt_libopenmpt::BasicPathString<mpt::mpt_libopenmpt::Utf8PathTraits, false>>>&) {
        return false; // Vorbis not supported
    }
    
    __attribute__((weak))
    bool CSoundFile::ReadMediaFoundationSample(unsigned short,
                                               detail::FileReader<mpt::mpt_libopenmpt::IO::FileCursorTraitsFileData, 
                                                                mpt::mpt_libopenmpt::IO::FileCursorFilenameTraits<mpt::mpt_libopenmpt::BasicPathString<mpt::mpt_libopenmpt::Utf8PathTraits, false>>>&, 
                                               bool) {
        return false; // Media Foundation not supported on iOS/macOS
    }
    
    __attribute__((weak))
    bool CSoundFile::ProbeFileHeaderXM(detail::FileReader<mpt::mpt_libopenmpt::IO::FileCursorTraitsMemory, 
                                                          mpt::mpt_libopenmpt::IO::FileCursorFilenameTraitsNone>, 
                                       const unsigned long long*) {
        return false; // XM format probing not supported
    }
    
    __attribute__((weak))
    bool CSoundFile::ProbeFileHeaderMO3(detail::FileReader<mpt::mpt_libopenmpt::IO::FileCursorTraitsMemory, 
                                                           mpt::mpt_libopenmpt::IO::FileCursorFilenameTraitsNone>, 
                                        const unsigned long long*) {
        return false; // MO3 format probing not supported
    }
    
    __attribute__((weak))
    bool CSoundFile::ReadXM(detail::FileReader<mpt::mpt_libopenmpt::IO::FileCursorTraitsFileData, 
                                              mpt::mpt_libopenmpt::IO::FileCursorFilenameTraits<mpt::mpt_libopenmpt::BasicPathString<mpt::mpt_libopenmpt::Utf8PathTraits, false>>>&, 
                            ModLoadingFlags) {
        return false; // XM format reading not supported
    }
    
    __attribute__((weak))
    bool CSoundFile::ReadMO3(detail::FileReader<mpt::mpt_libopenmpt::IO::FileCursorTraitsFileData, 
                                               mpt::mpt_libopenmpt::IO::FileCursorFilenameTraits<mpt::mpt_libopenmpt::BasicPathString<mpt::mpt_libopenmpt::Utf8PathTraits, false>>>&, 
                             ModLoadingFlags) {
        return false; // MO3 format reading not supported
    }
}

// Placeholder to ensure this file generates object code
extern "C" __attribute__((weak))
void __openmpt_codec_stubs_placeholder() {
    // This ensures the object file is created and linked
}