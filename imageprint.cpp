#include "imageprint.h"

ImagePrint::ImagePrint(QObject *parent) : QObject(parent)
{

}



QString ImagePrint::getPrinterName() {
    QPrinter printer;

    QPrintDialog *dialog = new QPrintDialog(&printer);
    dialog->setWindowTitle("Print Document");

    if (dialog->exec() != QDialog::Accepted)
        return "";

    return printer.printerName();

}


void ImagePrint::printPhotos(const QString &photoPaths, const QString &printerName) {
    QPrinter printer(QPrinter::HighResolution);
    printer.setFullPage(true);
    printer.setOrientation(QPrinter::Landscape);
    printer.setResolution(300);
    printer.setPrinterName(printerName);

    QMarginsF margins(qreal(0), qreal(0), qreal(0), qreal(0));

    printer.setPageMargins(margins, QPageLayout::Millimeter);

    QPrintDialog *dialog = new QPrintDialog(&printer);
    dialog->setWindowTitle("Print Document");

    if (dialog->exec() != QDialog::Accepted)
        return;

    QSizeF qsize = printer.paperSize(QPrinter::DevicePixel);

//    qDebug() << qsize;
//    qDebug() << printer.pageLayout().margins().top();
//    qDebug() << printer.pageLayout().margins().left();
//    qDebug() << printer.supportedResolutions();

    qDebug() << photoPaths;
    qDebug() << printerName;

    QStringList photoPathsList = photoPaths.split(";");
    qDebug() << photoPathsList;

    QPainter printerPainter;
    printerPainter.begin(&printer);

    QImage templateBg("C:/Users/Vu/Pictures/dslrBooth/Templates/Mia Pham/background.png");
    QImage image1(photoPathsList[0]);
    QImage image2(photoPathsList[1]);
    QImage image3(photoPathsList[2]);

    // resize photos to fit template
    image1 = image1.scaledToWidth(1560);
    image2 = image2.scaledToWidth(1560);
    image3 = image3.scaledToWidth(1560);

    // create an empty 3600x2400 canvas
    QImage output(3600, 2400, QImage::Format_RGB32);

    // paint on output imagePainter
    QPainter imagePainter(&output);

    // draw photos
    imagePainter.drawImage(1869, 126, image1);
    imagePainter.drawImage(171, 1245, image2);
    imagePainter.drawImage(1866, 1248, image3);

    // draw template on top
    imagePainter.drawImage(0, 0, templateBg);

    // save output
    output.save("C:/Users/Vu/Pictures/dslrBooth/Templates/Mia Pham/background2.png");

    // scale output image to printer dimensions
    output = output.scaled(int(qsize.width()), int(qsize.height()));

    // paint output onton printer
    printerPainter.drawImage(0, 0, output);

    // print
    printerPainter.end();
}

QString ImagePrint::saveFolder() {
    return m_saveFolder;
}

void ImagePrint::setSaveFolder(const QString &saveFolder) {
    if (saveFolder == m_saveFolder)
        return;
    m_saveFolder = saveFolder;
}
