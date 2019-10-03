#include "PrintPhotos.h"

PrintPhotos::PrintPhotos(QObject *parent) : QObject(parent)
{

}

QString PrintPhotos::getPrinterName(QString const &printerName) {
    QPrinter printer;

    QPrintDialog *dialog = new QPrintDialog(&printer);
    dialog->setWindowTitle("Print Document");

    if (dialog->exec() != QDialog::Accepted) return printerName;


    return printer.printerName();

}

// print in a new thread to prevent gui lag
void PrintPhotos::printPhoto(const QString &photoPath, int copyCount, bool printCanvas) {
    PrintThread *thread = new PrintThread(photoPath, printerName(), copyCount, printCanvas, this);
    connect(thread, SIGNAL(finished()), thread, SLOT(deleteLater()));
    thread->start();
}

QString PrintPhotos::saveFolder() {
    return m_saveFolder;
}

void PrintPhotos::setSaveFolder(const QString &saveFolder) {
    if (saveFolder == m_saveFolder)
        return;
    m_saveFolder = saveFolder;
}


QString PrintPhotos::printerName() {
    return m_printerName;
}

void PrintPhotos::setPrinterName(const QString &printerName) {
    if (printerName == m_printerName)
        return;
    m_printerName = printerName;
}



// ==================================================================


PrintThread::PrintThread(const QString &photoPath, const QString &printerName, int copyCount, bool printCanvas, QObject *parent)
    : QThread(parent), photoPath(photoPath), printerName(printerName), copyCount(copyCount), printCanvas(printCanvas)
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

    QSizeF qsize = printer.paperSize(QPrinter::DevicePixel);
    QList<int> supportedResolutions = printer.supportedResolutions();


    int res = supportedResolutions[supportedResolutions.length()-1];

    printer.setResolution(res);

    // debug prints
    qDebug() << "[PrintPhotos] Size:" << qsize;
//    qDebug() << printer.pageLayout().margins().top();
//    qDebug() << printer.pageLayout().margins().left();
    qDebug() << "[PrintPhotos] Resolution:" << printer.supportedResolutions();

//    qDebug() << photoPaths;
//    qDebug() << printerName;

    QPainter printerPainter;
    printerPainter.begin(&printer);
//    photoPath = "c:/Users/Vu/Pictures/PixylBooth/Prints/DSC05785_DSC05786_DSC05787.jpg";

    QImage photo(photoPath);
    QString canvasPath(photoPath.replace("/Prints/", "/Canvas/").replace(".jpg", ".png"));


    qDebug() << "[PrintPhotos] Printing" << photoPath;
    qDebug() << "[PrintPhotos] Copies:" << copyCount;
    qDebug() << "[PrintPhotos] Canvas:" << canvasPath;

    QImage photoScaled = photo.scaled(1820, 1230);
    printerPainter.drawImage(0, 0, photoScaled);

    if (printCanvas) {
        QImage canvasImage(canvasPath);
        QImage canvasImageScaled = canvasImage.scaled(1820, 1230);
        printerPainter.drawImage(0, 0, canvasImageScaled);
    }

    printerPainter.end();
}
