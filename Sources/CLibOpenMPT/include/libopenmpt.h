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

// Standard libopenmpt functions that exist in the XCFramework
extern int32_t openmpt_module_get_pattern_num_rows( openmpt_module * mod, int32_t pattern );
extern uint8_t openmpt_module_get_pattern_row_channel_command( openmpt_module * mod, int32_t pattern, int32_t row, int32_t channel, int command );
extern const char * openmpt_module_get_pattern_name( openmpt_module * mod, int32_t index );
extern int32_t openmpt_module_get_pattern_rows_per_beat( openmpt_module * mod, int32_t pattern );
extern int32_t openmpt_module_get_pattern_rows_per_measure( openmpt_module * mod, int32_t pattern );
extern int32_t openmpt_module_get_num_orders( openmpt_module * mod );
extern int32_t openmpt_module_get_order_pattern( openmpt_module * mod, int32_t order );
extern double openmpt_module_set_position_order_row( openmpt_module * mod, int32_t order, int32_t row );
extern int32_t openmpt_module_get_num_subsongs( openmpt_module * mod );
extern int32_t openmpt_module_get_selected_subsong( openmpt_module * mod );
extern int openmpt_module_select_subsong( openmpt_module * mod, int32_t subsong );
extern int32_t openmpt_module_get_render_param( openmpt_module * mod, int param );
extern int openmpt_module_set_render_param( openmpt_module * mod, int param, int32_t value );
extern const char * openmpt_module_ctl_get( openmpt_module * mod, const char * ctl );
extern int openmpt_module_ctl_set( openmpt_module * mod, const char * ctl, const char * value );

// Pattern cell structure for our custom bridge functions
typedef struct openmpt_pattern_cell {
    uint8_t note;
    uint8_t instrument;
    uint8_t volume;
    uint8_t effect;
    uint8_t effect_param;
} openmpt_pattern_cell;

// Custom bridge functions implemented in CLibOpenMPT.c
// Note: These are wrappers/stubs since libopenmpt is read-only
extern int32_t openmpt_module_get_pattern_rows( openmpt_module * mod, int32_t pattern );
extern int openmpt_module_get_pattern_cell( openmpt_module * mod, int32_t pattern, int32_t channel, int32_t row, openmpt_pattern_cell * cell );
extern int openmpt_module_set_pattern_cell( openmpt_module * mod, int32_t pattern, int32_t channel, int32_t row, const openmpt_pattern_cell * cell );
extern int openmpt_module_insert_pattern_row( openmpt_module * mod, int32_t pattern, int32_t row );
extern int openmpt_module_delete_pattern_row( openmpt_module * mod, int32_t pattern, int32_t row );

#ifdef __cplusplus
}
#endif

#endif /* LIBOPENMPT_SPM_WRAPPER_H */
