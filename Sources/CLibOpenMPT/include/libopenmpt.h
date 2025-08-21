/*
 * libopenmpt.h - SPM Wrapper
 * ---------------------------
 * Purpose: Wrapper header for LibOpenMPT XCFramework
 * This file redirects to the actual libopenmpt headers in the XCFramework
 */

#ifndef LIBOPENMPT_SPM_WRAPPER_H
#define LIBOPENMPT_SPM_WRAPPER_H

// We need to import the functions directly from the binary framework
// The actual function declarations will be linked from the XCFramework at link time

#include <stddef.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

// Forward declare the opaque module type
typedef struct openmpt_module openmpt_module;

// Essential function declarations for the module lifecycle
extern uint32_t openmpt_get_library_version(void);
extern uint32_t openmpt_get_core_version(void);
extern const char * openmpt_get_string( const char * key );
extern void openmpt_free_string( const char * str );

// Module creation and destruction
__attribute__((visibility("default"))) extern openmpt_module * openmpt_module_create_from_memory2( const void * filedata, size_t filesize, void * logfunc, void * loguser, void * errfunc, void * erruser, int * error, const char * * error_message, const void * ctls );
__attribute__((visibility("default"))) extern void openmpt_module_destroy( openmpt_module * mod );

// Playback control
extern int openmpt_module_set_repeat_count( openmpt_module * mod, int32_t repeat_count );
extern double openmpt_module_get_duration_seconds( openmpt_module * mod );
extern double openmpt_module_set_position_seconds( openmpt_module * mod, double seconds );
extern double openmpt_module_get_position_seconds( openmpt_module * mod );

// Audio rendering
extern size_t openmpt_module_read_interleaved_float_stereo( openmpt_module * mod, int32_t samplerate, size_t count, float * interleaved_stereo );

// Module information
extern const char * openmpt_module_get_metadata( openmpt_module * mod, const char * key );
extern int32_t openmpt_module_get_num_instruments( openmpt_module * mod );
extern int32_t openmpt_module_get_num_samples( openmpt_module * mod );
extern int32_t openmpt_module_get_num_patterns( openmpt_module * mod );
extern int32_t openmpt_module_get_num_channels( openmpt_module * mod );
extern const char * openmpt_module_get_instrument_name( openmpt_module * mod, int32_t index );
extern const char * openmpt_module_get_sample_name( openmpt_module * mod, int32_t index );

// Current position info
extern int32_t openmpt_module_get_current_order( openmpt_module * mod );
extern int32_t openmpt_module_get_current_pattern( openmpt_module * mod );
extern int32_t openmpt_module_get_current_row( openmpt_module * mod );
extern int32_t openmpt_module_get_current_speed( openmpt_module * mod );
extern double openmpt_module_get_current_tempo2( openmpt_module * mod );

#ifdef __cplusplus
}
#endif

#endif /* LIBOPENMPT_SPM_WRAPPER_H */
