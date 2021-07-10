
#include <iostream>

#include <QApplication>
#if defined(__linux__)
    #include <experimental/filesystem>  // Not implemented until g++8
    namespace fs = std::experimental::filesystem;
#elif defined(_WIN32)
    #include <filesystem>
    namespace fs = std::filesystem;
#endif

#include <QMediaPlayer>
#include <QHBoxLayout>
#include <QVBoxLayout>
#include <QLabel>
#include <QPushButton>
#include <QWidget>

#include <opencv2/opencv.hpp>

int main(int _argc, char** _argv){
    
    QApplication app(_argc, _argv);

    fs::path p = _argv[0];
    #if defined(__linux__)
        fs::path parentPath = std::getenv("APPDIR");
    #else
        fs::path parentPath = p.parent_path()/"..";
    #endif
    std::string musicPath = (parentPath/"Resources"/"music.mp3").string();
    std::string imgPath = (parentPath/"Resources"/"rappersdelight.png").string();
    if(musicPath.find("MacOS") != musicPath.npos){
        musicPath = (parentPath.parent_path()/"Resources"/"music.mp3").string();
        imgPath = (parentPath.parent_path()/"Resources"/"rappersdelight.png").string();
    }

    QMediaPlayer *player = new QMediaPlayer();
    player->setVolume(50);
    QString qpath = musicPath.c_str();
    player->setMedia(QUrl::fromLocalFile(qpath));

    QPushButton *btPlay = new QPushButton("Play");
    QObject::connect(btPlay, &QPushButton::clicked,[&](){ player->play(); });
    QPushButton *btPause = new QPushButton("Pause");
    QObject::connect(btPause, &QPushButton::clicked,[&](){ player->pause(); });
    QPushButton *btStop = new QPushButton("Stop");
    QObject::connect(btStop, &QPushButton::clicked,[&](){ player->stop(); });

    QWidget *cw = new QWidget;
    QVBoxLayout *lp = new QVBoxLayout;
    cw->setLayout(lp);
    cv::Mat image = cv::imread(imgPath.c_str());
    if (image.rows != 0) {
        QImage qimg;
        if (image.channels() == 1) {
            qimg = QImage(image.data, image.cols, image.rows, QImage::Format_Grayscale8);
        } else if (image.channels() == 3) {
            qimg = QImage(image.data, image.cols, image.rows, image.step, QImage::Format_RGB888).rgbSwapped();
        } else if (image.channels() == 4) {
            qimg = QImage(image.data, image.cols, image.rows, image.step, QImage::Format_RGBA8888).rgbSwapped();
        }
        QLabel *img = new QLabel;
        img->setPixmap(QPixmap::fromImage(qimg));
        lp->addWidget(img);
    }

    QHBoxLayout *l = new QHBoxLayout;
    lp->addLayout(l);
    l->addWidget(btPlay);
    l->addWidget(btPause);
    l->addWidget(btStop);

    cw->show();

    return app.exec();
}