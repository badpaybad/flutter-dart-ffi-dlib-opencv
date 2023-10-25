
#include "../../android/app/src/main/cppLibs/dlib/include/dlib/dlib/image_processing/frontal_face_detector.h"
//#include "../../android/app/src/main/cppLibs/dlib/include/dlib/dlib/gui_widgets.h"
#include "../../android/app/src/main/cppLibs/dlib/include/dlib/dlib/image_io.h"
#include <iostream>
#include "../../android/app/src/main/cppLibs/dlib/include/dlib/dlib/dnn.h"
#include "../../android/app/src/main/cppLibs/dlib/include/dlib/dlib/data_io.h"
#include "../../android/app/src/main/cppLibs/dlib/include/dlib/dlib/image_processing.h"


using namespace dlib;
using namespace std;

template <long num_filters, typename SUBNET> using con5d = con<num_filters,5,5,2,2,SUBNET>;
template <long num_filters, typename SUBNET> using con5  = con<num_filters,5,5,1,1,SUBNET>;

template <typename SUBNET> using downsampler  = relu<affine<con5d<32, relu<affine<con5d<32, relu<affine<con5d<16,SUBNET>>>>>>>>>;
template <typename SUBNET> using rcon5  = relu<affine<con5<45,SUBNET>>>;

using net_type = loss_mmod<con<1,9,9,1,1,rcon5<rcon5<rcon5<downsampler<input_rgb_image_pyramid<pyramid_down<6>>>>>>>>;

void detect_face(){
    //http://dlib.net/dnn_mmod_face_detection_ex.cpp.html
    //http://dlib.net/face_landmark_detection_ex.cpp.html
    //http://dlib.net/dnn_face_recognition_ex.cpp.html
    //frontal_face_detector detector = get_frontal_face_detector();

    /* cout << "Call this program like this:" << endl;
        cout << "./dnn_mmod_face_detection_ex mmod_human_face_detector.dat faces/*.jpg" << endl;
        cout << "\nYou can get the mmod_human_face_detector.dat file from:\n";
        cout << "http://dlib.net/files/mmod_human_face_detector.dat.bz2" << endl;*/
    ///work/flutter-dart-ffi-dlib-opencv/assets/weights/mmod_human_face_detector.dat

    net_type net;
    deserialize("work/flutter-dart-ffi-dlib-opencv/assets/weights/mmod_human_face_detector.dat") >> net;
    /*
        // Upsampling the image will allow us to detect smaller faces but will cause the
        // program to use more RAM and run longer.*/
    matrix<rgb_pixel> img;
    load_image(img, "/work/flutter-dart-ffi-dlib-opencv/assets/weights/dunp.jpg");
    while(img.size() < 1800*1800)
        pyramid_up(img);
    /*
     *   // Note that you can process a bunch of images in a std::vector at once and it runs
        // much faster, since this will form mini-batches of images and therefore get
        // better parallelism out of your GPU hardware.  However, all the images must be
        // the same size.  To avoid this requirement on images being the same size we
        // process them individually in this example.*/
    auto dets = net(img);

}