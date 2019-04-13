#include "printphotos.h"
#include "printthread.h"

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
void PrintPhotos::printPhotos(const QString &photoPaths, const QString &printerName, const QString &saveFolder, int copyCount) {
    PrintThread *thread = new PrintThread(photoPaths, printerName, saveFolder, copyCount, this);
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

