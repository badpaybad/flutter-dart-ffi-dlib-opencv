#ifndef DLIB_JPEG_SUPPORT
#define DLIB_JPEG_SUPPORT "ON"
#endif
#ifndef DLIB_PNG_SUPPORT
#define DLIB_PNG_SUPPORT "ON"
#endif

#include<time.h>
#include <unistd.h>
#include <fcntl.h>
#include <termios.h>

#include <stdio.h>
#include <stdint.h>
#include <ctype.h>

#include <string.h>
#include <ctype.h>
#include <stdlib.h>
#include <iostream>
#include <cstdio>
#include <istream>

#include "dlib/include/dlib/dlib/image_processing/frontal_face_detector.h"
//#include "../../android/app/src/main/cppLibs/dlib/include/dlib/dlib/gui_widgets.h"
#include "dlib/include/dlib/dlib/clustering.h"
#include "dlib/include/dlib/dlib/string.h"
#include "dlib/include/dlib/dlib/image_io.h"
#include "dlib/include/dlib/dlib/dnn.h"
#include "dlib/include/dlib/dlib/data_io.h"
#include "dlib/include/dlib/dlib/image_processing.h"
#include "dlib/include/dlib/dlib/image_processing/frontal_face_detector.h"

using namespace dlib;

// ref : https://learnopencv.com/install-opencv-on-android-tiny-and-optimized/
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

//---------------------------------------------------------


// ----------------------------------------------------------------------------------------

// The next bit of code defines a ResNet network.  It's basically copied
// and pasted from the dnn_imagenet_ex.cpp example, except we replaced the loss
// layer with loss_metric and made the network somewhat smaller.  Go read the introductory
// dlib DNN examples to learn what all this stuff means.
//
// Also, the dnn_metric_learning_on_images_ex.cpp example shows how to train this network.
// The dlib_face_recognition_resnet_model_v1 model used by this example was trained using
// essentially the code shown in dnn_metric_learning_on_images_ex.cpp except the
// mini-batches were made larger (35x15 instead of 5x5), the iterations without progress
// was set to 10000, and the training dataset consisted of about 3 million images instead of
// 55.  Also, the input layer was locked to images of size 150.
template <template <int,template<typename>class,int,typename> class block, int N, template<typename>class BN, typename SUBNET>
using residual = add_prev1<block<N,BN,1,tag1<SUBNET>>>;

template <template <int,template<typename>class,int,typename> class block, int N, template<typename>class BN, typename SUBNET>
using residual_down = add_prev2<avg_pool<2,2,2,2,skip1<tag2<block<N,BN,2,tag1<SUBNET>>>>>>;

template <int N, template <typename> class BN, int stride, typename SUBNET>
using block  = BN<con<N,3,3,1,1,relu<BN<con<N,3,3,stride,stride,SUBNET>>>>>;

template <int N, typename SUBNET> using ares      = relu<residual<block,N,affine,SUBNET>>;
template <int N, typename SUBNET> using ares_down = relu<residual_down<block,N,affine,SUBNET>>;

template <typename SUBNET> using alevel0 = ares_down<256,SUBNET>;
template <typename SUBNET> using alevel1 = ares<256,ares<256,ares_down<256,SUBNET>>>;
template <typename SUBNET> using alevel2 = ares<128,ares<128,ares_down<128,SUBNET>>>;
template <typename SUBNET> using alevel3 = ares<64,ares<64,ares<64,ares_down<64,SUBNET>>>>;
template <typename SUBNET> using alevel4 = ares<32,ares<32,ares<32,SUBNET>>>;

using anet_type = loss_metric<fc_no_bias<128,avg_pool_everything<
        alevel0<
                alevel1<
                        alevel2<
                                alevel3<
                                        alevel4<
                                                max_pool<3,3,2,2,relu<affine<con<32,7,7,2,2,
                                                        input_rgb_image_sized<150>
                                                >>>>>>>>>>>>;


// ----------------------------------------------------------------------------------------

std::vector<matrix<rgb_pixel>> jitter_image(
        const matrix<rgb_pixel>& img
)
{
    // All this function does is make 100 copies of img, all slightly jittered by being
    // zoomed, rotated, and translated a little bit differently. They are also randomly
    // mirrored left to right.
    thread_local dlib::rand rnd;

    std::vector<matrix<rgb_pixel>> crops;
    for (int i = 0; i < 100; ++i)
        crops.push_back(jitter_image(img,rnd));

    return crops;
}

// ----------------------------------------------------------------------------------------


// ----------------------------------------------------------------------------------------
static shape_predictor sp_5facechip;
static shape_predictor sp_68facechip;
static anet_type net_recognition;
static net_type net_detect;
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

    deserialize(std::string(file_path)) >> net_detect;
    _is_model_loaded = 1;
}

