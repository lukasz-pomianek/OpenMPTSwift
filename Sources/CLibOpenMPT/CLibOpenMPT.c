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
    (void*)openmpt_module_get_pattern_num_rows,
    (void*)openmpt_module_get_pattern_row_channel_command,
    (void*)openmpt_module_get_pattern_name,
    (void*)openmpt_module_get_pattern_rows_per_beat,
    (void*)openmpt_module_get_pattern_rows_per_measure,
    (void*)openmpt_module_get_num_orders,
    (void*)openmpt_module_get_order_pattern,
    (void*)openmpt_module_set_position_order_row,
    (void*)openmpt_module_get_num_subsongs,
    (void*)openmpt_module_get_selected_subsong,
    (void*)openmpt_module_select_subsong,
    (void*)openmpt_module_get_render_param,
    (void*)openmpt_module_set_render_param,
    (void*)openmpt_module_ctl_get,
    (void*)openmpt_module_ctl_set,
    (void*)openmpt_module_get_pattern_rows,
    (void*)openmpt_module_get_pattern_cell,
    (void*)openmpt_module_set_pattern_cell,
    (void*)openmpt_module_insert_pattern_row,
    (void*)openmpt_module_delete_pattern_row,
    0
};

// Function to ensure symbol table is referenced
__attribute__((used))
void* clibopenmpt_get_symbol_table(void) {
    return _openmpt_symbol_table;
}

// Stub implementations for missing codec functions
// These are needed because libOpenMPT 0.8.2 references external codec libraries

// MPG123 stubs
int mpg123_delete(void* mh) { return 0; }
int mpg123_exit(void) { return 0; }
int mpg123_getformat(void* mh, long* rate, int* channels, int* encoding) { return -1; }
int mpg123_id3(void* mh, void** v1, void** v2) { return 0; }
int mpg123_info2(void* mh, void* mi) { return -1; }
int mpg123_init(void) { return 0; }
long mpg123_length64(void* mh) { return -1; }
void* mpg123_new(const char* decoder, int* error) { return 0; }
int mpg123_open_handle64(void* mh, void* iohandle) { return -1; }
long mpg123_outblock(void* mh) { return 0; }
int mpg123_param2(void* mh, int type, long value, double fvalue) { return -1; }
int mpg123_read(void* mh, unsigned char* outmemory, size_t outmemsize, size_t* done) { return -1; }
int mpg123_reader64(void* mh, void* r_read, void* r_lseek, void* cleanup) { return -1; }
int mpg123_scan(void* mh) { return -1; }

// Additional MPG123 symbols that may be missing on simulator
int mpg123_encsize(int encoding) { return 0; }
int mpg123_format2(int encoding) { return 0; }
int mpg123_format_none(void) { return 0; }

// Ogg Vorbis stubs  
int ov_clear(void* vf) { return 0; }
char* ov_comment(void* vf, int link) { return 0; }
void* ov_info(void* vf, int link) { return 0; }
int ov_open_callbacks(void* datasource, void* vf, const char* initial, long ibytes, void* callbacks) { return -1; }
long ov_pcm_total(void* vf, int i) { return -1; }
long ov_read_float(void* vf, float*** pcm_channels, int samples, int* bitstream) { return -1; }
int ov_streams(void* vf) { return 0; }

// Vorbis stubs
int vorbis_comment_query(void* vc, const char* tag, int count) { return 0; }

// Pattern editing bridge functions
// Note: libopenmpt is read-only, so editing functions are stubs that return errors

int32_t openmpt_module_get_pattern_rows(openmpt_module* mod, int32_t pattern) {
    // This maps to the existing function with different name
    return openmpt_module_get_pattern_num_rows(mod, pattern);
}

int openmpt_module_get_pattern_cell(openmpt_module* mod, int32_t pattern, int32_t channel, int32_t row, openmpt_pattern_cell* cell) {
    if (!mod || !cell) return 0;
    
    // Use the existing pattern data access function to read pattern data
    // This is a simplified implementation - in reality we'd need to parse the raw pattern data
    cell->note = openmpt_module_get_pattern_row_channel_command(mod, pattern, row, channel, 0); // note
    cell->instrument = openmpt_module_get_pattern_row_channel_command(mod, pattern, row, channel, 1); // instrument  
    cell->volume = openmpt_module_get_pattern_row_channel_command(mod, pattern, row, channel, 2); // volume
    cell->effect = openmpt_module_get_pattern_row_channel_command(mod, pattern, row, channel, 3); // effect
    cell->effect_param = openmpt_module_get_pattern_row_channel_command(mod, pattern, row, channel, 4); // effect param
    
    return 1; // success
}

int openmpt_module_set_pattern_cell(openmpt_module* mod, int32_t pattern, int32_t channel, int32_t row, const openmpt_pattern_cell* cell) {
    // libopenmpt is read-only - editing is not supported
    // Return 0 to indicate failure/not supported
    return 0;
}

int openmpt_module_insert_pattern_row(openmpt_module* mod, int32_t pattern, int32_t row) {
    // libopenmpt is read-only - editing is not supported
    // Return 0 to indicate failure/not supported  
    return 0;
}

int openmpt_module_delete_pattern_row(openmpt_module* mod, int32_t pattern, int32_t row) {
    // libopenmpt is read-only - editing is not supported
    // Return 0 to indicate failure/not supported
    return 0;
}