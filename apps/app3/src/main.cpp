
#include <iostream>
#include <opencv2/opencv.hpp>
#include <filesystem>


int main(int _argc, char** _argv){
    std::filesystem::path p = _argv[0];
    auto parentPath = p.parent_path();
    auto imgPath = parentPath/"Resources"/"sfdk.jpg";
    std::cout << imgPath.string() << std::endl;
    auto img = cv::imread(imgPath.string());
    if(img.rows >= 0){
        cv::imshow("Siempre Fuertes De Konziencia", img);
        cv::waitKey();
    }
}