#ifndef CSVFILE_H
#define CSVFILE_H

#include <QObject>
#include <QFile>
#include <QTextStream>
#include <QDebug>

class CSVFile : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString saveFolder READ saveFolder WRITE setSaveFolder)
public:
    explicit CSVFile(QObject *parent = nullptr);
    QString saveFolder();
    void setSaveFolder(const QString &saveFolder);

signals:

public slots:
    void exportCSV(const QString &string);

private:
    int countRow();
    QString m_saveFolder;
};

#endif // CSVFILE_H
