#include "CSVFile.h"

CSVFile::CSVFile(QObject *parent) : QObject(parent)
{

}


int CSVFile::countRow() {
    return 0;
}


void CSVFile::exportCSV(const QString &string) {
    qDebug() << string;
    QFile csvFile(m_saveFolder + "/EmailList.csv");

    if(csvFile.open( QIODevice::Append )) {
        // Create a text stream, which will write the data
        QTextStream textStream( &csvFile );
//        QStringList stringList; // The helper object QSqtringList, which will form a line

        textStream << string + "\n";

        csvFile.close();

    }
}


QString CSVFile::saveFolder() {
    return m_saveFolder;
}

void CSVFile::setSaveFolder(const QString &saveFolder) {
    if (saveFolder == m_saveFolder)
        return;
    m_saveFolder = saveFolder;
}
