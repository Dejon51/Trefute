#ifndef _TRIFUTE_MACROS_H
#define _TRIFUTE_MACROS_H

#include <string.h>

#define VERSION_MAJOR "0"
#define VERSION_MINOR "0"
#define VERSION_PATCH "0"

#ifndef NDEBUG
#define VERSION VERSION_MAJOR "." VERSION_MINOR "." VERSION_PATCH "-dev"
#else
#define VERSION VERSION_MAJOR "." VERSION_MINOR "." VERSION_PATCH
#endif

#endif
