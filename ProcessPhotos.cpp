#include "ProcessPhotos.h"

ProcessPhotos::ProcessPhotos(QObject *parent) :
    QObject(parent)
{
}


QString ProcessPhotos::saveFolder() {

    return m_saveFolder;
}

void ProcessPhotos::setSaveFolder(const QString &saveFolder) {
    if (saveFolder == m_saveFolder)
        return;
    m_saveFolder = saveFolder;
}

QString ProcessPhotos::templateFormat() {

    return m_templateFormat;
}

void ProcessPhotos::setTemplateFormat(const QString &templateFormat) {
    if (templateFormat == m_templateFormat)
        return;
    m_templateFormat = templateFormat;

    QJsonDocument doc = QJsonDocument::fromJson(m_templateFormat.toUtf8());
    templateJsonArray = doc.array();

}

QString ProcessPhotos::templatePath() {

    return m_templatePath;
}

void ProcessPhotos::setTemplatePath(const QString &templatePath) {
    if (templatePath == m_templatePath)
        return;
    m_templatePath = templatePath;
}


void ProcessPhotos::testTemplate() {

    qDebug() << m_templatePath;
}


QString ProcessPhotos::combine(const QString &photoPaths) {
    photoPathsList = photoPaths.split(";");
    qDebug() << photoPathsList;

//    QDir templateDir(photoPathsList[0]);
//    QDir image1Dir(photoPathsList[1]);
//    QDir image2Dir(photoPathsList[2]);
//    QDir image3Dir(photoPathsList[3]);
//    QDir image4Dir(photoPathsList[4]);

    // define paths for images
//    QDir templateDir(m_templatePath);
    qDebug() << m_templatePath;
    QImage templateImage(m_templatePath);

//    QImage image1(image1Dir.absolutePath());
//    QImage image2(image2Dir.absolutePath());
//    QImage image3(image3Dir.absolutePath());
//    QImage image4(image4Dir.absolutePath());

    // resize photos to fit template
//    QImage image1Scaled = image1.scaledToWidth(1137);
//    QImage image2Scaled = image2.scaledToWidth(1137);
//    QImage image3Scaled = image3.scaledToWidth(1137);
//    QImage image4Scaled = image4.scaledToWidth(1713);

//    QImage image1Scaled = image1.scaledToWidth(1563);
//    QImage image2Scaled = image2.scaledToWidth(1563);
//    QImage image3Scaled = image3.scaledToWidth(1563);

    // create an empty 3600x2400 canvas
    QImage output(3600, 2400, QImage::Format_RGB32);

    // paint on output imagePainter
    QPainter imagePainter(&output);

    // draw photos
//    imagePainter.drawImage(117, 240, image1Scaled);
//    imagePainter.drawImage(1248, 249, image2Scaled);
//    imagePainter.drawImage(2349, 246, image3Scaled);
//    imagePainter.drawImage(129, 1011, image4Scaled);

//    imagePainter.drawImage(237, 147, image1Scaled);
//    imagePainter.drawImage(1809, 168, image2Scaled);
//    imagePainter.drawImage(1803, 1215, image3Scaled);

    if (photoPathsList.length() == templateJsonArray.count()) {

        for (int i = 0 ; i < templateJsonArray.count() ; i++) {
            int ax = templateJsonArray[i].toObject()["ax"].toInt();
            int ay = templateJsonArray[i].toObject()["ay"].toInt();
            int awidth = templateJsonArray[i].toObject()["awidth"].toInt();

            QDir imageDir(photoPathsList[i]);
            QImage image(imageDir.absolutePath());
            QImage imageScaled = image.scaledToWidth(awidth);

            imagePainter.drawImage(ax, ay, imageScaled);
        }
    }



    // draw template on top
    imagePainter.drawImage(0, 0, templateImage);

    // save output

    QStringList fileNameList;

    for (int i = 0 ; i < photoPathsList.count() ; i++) {
        QDir dir = photoPathsList[i];
        QString fileName = dir.dirName().split(".")[0];
        fileNameList.append(fileName);
    }

    QString combinedName = fileNameList.join("_");

    QString saveOutputPath = QString("%1/%2.jpg")
            .arg(saveFolder())
            .arg(combinedName);

    output.save(saveOutputPath);
    return saveOutputPath;

}

