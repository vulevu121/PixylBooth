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
#include <QAbstractItemModel>
#include <QThread>

class ProcessPhotos : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString saveFolder READ getSaveFolder WRITE setSaveFolder)
    Q_PROPERTY(QString templateFormat READ getTemplateFormat WRITE setTemplateFormat)
    Q_PROPERTY(QString templatePath READ getTemplatePath WRITE setTemplatePath)
    Q_PROPERTY(QAbstractItemModel *model READ getModel WRITE setModel)
    Q_PROPERTY(bool portraitMode READ portraitMode WRITE setPortraitMode)

public:
    explicit ProcessPhotos(QObject *parent = nullptr);

    QString getSaveFolder();
    void setSaveFolder(const QString &saveFolder);

    QString getTemplateFormat();
    void setTemplateFormat(const QString &templateFormat);

    QString getTemplatePath();
    void setTemplatePath(const QString &templatePath);

    QAbstractItemModel *getModel();
    void setModel(QAbstractItemModel *model);

    bool portraitMode();
    void setPortraitMode(bool enable);


signals:
    void combineFinished(const QString &outputPath);
    void operate();

public slots:
    void combine();
    void emitCombineFinished(const QString &outputPath);

private:
    QString m_saveFolder;
    QString m_templateFormat;
    QString m_templatePath;
    QJsonArray templateJsonArray;
    QAbstractItemModel *m_model;
    bool m_portraitMode = false;
};


// ==================================================================

class CombineThread : public QThread
{
    Q_OBJECT

public:
    CombineThread(QObject *parent = nullptr);
    void run() override;

    QString m_saveFolder;
    QString m_templateFormat;
    QString m_templatePath;
    QJsonArray templateJsonArray;
    QAbstractItemModel *m_model;
    bool portraitMode = false;

signals:
    void combineFinished(const QString &outputPath);

public slots:


private:

};



#endif // PROCESSPHOTOS_H
