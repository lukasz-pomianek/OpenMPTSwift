// stubs.cpp
// Stub implementations for optional libopenmpt codec functions
// These prevent linker errors while maintaining basic tracker format support

#include <cstddef>

// Forward declarations to match the missing symbols
namespace OpenMPT {
    
    class CSoundFile {
    public:
        template<typename FileReader>
        static bool ReadMP3Sample(unsigned short, FileReader&, bool, bool) {
            return false; // MP3 support not available
        }
        
        template<typename FileReader>
        static bool ReadOpusSample(unsigned short, FileReader&) {
            return false; // Opus support not available
        }
        
        template<typename FileReader>
        static bool ReadVorbisSample(unsigned short, FileReader&) {
            return false; // Vorbis support not available
        }
        
        template<typename FileReader>
        static bool ReadMediaFoundationSample(unsigned short, FileReader&, bool) {
            return false; // Media Foundation not available on iOS/macOS
        }
        
        template<typename FileReader>
        static bool ProbeFileHeaderXM(FileReader, const unsigned long long*) {
            return false; // XM format probing not implemented
        }
        
        template<typename FileReader>
        static bool ProbeFileHeaderMO3(FileReader, const unsigned long long*) {
            return false; // MO3 format probing not implemented
        }
        
        template<typename FileReader, typename ModLoadingFlags>
        static bool ReadXM(FileReader&, ModLoadingFlags) {
            return false; // XM format reading not implemented
        }
        
        template<typename FileReader, typename ModLoadingFlags>
        static bool ReadMO3(FileReader&, ModLoadingFlags) {
            return false; // MO3 format reading not implemented
        }
    };
}