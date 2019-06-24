#include "ProcessPhotos.h"

ProcessPhotos::ProcessPhotos(QObject *parent) :
    QObject(parent)
{
}

//QString ProcessPhotos::photoData() {
//    return m_photoData;
//}

//void ProcessPhotos::setPhotoData(const QString &jsonString) {
//    qDebug() << jsonString;
//}


//QString ProcessPhotos::photoURLs() {
//    return m_photoURLs;
//}

//void ProcessPhotos::setPhotoURLs(const QString &photoURLs) {

//}

QString ProcessPhotos::combine(const QString &photoPaths) {
    QStringList photoPathsList = photoPaths.split(";");
//    qDebug() << photoPathsList;

    QDir templateDir(photoPathsList[0]);
    QDir image1Dir(photoPathsList[1]);
    QDir image2Dir(photoPathsList[2]);
    QDir image3Dir(photoPathsList[3]);
//    QDir image4Dir(photoPathsList[4]);

    // define paths for images
    QImage templateImage(templateDir.absolutePath());
    QImage image1(image1Dir.absolutePath());
    QImage image2(image2Dir.absolutePath());
    QImage image3(image3Dir.absolutePath());

    // resize photos to fit template
    QImage image1Scaled = image1.scaledToWidth(1500);
    QImage image2Scaled = image2.scaledToWidth(1500);
    QImage image3Scaled = image3.scaledToWidth(1500);

    // create an empty 3600x2400 canvas
    QImage output(3600, 2400, QImage::Format_RGB32);

    // paint on output imagePainter
    QPainter imagePainter(&output);

    // draw photos
    imagePainter.drawImage(261, 159, image1Scaled);
    imagePainter.drawImage(1836, 159, image2Scaled);
    imagePainter.drawImage(1836, 1236, image3Scaled);

    // draw template on top
    imagePainter.drawImage(0, 0, templateImage);

    // save output

    QString saveOutputPath = QString("%1/%2_%3_%4.jpg")
            .arg(saveFolder())
            .arg(image1Dir.dirName().split(".")[0])
            .arg(image2Dir.dirName().split(".")[0])
            .arg(image3Dir.dirName().split(".")[0]);

    output.save(saveOutputPath);
    return saveOutputPath;

}

QString ProcessPhotos::saveFolder() {
    return m_saveFolder;
}

void ProcessPhotos::setSaveFolder(const QString &saveFolder) {
    if (saveFolder == m_saveFolder)
        return;
    m_saveFolder = saveFolder;
}
