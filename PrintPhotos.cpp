#include "PrintPhotos.h"

PrintPhotos::PrintPhotos(QObject *parent) : QObject(parent)
{

}

QString PrintPhotos::saveFolder() {
    return m_saveFolder;
}

void PrintPhotos::setSaveFolder(const QString &saveFolder) {
    if (saveFolder != m_saveFolder)
        m_saveFolder = saveFolder;
}


QString PrintPhotos::printerName() {
    return m_printerName;
}

void PrintPhotos::setPrinterName(const QString &printerName) {
    if (printerName != m_printerName)
        m_printerName = printerName;
}

QString PrintPhotos::paperName() {
    return m_paperName;
}

void PrintPhotos::setPaperName(const QString &paperName) {
    if (paperName != m_paperName)
        m_paperName = paperName;
}

QString PrintPhotos::getPrinterSettings(QString const &printerName) {
    QPrinter printer;

    QPrintDialog *dialog = new QPrintDialog(&printer);
    dialog->setWindowTitle("Print Document");

    if (dialog->exec() != QDialog::Accepted) return printerName;

    m_printerName = printer.printerName();
    m_paperName = printer.paperName();
//    QSettings *settings = new QSettings("Pixyl", "PixylBooth");
//    settings->setValue("/Printer/paperName", m_paperName);
    return printer.printerName();
}

// print in a new thread to prevent gui lag
void PrintPhotos::printPhoto(const QString &photoPath, int copyCount, bool printCanvas) {
    PrintThread *thread = new PrintThread(this);
    thread->photoPath = photoPath;
    thread->saveFolder = m_saveFolder;
    thread->copyCount = copyCount;
    thread->printCanvas = printCanvas;
    thread->printerName = m_printerName;
    connect(thread, &PrintThread::finished, thread, &PrintThread::deleteLater);
    thread->start();
}


// ==================================================================


PrintThread::PrintThread(QObject *parent)
    : QThread(parent)
{

}

void PrintThread::run() {
    QImage photo(photoPath);
    QString canvasPath(photoPath.replace("/Prints/", "/Canvas/").replace(".jpg", ".png"));

    QPrinter printer(QPrinter::HighResolution);
    printer.setFullPage(true);
    printer.setPrinterName(printerName);
    printer.setCopyCount(copyCount);

    if (photo.width() <= 1250 && photo.height() <= 3650) {
        printer.setOrientation(QPrinter::Portrait);
        printer.setPaperName("6x4-Split (6x2 2 prints)");
    }
    else {
        printer.setOrientation(QPrinter::Landscape);
        printer.setPaperName("6x4 / 152x100mm");
    }



    QMarginsF margins(qreal(0), qreal(0), qreal(0), qreal(0));

    printer.setPageMargins(margins, QPageLayout::Millimeter);

    QSizeF qsize = printer.paperSize(QPrinter::DevicePixel);
    QList<int> supportedResolutions = printer.supportedResolutions();

    int res = supportedResolutions[supportedResolutions.length()-1];

    printer.setResolution(res);
    qDebug() << "[PrintPhotos] Size:" << qsize;
    qDebug() << "[PrintPhotos] Resolution:" << printer.supportedResolutions();

    QPainter printerPainter;
    printerPainter.begin(&printer);

    qDebug() << "[PrintPhotos] Printing" << photoPath;
    qDebug() << "[PrintPhotos] Copies:" << copyCount;
    qDebug() << "[PrintPhotos] Canvas:" << canvasPath;

    if (photo.width() <= 1250 && photo.height() <= 3650) {
        QImage photoScaled = photo.scaled(615, 1820);
        printerPainter.drawImage(0, 0, photoScaled);
        printerPainter.drawImage(615, 0, photoScaled);
    }
    else {
        QImage photoScaled = photo.scaled(1820, 1230);
        printerPainter.drawImage(0, 0, photoScaled);
    }


    if (printCanvas) {
        QImage canvasImage(canvasPath);
        QImage canvasImageScaled = canvasImage.scaled(1820, 1230);
        printerPainter.drawImage(0, 0, canvasImageScaled);
    }

    printerPainter.end();
}
