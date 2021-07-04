
#include <iostream>

#include <QApplication>

#include <QLabel>

int main(int _argc, char** _argv){
    
    QApplication app(_argc, _argv);

    QLabel label(   "YEAH, I am app 2 and I rap too!\n"
                    "Yeah, uh huh, you know what it is (what it is) \n"
                    "Everything I do, I do it big \n"
                    "Yeah, uh huh, screamin' that's nothin' \n"
                    "What I pulled off the lot, that's stuntin' \n"
                    "Reppin' my town when you see me you know everything \n"
                    "Black and yellow \n"
                    "Black and yellow\n");
    label.show();

    return app.exec();
}