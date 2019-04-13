#include "imageprint.h"
#include "printThread.h"

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

// print in a new thread to prevent gui lag
void ImagePrint::printPhotos(const QString &photoPaths, const QString &printerName, const QString &saveFolder) {
    PrintThread *thread = new PrintThread(photoPaths, printerName, saveFolder, this);
    connect(thread, SIGNAL(finished()), thread, SLOT(deleteLater()));
    thread->start();
}

//QString ImagePrint::saveFolder() {
//    return m_saveFolder;
//}

//void ImagePrint::setSaveFolder(const QString &saveFolder) {
//    if (saveFolder == m_saveFolder)
//        return;
//    m_saveFolder = saveFolder;
//}

