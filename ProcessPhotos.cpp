#include "ProcessPhotos.h"

ProcessPhotos::ProcessPhotos(QObject *parent) :
    QObject(parent)
{
}


QString ProcessPhotos::getSaveFolder() {
    return m_saveFolder;
}

void ProcessPhotos::setSaveFolder(const QString &saveFolder) {
    if (saveFolder == m_saveFolder)
        return;
    m_saveFolder = saveFolder;

    QDir saveDir(m_saveFolder);

    if (!saveDir.exists()) {
        saveDir.mkdir(m_saveFolder);
    }
}

QString ProcessPhotos::getTemplateFormat() {
    return m_templateFormat;
}

void ProcessPhotos::setTemplateFormat(const QString &templateFormat) {
    if (templateFormat == m_templateFormat)
        return;
    m_templateFormat = templateFormat;

    QJsonDocument doc = QJsonDocument::fromJson(m_templateFormat.toUtf8());
    templateJsonArray = doc.array();

}

QString ProcessPhotos::getTemplatePath() {
    return m_templatePath;
}

void ProcessPhotos::setTemplatePath(const QString &templatePath) {
    if (templatePath == m_templatePath)
        return;
    m_templatePath = templatePath;
}

QAbstractItemModel* ProcessPhotos::getModel() {
    return m_model;
}

void ProcessPhotos::setModel(QAbstractItemModel *model) {
    if (model != m_model) {
        m_model = model;
    }
}

bool ProcessPhotos::portraitMode()
{
    return m_portraitMode;
}

void ProcessPhotos::setPortraitMode(bool enable)
{
    if (enable != m_portraitMode) {
        m_portraitMode = enable;
    }
}

void ProcessPhotos::emitCombineFinished(const QString &outputPath) {
    emit combineFinished(outputPath);
}

void ProcessPhotos::combine() {
    CombineThread *thread = new CombineThread(this);
    thread->m_saveFolder = m_saveFolder;
    thread->m_templatePath = m_templatePath;
    thread->m_templateFormat = m_templateFormat;
    thread->templateJsonArray = templateJsonArray;
    thread->portraitMode = m_portraitMode;
    thread->m_model = m_model;
    connect(thread, &CombineThread::finished, thread, &CombineThread::deleteLater);
    connect(thread, &CombineThread::combineFinished, this, &ProcessPhotos::emitCombineFinished);
    thread->start();
}

// ==================================================================

CombineThread::CombineThread(QObject *parent)
    : QThread(parent)
{

}

void CombineThread::run() {
    // get template image
    QImage templateImage(m_templatePath);
    qDebug() << "[ProcessPhotos] Template" << m_templatePath;
    // create an empty 3600x2400 canvas
//    QImage output(3600, 2400, QImage::Format_RGB32);
    QImage output(templateImage.width(), templateImage.height(), QImage::Format_RGB32);
    // prepare painting
    QPainter imagePainter(&output);
    QTransform trans;

    for (int i = 0 ; i < templateJsonArray.count() ; i++) {
        int ax = templateJsonArray[i].toObject()["ax"].toInt();
        int ay = templateJsonArray[i].toObject()["ay"].toInt();
        int awidth = templateJsonArray[i].toObject()["awidth"].toInt();
        int protation = templateJsonArray[i].toObject()["protation"].toInt();

        QString filePath = m_model->data(m_model->index(i, 0), 0).toString();
        qDebug() << "[ProcessPhotos] Processing" << filePath;

        QDir imageDir(filePath);
        QImage image(imageDir.absolutePath());

        if (portraitMode) {

    //        QImage imageScaled = image.scaledToWidth(awidth);
            QImage imageScaled = image.scaledToWidth(1800);

            trans.reset();
    //        if (i == 0) {
    //            trans.translate(output.width()/2+1200, output.height()/2-1800);
    //        }
    //        else if (i == 1) {
    //            trans.translate(output.width()/2, output.height()/2);
    //        }
    //        else if (i == 2) {
    //            trans.translate(output.width()/2+1200, output.height()/2);
    //        }

            if (i == 0) {
                trans.translate(output.width()/2, output.height()/2);
            }
            else if (i == 1) {
                trans.translate(output.width()/2, output.height()/2+1800);
            }
            else if (i == 2) {
                trans.translate(0, output.height());
            }

            trans.rotate(-90);
            imagePainter.setTransform(trans);

            // draw each photo onto canvas
            imagePainter.drawImage(0, 0, imageScaled);

            // return to top-left origin
            imagePainter.resetTransform();
        }
        else {
            QImage imageScaled = image.scaledToWidth(awidth);
            imagePainter.drawImage(ax, ay, imageScaled);
        }

    }

    // draw template image after photos
    imagePainter.drawImage(0, 0, templateImage);

    // combine filenames and save
    QStringList fileNameList;

    for (int i = 0 ; i < m_model->rowCount() ; i++) {
        QDir dir = m_model->data(m_model->index(i, 0), 0).toString();
        QString fileName = dir.dirName().split(".")[0];
        fileNameList.append(fileName);
    }

    QString combinedName = fileNameList.join("_");

    QString outputPath = QString("%1/%2.jpg")
            .arg(m_saveFolder)
            .arg(combinedName);

    qDebug() << "[ProcessPhotos]" << "Combined" << outputPath;
    output.save(outputPath);
    emit combineFinished(outputPath);
}
