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
void PrintPhotos::printPhotos(const QString &photoPaths, int copyCount) {
    PrintThread *thread = new PrintThread(photoPaths, printerName(), saveFolder(), copyCount, this);
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
