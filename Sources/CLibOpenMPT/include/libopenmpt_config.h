/*
 * libopenmpt_config.h
 * -------------------
 * Purpose: libopenmpt build configuration
 * Notes  : This file is configured for iOS/macOS builds
 * Authors: OpenMPT Devs
 * The OpenMPT source code is released under the BSD license.
 */

#ifndef LIBOPENMPT_CONFIG_H
#define LIBOPENMPT_CONFIG_H

/* Build info */
#define LIBOPENMPT_BUILD_COMPILER "clang"
#define LIBOPENMPT_BUILD_FEATURES ""

/* C API visibility */
#ifdef __cplusplus
#define LIBOPENMPT_API extern "C"
#else
#define LIBOPENMPT_API
#endif

/* Extension API support */
#define LIBOPENMPT_EXT_INTERFACE_SUPPORTED 1
#define LIBOPENMPT_EXT_INTERACTIVE_SUPPORTED 1

/* C++ API support */
#ifdef __cplusplus
#define LIBOPENMPT_CXX_API
#endif

/* Deprecation warnings */
#ifdef __GNUC__
#define LIBOPENMPT_DEPRECATED __attribute__((deprecated))
#elif defined(_MSC_VER)
#define LIBOPENMPT_DEPRECATED __declspec(deprecated)
#else
#define LIBOPENMPT_DEPRECATED
#endif

#endif /* LIBOPENMPT_CONFIG_H */