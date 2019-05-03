#include "PrintPhotos.h"

PrintPhotos::PrintPhotos(QObject *parent) : QObject(parent)
{

}

QString PrintPhotos::getPrinterName() {
    QPrinter printer;

    QPrintDialog *dialog = new QPrintDialog(&printer);
    dialog->setWindowTitle("Print Document");

    if (dialog->exec() != QDialog::Accepted)
        return "";

    return printer.printerName();

}

// print in a new thread to prevent gui lag
void PrintPhotos::printPhotos(const QString &photoPath, int copyCount) {
    PrintThread *thread = new PrintThread(photoPath, printerName(), copyCount, this);
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


PrintThread::PrintThread(const QString &photoPath, const QString &printerName, int copyCount, QObject *parent)
    : QThread(parent), photoPath(photoPath), printerName(printerName), copyCount(copyCount)
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

    int res = supportedResolutions[0];

    printer.setResolution(res);

    // debug prints
    qDebug() << qsize;
//    qDebug() << printer.pageLayout().margins().top();
//    qDebug() << printer.pageLayout().margins().left();
    qDebug() << printer.supportedResolutions();

//    qDebug() << photoPaths;
//    qDebug() << printerName;

    QPainter printerPainter;
    printerPainter.begin(&printer);

    QImage photo(photoPath);

    qDebug() << photoPath;

    QImage photoScaled = photo.scaled(int(qsize.width()), int(qsize.height()));
    printerPainter.drawImage(0, 0, photoScaled);

    printerPainter.end();
}
