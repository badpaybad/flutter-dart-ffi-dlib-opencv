#ifndef DLIB_JPEG_SUPPORT
#define DLIB_JPEG_SUPPORT "ON"
#endif
#ifndef DLIB_PNG_SUPPORT
#define DLIB_PNG_SUPPORT "ON"
#endif

#include "dlib/include/dlib/dlib/image_processing/frontal_face_detector.h"
//#include "../../android/app/src/main/cppLibs/dlib/include/dlib/dlib/gui_widgets.h"
#include "dlib/include/dlib/dlib/image_io.h"
#include <iostream>
#include "dlib/include/dlib/dlib/dnn.h"
#include "dlib/include/dlib/dlib/data_io.h"
#include "dlib/include/dlib/dlib/image_processing.h"
#include "dlib/include/dlib/dlib/image_processing/frontal_face_detector.h"

using namespace dlib;

//using namespace std;
struct UnhandleException : public std::exception {
    std::string s;

    UnhandleException(std::string ss) : s(ss) {}

    ~UnhandleException() throw() {} // Updated
    const char *what() const throw() { return s.c_str(); }
};

template<long num_filters, typename SUBNET> using con5d = con<num_filters, 5, 5, 2, 2, SUBNET>;
template<long num_filters, typename SUBNET> using con5 = con<num_filters, 5, 5, 1, 1, SUBNET>;

template<typename SUBNET> using downsampler = relu<affine<con5d<32, relu<affine<con5d<32, relu<affine<con5d<16, SUBNET>>>>>>>>>;
template<typename SUBNET> using rcon5 = relu<affine<con5<45, SUBNET>>>;

using net_type = loss_mmod<con<1, 9, 9, 1, 1, rcon5<rcon5<rcon5<downsampler<input_rgb_image_pyramid<pyramid_down<6>>>>>>>>;

static net_type net;
static int _is_model_loaded = 0;

static frontal_face_detector frontal_detector = get_frontal_face_detector();

extern "C" __attribute__((visibility("default"))) __attribute__((used))
void detect_face_load_model(char *file_path) {
    if (_is_model_loaded == 1) return;
    /* cout << "Call this program like this:" << endl;
        cout << "./dnn_mmod_face_detection_ex mmod_human_face_detector.dat faces/*.jpg" << endl;
        cout << "\nYou can get the mmod_human_face_detector.dat file from:\n";
        cout << "http://dlib.net/files/mmod_human_face_detector.dat.bz2" << endl;*/
    ///work/flutter-dart-ffi-dlib-opencv/assets/weights/mmod_human_face_detector.dat

    deserialize(std::string(file_path)) >> net;
    _is_model_loaded = 1;
}

extern "C" __attribute__((visibility("default"))) __attribute__((used))
char *detect_face(char *file_path) {
    if (_is_model_loaded == 0) {
        throw UnhandleException(
                "Model did not load, call detect_face_load_model(...) with args file path: mmod_human_face_detector.dat");
    }
    //http://dlib.net/dnn_mmod_face_detection_ex.cpp.html
    //http://dlib.net/face_landmark_detection_ex.cpp.html
    //http://dlib.net/dnn_face_recognition_ex.cpp.html
    //frontal_face_detector detector = get_frontal_face_detector();
    /*
        // Upsampling the image will allow us to detect smaller faces but will cause the
        // program to use more RAM and run longer.*/
    matrix<rgb_pixel> img;
    //"/work/flutter-dart-ffi-dlib-opencv/assets/weights/dunp.jpg"

    const std::string fileimg = std::string(file_path);
    load_image(img, fileimg);


    while (img.size() < 1800 * 1800) { pyramid_up(img); }
    /*
     *   // Note that you can process a bunch of images in a std::vector at once and it runs
        // much faster, since this will form mini-batches of images and therefore get
        // better parallelism out of your GPU hardware.  However, all the images must be
        // the same size.  To avoid this requirement on images being the same size we
        // process them individually in this example.*/

    auto dets = net(img);

    //return std::string(dets).c_str();
    return "";
}

extern "C" __attribute__((visibility("default"))) __attribute__((used))

char *detect_face_cpu(char *file_path) {
    array2d<unsigned char> img;
    load_image(img, file_path);
    // Make the image bigger by a factor of two.  This is useful since
    // the face detector looks for faces that are about 80 by 80 pixels
    // or larger.  Therefore, if you want to find faces that are smaller
    // than that then you need to upsample the image as we do here by
    // calling pyramid_up().  So this will allow it to detect faces that
    // are at least 40 by 40 pixels in size.  We could call pyramid_up()
    // again to find even smaller faces, but note that every time we
    // upsample the image we make the detector run slower since it must
    // process a larger image.
    pyramid_up(img);
    // Now tell the face detector to give us a list of bounding boxes
    // around all the faces it can find in the image.
    std::vector<rectangle> dets = frontal_detector(img);
    //std::cout << "Number of faces detected: " << dets.size() << std::endl;
    char *res = (std::string("Number of faces detected: ") +std::to_string(dets.size()).c_str();

    //throw UnhandleException(std::string(res));

    return (char *) res;
}