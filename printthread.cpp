#include "printthread.h"

PrintThread::PrintThread(const QString &photoPaths, const QString &printerName, const QString &saveFolder, int copyCount, QObject *parent)
    : QThread(parent), photoPaths(photoPaths), printerName(printerName), saveFolder(saveFolder), copyCount(copyCount)
{

}

void PrintThread::run() {
    QPrinter printer(QPrinter::HighResolution);
    printer.setFullPage(true);
    printer.setOrientation(QPrinter::Landscape);
    printer.setPrinterName(printerName);
    printer.setCopyCount(copyCount);

    QMarginsF margins(qreal(0), qreal(0), qreal(0), qreal(0));

    printer.setPageMargins(margins, QPageLayout::Millimeter);

//    QPrintDialog *dialog = new QPrintDialog(&printer);
//    dialog->setWindowTitle("Print Document");

//    if (dialog->exec() != QDialog::Accepted)
//        return;

    QSizeF qsize = printer.paperSize(QPrinter::DevicePixel);
    QList<int> supportedResolutions = printer.supportedResolutions();

    printer.setResolution(supportedResolutions[0]);

    // debug prints
    qDebug() << qsize;
//    qDebug() << printer.pageLayout().margins().top();
//    qDebug() << printer.pageLayout().margins().left();
    qDebug() << printer.supportedResolutions();

//    qDebug() << photoPaths;
    qDebug() << printerName;

    QStringList photoPathsList = photoPaths.split(";");
    qDebug() << photoPathsList;

    QPainter printerPainter;
    printerPainter.begin(&printer);

    QDir templateDir(photoPathsList[0]);
    QDir image1Dir(photoPathsList[1]);
    QDir image2Dir(photoPathsList[2]);
    QDir image3Dir(photoPathsList[3]);

    // define paths for images
    QImage templateImage(templateDir.absolutePath());
    QImage image1(image1Dir.absolutePath());
    QImage image2(image2Dir.absolutePath());
    QImage image3(image2Dir.absolutePath());

    qDebug() << image1Dir.dirName();

    // resize photos to fit template
    QImage image1Scaled = image1.scaledToWidth(1560);
    QImage image2Scaled = image2.scaledToWidth(1560);
    QImage image3Scaled = image3.scaledToWidth(1560);

    // create an empty 3600x2400 canvas
    QImage output(3600, 2400, QImage::Format_RGB32);

    // paint on output imagePainter
    QPainter imagePainter(&output);

    // draw photos
    imagePainter.drawImage(1869, 126, image1Scaled);
    imagePainter.drawImage(171, 1245, image2Scaled);
    imagePainter.drawImage(1866, 1248, image3Scaled);

    // draw template on top
    imagePainter.drawImage(0, 0, templateImage);

    // save output

    QString saveOutputPath = QString("%1/%2_%3_%4.png")
            .arg(saveFolder)
            .arg(image1Dir.dirName())
            .arg(image2Dir.dirName())
            .arg(image3Dir.dirName());

    output.save(saveOutputPath);

    // scale output image to printer dimensions
    QImage outputScaled = output.scaled(int(qsize.width()), int(qsize.height()));

    // paint output onto printer
    printerPainter.drawImage(0, 0, outputScaled);

    // print
    printerPainter.end();
}
