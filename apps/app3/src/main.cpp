
#include <iostream>
#include <opencv2/opencv.hpp>
#include <filesystem>


int main(int _argc, char** _argv){
    std::filesystem::path p = _argv[0];
    auto parentPath = p.parent_path();
    auto imgPath = (parentPath/"Resources"/"sfdk.jpg").string();

    if(imgPath.find("MacOS") != imgPath.npos){
        // Structure in MacOS is
        // Content  / MacOS / app3
        //          / Resources / sfdk.jpg
        imgPath = (parentPath.parent_path()/"Resources"/"sfdk.jpg").string();
    }

    std::cout << imgPath << std::endl;
    auto img = cv::imread(imgPath);
    if(img.rows >= 0){
        cv::imshow("Siempre Fuertes De Konziencia", img);
        cv::waitKey();
    }
}