extern "C" __attribute__((visibility("default"))) __attribute__((used))
void detect_5facechip_load_model(char *file_path) {
    //cout << "http://dlib.net/files/shape_predictor_5_face_landmarks.dat.bz2" << endl;
    /* cout << "Call this program like this:" << endl;
        cout << "./dnn_mmod_face_detection_ex mmod_human_face_detector.dat faces/*.jpg" << endl;
        cout << "\nYou can get the mmod_human_face_detector.dat file from:\n";
        cout << "http://dlib.net/files/mmod_human_face_detector.dat.bz2" << endl;*/
    ///work/flutter-dart-ffi-dlib-opencv/assets/weights/mmod_human_face_detector.dat

    deserialize(std::string(file_path)) >> sp_5facechip;

}

extern "C" __attribute__((visibility("default"))) __attribute__((used))
void detect_68facechip_load_model(char *file_path) {
    //cout << "http://dlib.net/files/shape_predictor_68_face_landmarks.dat.bz2" << endl;
    /* cout << "Call this program like this:" << endl;
        cout << "./dnn_mmod_face_detection_ex mmod_human_face_detector.dat faces/*.jpg" << endl;
        cout << "\nYou can get the mmod_human_face_detector.dat file from:\n";
        cout << "http://dlib.net/files/mmod_human_face_detector.dat.bz2" << endl;*/
    ///work/flutter-dart-ffi-dlib-opencv/assets/weights/mmod_human_face_detector.dat

    deserialize(std::string(file_path)) >> sp_68facechip;

}

extern "C" __attribute__((visibility("default"))) __attribute__((used))
void recognition_face_load_model(char *file_path) {
    //cout << "http://dlib.net/files/dlib_face_recognition_resnet_model_v1.dat.bz2" << endl;
    /* cout << "Call this program like this:" << endl;
        cout << "./dnn_mmod_face_detection_ex mmod_human_face_detector.dat faces/*.jpg" << endl;
        cout << "\nYou can get the mmod_human_face_detector.dat file from:\n";
        cout << "http://dlib.net/files/mmod_human_face_detector.dat.bz2" << endl;*/
    ///work/flutter-dart-ffi-dlib-opencv/assets/weights/mmod_human_face_detector.dat

    deserialize(std::string(file_path)) >> net_recognition;

}

//https://flutter.dev/docs/development/platform-integration/c-interop
extern "C" __attribute__((visibility("default"))) __attribute__((used))
long **detect_face(char *file_path, int pyramid_up_count) {
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


    //while (img.size() < 1800 * 1800) { pyramid_up(img); }
    for (int i = 0; i < pyramid_up_count; i++) {
        pyramid_up(img);
    }
    /*
     *   // Note that you can process a bunch of images in a std::vector at once and it runs
        // much faster, since this will form mini-batches of images and therefore get
        // better parallelism out of your GPU hardware.  However, all the images must be
        // the same size.  To avoid this requirement on images being the same size we
        // process them individually in this example.*/

    std::vector<dlib::mmod_rect> dets = net_detect (img);
    int numRows = dets.size() + 1;
    int numCols = 4;
    long **listBbox = (long **) malloc(numRows * sizeof(long *));
    listBbox[0] = (long *) malloc(numCols * sizeof(long));
    listBbox[0][0] = static_cast<long>(numRows);
    listBbox[0][1] = static_cast<long>(numCols);
    listBbox[0][2] = static_cast<long>(img.nr());
    listBbox[0][3] = static_cast<long>(img.nc());
    for (int i = 1; i < numRows; i++) {
        dlib::mmod_rect mbbox = dets[i - 1];
        dlib::rectangle bbox = mbbox.rect;
        listBbox[i] = (long *) malloc(numCols * sizeof(long));
        listBbox[i][0] = static_cast<long>(bbox.top());
        listBbox[i][1] = static_cast<long>(bbox.left());
        listBbox[i][2] = static_cast<long>(bbox.width());
        listBbox[i][3] = static_cast<long>(bbox.height());
    }
    return listBbox;
}

class MemoryBuffer : public std::streambuf {
public:
    MemoryBuffer(uint8_t* data, size_t length) {
        setg(reinterpret_cast<char*>(data), reinterpret_cast<char*>(data), reinterpret_cast<char*>(data) + length);
    }
};

class MemoryStream : public std::istream {
public:
    MemoryStream(uint8_t* data, size_t length) : std::istream(&buffer), buffer(data, length) {}
private:
    MemoryBuffer buffer;
};


