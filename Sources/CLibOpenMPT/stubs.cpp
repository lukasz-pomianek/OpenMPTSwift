// stubs.cpp
// Exact stub implementations for missing libopenmpt codec functions
// These match the precise C++ mangled symbol names that the linker expects

// We need to recreate the exact namespace and type structure that libopenmpt uses
namespace mpt {
    namespace mpt_libopenmpt {
        // These are directly under mpt_libopenmpt, not under IO
        struct Utf8PathTraits {};
        
        template<typename PathTraits, bool isUnicode>
        struct BasicPathString {};
        
        namespace IO {
            struct FileCursorTraitsFileData {};
            struct FileCursorTraitsMemory {};
            struct FileCursorFilenameTraitsNone {};
            
            template<typename PathString>
            struct FileCursorFilenameTraits {};
        }
    }
}

namespace OpenMPT {
    namespace detail {
        template<typename CursorTraits, typename FilenameTraits>
        class FileReader {
        public:
            // Empty implementation - just needs to exist for linking
        };
    }
    
    // Define the ModLoadingFlags enum that's used in the signatures
    enum class ModLoadingFlags : unsigned int {
        loadCompleteModule = 0
    };
    
    class CSoundFile {
    public:
        // Exact stub implementations for the missing symbols
        
        // MP3 Sample reading
        static bool ReadMP3Sample(
            unsigned short smp, 
            detail::FileReader<mpt::mpt_libopenmpt::IO::FileCursorTraitsFileData, 
                             mpt::mpt_libopenmpt::IO::FileCursorFilenameTraits<
                                 mpt::mpt_libopenmpt::BasicPathString<mpt::mpt_libopenmpt::Utf8PathTraits, false>>>& file,
            bool mayNormalize, 
            bool includeInstrumentEnvelopes
        ) {
            return false; // MP3 not supported in this build
        }
        
        // Opus Sample reading  
        static bool ReadOpusSample(
            unsigned short smp,
            detail::FileReader<mpt::mpt_libopenmpt::IO::FileCursorTraitsFileData,
                             mpt::mpt_libopenmpt::IO::FileCursorFilenameTraits<
                                 mpt::mpt_libopenmpt::BasicPathString<mpt::mpt_libopenmpt::Utf8PathTraits, false>>>& file
        ) {
            return false; // Opus not supported in this build
        }
        
        // Vorbis Sample reading
        static bool ReadVorbisSample(
            unsigned short smp,
            detail::FileReader<mpt::mpt_libopenmpt::IO::FileCursorTraitsFileData,
                             mpt::mpt_libopenmpt::IO::FileCursorFilenameTraits<
                                 mpt::mpt_libopenmpt::BasicPathString<mpt::mpt_libopenmpt::Utf8PathTraits, false>>>& file
        ) {
            return false; // Vorbis not supported in this build  
        }
        
        // Media Foundation Sample reading (Windows only)
        static bool ReadMediaFoundationSample(
            unsigned short smp,
            detail::FileReader<mpt::mpt_libopenmpt::IO::FileCursorTraitsFileData,
                             mpt::mpt_libopenmpt::IO::FileCursorFilenameTraits<
                                 mpt::mpt_libopenmpt::BasicPathString<mpt::mpt_libopenmpt::Utf8PathTraits, false>>>& file,
            bool mayNormalize
        ) {
            return false; // Media Foundation not available on iOS/macOS
        }
        
        // XM format probing
        static bool ProbeFileHeaderXM(
            detail::FileReader<mpt::mpt_libopenmpt::IO::FileCursorTraitsMemory,
                             mpt::mpt_libopenmpt::IO::FileCursorFilenameTraitsNone> file,
            const unsigned long long* headerMagic
        ) {
            return false; // XM probing not implemented in this build
        }
        
        // MO3 format probing
        static bool ProbeFileHeaderMO3(
            detail::FileReader<mpt::mpt_libopenmpt::IO::FileCursorTraitsMemory,
                             mpt::mpt_libopenmpt::IO::FileCursorFilenameTraitsNone> file,
            const unsigned long long* headerMagic
        ) {
            return false; // MO3 probing not implemented in this build
        }
        
        // XM format reading
        static bool ReadXM(
            detail::FileReader<mpt::mpt_libopenmpt::IO::FileCursorTraitsFileData,
                             mpt::mpt_libopenmpt::IO::FileCursorFilenameTraits<
                                 mpt::mpt_libopenmpt::BasicPathString<mpt::mpt_libopenmpt::Utf8PathTraits, false>>>& file,
            ModLoadingFlags loadFlags
        ) {
            return false; // XM format not supported in this build
        }
        
        // MO3 format reading  
        static bool ReadMO3(
            detail::FileReader<mpt::mpt_libopenmpt::IO::FileCursorTraitsFileData,
                             mpt::mpt_libopenmpt::IO::FileCursorFilenameTraits<
                                 mpt::mpt_libopenmpt::BasicPathString<mpt::mpt_libopenmpt::Utf8PathTraits, false>>>& file,
            ModLoadingFlags loadFlags
        ) {
            return false; // MO3 format not supported in this build
        }
    };
}