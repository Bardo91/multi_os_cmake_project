
#include <iostream>
#include <opencv2/opencv.hpp>
#include <filesystem>


int main(int _argc, char** _argv){
    std::filesystem::path p = _argv[0];
    auto parentPath = p.parent_path();
    auto imgPath = parentPath/"Resources"/"sfdk.jpg";
    auto img = cv::imread(imgPath.string());

    cv::imshow("Siempre Fuertes De Konziencia", img);
    cv::waitKey();
}