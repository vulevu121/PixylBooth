#include <QCoreApplication>
#include <QtCore>
#include <QtWidgets>
#include "googlephotoqueu.h"
#include "googleoauth2.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);


    GooglePhotoQueu q;

    return app.exec();
}