extern "C" __attribute__((visibility("default"))) __attribute__((used))
long **detect_face_from_bmp_array(uint8_t *data,size_t data_size, int32_t width, int32_t height, int pyramid_up_count) {
    if (_is_model_loaded == 0) {
        throw UnhandleException(
                "Model did not load, call detect_face_load_model(...) with args file path: mmod_human_face_detector.dat");
    }

//    std::string aa("");
//
//    for(int i=0;i< data_size;i++){
//        aa.append(std::to_string(data[i]))        ;
//        aa.append(",");
//    }
//
//    throw UnhandleException(aa);

    MemoryStream dataStream(data, data_size);

    matrix<rgb_pixel> img;
    load_bmp(img,dataStream);
//
//    free(mem_file);

    //while (img.size() < 1800 * 1800) { pyramid_up(img); }
    for (int i = 0; i < pyramid_up_count; i++) {
        pyramid_up(img);
    }
    /*
     *   // Note that you can process a bunch of images in a std::vector at once and it runs
        // much faster, since this will form mini-batches of images and therefore get
        // better parallelism out of your GPU hardware.  However, all the images must be
        // the same size.  To avoid this requirement on images being the same size we
        // process them individually in this example.*/

    std::vector<dlib::mmod_rect> dets = net_detect (img);
    int numRows = dets.size() + 1;
    int numCols = 4;
    long **listBbox = (long **) malloc(numRows * sizeof(long *));
    listBbox[0] = (long *) malloc(numCols * sizeof(long));
    listBbox[0][0] = static_cast<long>(numRows);
    listBbox[0][1] = static_cast<long>(numCols);
    listBbox[0][2] = static_cast<long>(img.nr());
    listBbox[0][3] = static_cast<long>(img.nc());
    for (int i = 1; i < numRows; i++) {
        dlib::mmod_rect mbbox = dets[i - 1];
        dlib::rectangle bbox = mbbox.rect;
        listBbox[i] = (long *) malloc(numCols * sizeof(long));
        listBbox[i][0] = static_cast<long>(bbox.top());
        listBbox[i][1] = static_cast<long>(bbox.left());
        listBbox[i][2] = static_cast<long>(bbox.width());
        listBbox[i][3] = static_cast<long>(bbox.height());
    }
    return listBbox;
}
extern "C" __attribute__((visibility("default"))) __attribute__((used))
long **detect_face_cpu(char *file_path, int pyramid_up_count) {
    array2d<unsigned char> img;
//    auto ms0=(float )(clock()/CLOCKS_PER_SEC);
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
//    auto ms1=(float )(clock()/CLOCKS_PER_SEC);
    for (int i = 0; i < pyramid_up_count; i++) {
        pyramid_up(img);
    }

//    auto ms2=(float )(clock()/CLOCKS_PER_SEC);
    // Now tell the face detector to give us a list of bounding boxes
    // around all the faces it can find in the image.
    std::vector<dlib::rectangle> dets = frontal_detector(img);
//    auto ms3=(float )(clock()/CLOCKS_PER_SEC);
    //std::cout << "Number of faces detected: " << dets.size() << std::endl;
//    auto res= std::string("Number of faces detected: ");
//    res.append(std::to_string(dets.size()));
//    char *cstr = new char[res.length() + 1];
//    strcpy(cstr, res.c_str());
    int numRows = dets.size() + 1;
    int numCols = 4;
    long **listBbox = (long **) malloc(numRows * sizeof(long *));
    listBbox[0] = (long *) malloc(numCols * sizeof(long));
    listBbox[0][0] = static_cast<long>(numRows);
    listBbox[0][1] = static_cast<long>(numCols);
    listBbox[0][2] = static_cast<long>(img.nr());
    listBbox[0][3] = static_cast<long>(img.nc());
    for (int i = 1; i < numRows; i++) {
        auto bbox = dets[i - 1];
        listBbox[i] = (long *) malloc(numCols * sizeof(long));
        listBbox[i][0] = static_cast<long>(bbox.top());
        listBbox[i][1] = static_cast<long>(bbox.left());
        listBbox[i][2] = static_cast<long>(bbox.width());
        listBbox[i][3] = static_cast<long>(bbox.height());
    }
//    auto ms4=(float )(clock()/CLOCKS_PER_SEC);
//
//    auto xxx=std::to_string( ms1-ms0);
//    xxx.append(" loaded img, ");
//    xxx.append(std::to_string( ms2-ms1));
//    xxx.append(" pyramid, ");
//    xxx.append(std::to_string( ms3-ms2));
//    xxx.append(" detect, ");
//    xxx.append(std::to_string( ms4-ms3));
//    xxx.append(" listBbox, ");
//
//    throw UnhandleException(xxx);
    return listBbox;
}

extern "C" __attribute__((visibility("default"))) __attribute__((used))
void free_detect_face_cpu(long **matrix) {
    if (matrix == nullptr) return;

    for (int i = 0; matrix[i] != nullptr; i++) {
        free(matrix[i]);
    }
    free(matrix);
}

extern "C" __attribute__((visibility("default"))) __attribute__((used))
char *test_string_paramUTF8_returnUTF8(char *inputText) {
    return inputText;
}
