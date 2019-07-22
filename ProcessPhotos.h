#ifndef PROCESSPHOTOS_H
#define PROCESSPHOTOS_H

#include <QObject>
#include <QDebug>
#include <QDir>
#include <QImage>
#include <QPainter>
#include <QList>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QStringList>

class ProcessPhotos : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString saveFolder READ saveFolder WRITE setSaveFolder)
    Q_PROPERTY(QString templateFormat READ templateFormat WRITE setTemplateFormat)
    Q_PROPERTY(QString templatePath READ templatePath WRITE setTemplatePath)

public:
    explicit ProcessPhotos(QObject *parent = nullptr);

    QString saveFolder();
    void setSaveFolder(const QString &saveFolder);

    QString templateFormat();
    void setTemplateFormat(const QString &templateFormat);

    QString templatePath();
    void setTemplatePath(const QString &templatePath);

signals:

public slots:
    QString combine(const QString &photoPaths);
    void testTemplate();

private:
    QString m_saveFolder;
    QString m_templateFormat;
    QString m_templatePath;
    QJsonArray templateJsonArray;
    QStringList photoPathsList;

};

#endif // PROCESSPHOTOS_H
