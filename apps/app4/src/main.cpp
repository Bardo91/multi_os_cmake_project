
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
#include <QPushButton>
#include <QWidget>

int main(int _argc, char** _argv){
    
    QApplication app(_argc, _argv);

    fs::path p = _argv[0];
    auto parentPath = p.parent_path();
    std::string musicPath = (parentPath/"Resources"/"music.mp3").string();
    if(musicPath.find("MacOS") != musicPath.npos){
        musicPath = (parentPath.parent_path()/"Resources"/"music.mp3").string();
    }

    QMediaPlayer *player = new QMediaPlayer();
    player->setVolume(50);
    QString qpath = musicPath.c_str();
    player->setMedia(QUrl::fromLocalFile(qpath));

    QWidget *cw = new QWidget;
    QPushButton *btPlay = new QPushButton("Play");
    QObject::connect(btPlay, &QPushButton::clicked,[&](){ player->play(); });
    QPushButton *btPause = new QPushButton("Pause");
    QObject::connect(btPause, &QPushButton::clicked,[&](){ player->pause(); });
    QPushButton *btStop = new QPushButton("Stop");
    QObject::connect(btStop, &QPushButton::clicked,[&](){ player->stop(); });

    QHBoxLayout *l = new QHBoxLayout;
    cw->setLayout(l);
    l->addWidget(btPlay);
    l->addWidget(btPause);
    l->addWidget(btStop);

    cw->show();

    return app.exec();
}