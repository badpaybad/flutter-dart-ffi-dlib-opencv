
#include "../../android/app/src/main/cppLibs/dlib/include/dlib/dlib/image_processing/frontal_face_detector.h"
//#include "../../android/app/src/main/cppLibs/dlib/include/dlib/dlib/gui_widgets.h"
#include "../../android/app/src/main/cppLibs/dlib/include/dlib/dlib/image_io.h"
#include <iostream>
#include "../../android/app/src/main/cppLibs/dlib/include/dlib/dlib/dnn.h"
#include "../../android/app/src/main/cppLibs/dlib/include/dlib/dlib/data_io.h"
#include "../../android/app/src/main/cppLibs/dlib/include/dlib/dlib/image_processing.h"


using namespace dlib;
using namespace std;

int detect_face(){
    frontal_face_detector detector = get_frontal_face_detector();

    return 0;
}