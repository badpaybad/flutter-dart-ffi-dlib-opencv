// only do anything with this file if DLIB_JPEG_SUPPORT is defined
#ifdef DLIB_JPEG_SUPPORT

#include "../../dlib/include/dlib/dlib/array2d.h"
#include "../../dlib/include/dlib/dlib/pixel.h"
#include "../../dlib/include/dlib/dlib/dir_nav.h"
#include "../../dlib/include/dlib/dlib/image_loader/jpeg_loader.h"
#include <stdio.h>
#ifdef DLIB_JPEG_STATIC
#   include "../../dlib/include/dlib/dlib/external/libjpeg/jpeglib.h"
#else
#   include <jpeglib.h>
#endif
#include <sstream>
#include <setjmp.h>
namespace dlib {
}