
#include "gphoto_gmail.h"
#include <QCoreApplication>
#include <QtCore>
#include <QtWidgets>

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    GooglePhoto p;
    return app.exec();
}
