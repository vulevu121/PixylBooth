#include "gphoto_gmail.h"

//GooglePhoto::GooglePhoto(QObject *parent) : QObject(parent)
//{
//    RequestAuthCode();
//}

//void GooglePhoto::RequestAuthCode(){
//    if (manager == nullptr) {
//         manager = new QNetworkAccessManager(this);
//     }

//    QFile jsonFile("C:/Users/khuon/Documents/GooglePhoto_Gmail/client_secret_1044474243779-a1gndnc2as4cc5c6ufksmbetoafi5mcr.apps.googleusercontent.com.json");
//    jsonFile.open(QFile::ReadOnly);
//    QJsonDocument document = QJsonDocument().fromJson(jsonFile.readAll());

//    const auto object = document.object();
//    settingsObject = object["web"].toObject();

////    const QUrl authUri(settingsObject["auth_uri"].toString());
////    const auto clientId = settingsObject["client_id"].toString();
////    const QUrl tokenUri(settingsObject["token_uri"].toString());
////    const auto clientSecret(settingsObject["client_secret"].toString());
////    const auto redirectUris = settingsObject["redirect_uris"].toArray();
////    const QUrl redirectUri(redirectUris[0].toString()); // Get the first URI
////    const auto port = static_cast<quint16>(redirectUri.port()); // Get the port


////        authEndpoint = QString("https://accounts.google.com/o/oauth2/auth");
//        authEndpoint = settingsObject["auth_uri"].toString();

////        tokenEndpoint = QString("https://www.googleapis.com/oauth2/v4/token?");
//          tokenEndpoint = settingsObject["token_uri"].toString() + "?";

////        scope = QString("?scope=https://www.googleapis.com/auth/photoslibrary"); //scope for all access except sharing
////        scope = QString("?scope=https://www.googleapis.com/auth/photoslibrary.sharing"); // scope for sharing
//        scope = QString("?scope=https://www.googleapis.com/auth/gmail.send"); // Create, read, update, and delete drafts. Send messages and drafts.

//        response_type = QString("&response_type=code");

////        redirect_uri = QString("&redirect_uri=http://127.0.0.1:8080/");
//        redirect_uri = QString("&redirect_uri=" + settingsObject["redirect_uris"].toArray()[0].toString());

////        client_id = QString("&client_id=1044474243779-a1gndnc2as4cc5c6ufksmbetoafi5mcr.apps.googleusercontent.com");
//        client_id = "&client_id=" + settingsObject["client_id"].toString();

////        client_secret = QString("&client_secret=tIML2i8JEn2oR7K0XQ-GNepp");
//        client_secret = "&client_secret=" + settingsObject["client_secret"].toString();
////        qDebug() << client_secret;

//        inputAlbumName = QString("My shared album");
////        pathToPic = QString("C:/Users/khuon/Documents/GooglePhoto/2.jpg");

//        QUrl url(authEndpoint + scope + response_type + redirect_uri + client_id);

////        qDebug() << url;
//        QNetworkRequest req(url);

//        manager->get(req);

//        connect(this->manager, SIGNAL(finished(QNetworkReply*)),
//                this, SLOT(AuthCodeReply(QNetworkReply*)));
//}

//void GooglePhoto::AuthCodeReply(QNetworkReply *reply) {
//    if(reply->error()) {
//        qDebug() << reply->errorString();
//    } else {
//        qDebug() << "Access Code request success!";
//        QUrl url(reply->url());
//        view = new QWebEngineView();
//        view->load(url);
////        view->show();
//        connect(view,SIGNAL(urlChanged(QUrl)),this,SLOT(AuthCodeRedirectReply(QUrl)));
//    }
//    manager->disconnect();

//}

//void GooglePhoto::AuthCodeRedirectReply(QUrl url) {
//    qDebug() << "Access Code Received!";
//    QString url_string(url.toString());
////    qDebug() << url_string;

//    /* For GMAIL authentication, needs to go through several steps, so this
//     section will be different from Google Photo API*/
//    url_string.replace("?","&");
//    QStringList list  = url_string.split(QString("&"));

////    qDebug() << list;

//    if (list[0] == settingsObject["redirect_uris"].toArray()[0].toString()){
//        authCode = list.at(1);
////        qDebug() << authCode;

//        RequestAccessToken();
//    }
//}

//void GooglePhoto::RequestAccessToken(){
//    qDebug() << "Requesting Access Token...";

//    /* Exchange the access code for access token */
//    if (manager == nullptr) {
//         manager = new QNetworkAccessManager(this);
//     }

//    grant_type  = QString("&grant_type=authorization_code");

//    QUrl urlToken(tokenEndpoint+ authCode+client_id+client_secret+redirect_uri+grant_type);
//    QNetworkRequest req(urlToken);
//    req.setRawHeader("Content-Type","application/x-www-form-urlencoded");

////    qDebug() << urlToken;
//    QByteArray data;
//    manager->post(req,data);

//    connect(this->manager, SIGNAL(finished(QNetworkReply*)),
//            this, SLOT(AccessTokenReply(QNetworkReply*)));
//}

//void GooglePhoto::AccessTokenReply(QNetworkReply *reply) {
//    if(reply->error()) {
//        QByteArray response = reply->readAll();
//        QJsonDocument jsonDoc = QJsonDocument::fromJson(response);
//        QJsonObject jsonObject = jsonDoc.object();
//        qDebug() << jsonObject["error"].toObject()["message"].toString();
//        manager->disconnect();

//    } else {
//        qDebug() << "Token Received!";

//        QByteArray response = reply->readAll();
//        QJsonDocument jsonDoc = QJsonDocument::fromJson(response);

//        QJsonObject jsonObject = jsonDoc.object();

//        token = jsonObject["access_token"].toString();
////        qDebug() <<  token;
//        manager->disconnect();

////        UploadPicData(); //Upload photo and send email require different scope. Need to figure out the logic
////           _SendEmail();
//    }

//}

//void GooglePhoto::UploadPicData(){
//        qDebug() << "Uploading binary";

//        if (manager == nullptr) {
//             manager = new QNetworkAccessManager(this);
//         }
////        QFile file("C:/Users/khuon/Documents/GooglePhoto/rdm.jpg");
//        QFile file(pathToPic);

//        qDebug() << "File exists:" << file.exists();

//        file.open(QIODevice::ReadOnly);
//        QByteArray fileBytes = file.readAll();
//        file.close();


//        QNetworkRequest req (QUrl("https://photoslibrary.googleapis.com/v1/uploads"));
//        req.setRawHeader("Authorization","Bearer "+ token.toUtf8());
//        req.setRawHeader("Content-Type","application/octet-stream");
//        req.setRawHeader("X-Goog-Upload-File-Name",file.fileName().toUtf8());
//        req.setRawHeader("X-Goog-Upload-File-Name","rdm1.jpg");
//        req.setRawHeader("X-Goog-Upload-Protocol", "raw");

////        qDebug() << req.rawHeader("Authorization");
////        qDebug() << req.rawHeader("X-Goog-Upload-File-Name");
////        qDebug() << req.rawHeader("X-Goog-Upload-Protocol");
////        qDebug() << req.rawHeader("Content-Type");


//        manager->post(req, fileBytes);
//        connect(this->manager, SIGNAL(finished(QNetworkReply*)),
//                this, SLOT(UploadReply(QNetworkReply*)));
//}

//void GooglePhoto::UploadReply(QNetworkReply *reply) {
//    if(reply->error()) {
//        qDebug() << reply->errorString();
//    } else {
//        qDebug() << "Upload Success!";
//        uploadToken = reply->readAll();
////        qDebug() << "Upload Token: " << uploadToken << endl;
//    }
//    manager->disconnect();
////    CreateMedia();
//    CreateAlbum(inputAlbumName);
//}


//void GooglePhoto::CreateMedia(QString AlbumID){
//    if (manager == nullptr) {
//        manager = new QNetworkAccessManager(this);
//    }

//    QUrl endpoint("https://photoslibrary.googleapis.com/v1/mediaItems:batchCreate");
//    QNetworkRequest req(endpoint);
//    req.setRawHeader("Content-Type","application/json");
//    req.setRawHeader("Authorization","Bearer "+ token.toUtf8());

//    QJsonObject temp;
//        temp["uploadToken"] = uploadToken;

//    QJsonObject temp2;
//    temp2 [ "description" ] = "my rdm";
//    temp2 ["simpleMediaItem"] = temp;

//    QJsonArray arr;
//    arr.append(temp2);

//    QJsonObject obj;
//    obj ["newMediaItems"] = arr;


//    /* Add media to provided album id if available */
//    if (AlbumID.isEmpty()){
//        qDebug() << "album ID not available";
//      }else{
//        qDebug() << "album ID available";
//        obj ["albumId"] = AlbumID;

//    }
//    //to see the JSON output
//    QJsonDocument doc (obj);


//    QByteArray jsonRequest = doc.toJson(QJsonDocument::Compact);
//    QByteArray postDataSize = QByteArray::number(jsonRequest.size());
//    req.setRawHeader("Content-Length", postDataSize);

//      manager->post(req,jsonRequest);

//    connect(this->manager, SIGNAL(finished(QNetworkReply*)),
//            this, SLOT(CreateMediaReply(QNetworkReply*)));
//}

//void GooglePhoto::CreateMediaReply(QNetworkReply *reply) {
//    if(reply->error()) {
//        qDebug() << "Create Media Error" << reply->readAll();
//    } else {
//        qDebug() << "Create Media Success!";

//        QJsonDocument jsonDoc = QJsonDocument::fromJson(reply->readAll());
//        QJsonObject jsonObj = jsonDoc.object();

//        qDebug() << jsonObj["newMediaItemResults"].toArray()[0].toObject()["mediaItem"].toObject()["description"];

//    }
//    manager->disconnect();
//    _SendEmail();


//}

//void GooglePhoto::CreateAlbum(QString album_name){
//    qDebug() << "Creating new album!";

//    if (manager == nullptr) {
//        manager = new QNetworkAccessManager(this);
//    }

//    QUrl endpoint("https://photoslibrary.googleapis.com/v1/albums");
//    QNetworkRequest req(endpoint);
//    req.setRawHeader("Content-Type","application/json");
//    req.setRawHeader("Authorization","Bearer "+ token.toUtf8());

//    QJsonObject obj;
//    obj["title"] = album_name;

//    QJsonObject jsonObj {
//        {"album",obj}
//    };

//    QJsonDocument doc (jsonObj);

////    qDebug() << doc;

//    QByteArray jsonRequest = doc.toJson(QJsonDocument::Compact);
//    QByteArray postDataSize = QByteArray::number(jsonRequest.size());
//    req.setRawHeader("Content-Length", postDataSize);

//    manager->post(req,jsonRequest);

//    connect(this->manager, SIGNAL(finished(QNetworkReply*)),
//            this, SLOT(CreateAlbumReply(QNetworkReply*)));
//}


//void GooglePhoto::CreateAlbumReply(QNetworkReply * reply){
//    if(reply->error()) {
//        qDebug() << "Create Album Error" << reply->readAll();
//    } else {
//        qDebug() << "Create Album Success!";
////        qDebug() << reply->readAll();

//        QJsonDocument jsonDoc = QJsonDocument::fromJson(reply->readAll());
//        QJsonObject jsonObj = jsonDoc.object();


//        albumID = jsonObj["id"].toString();
//        qDebug() << "Album created:" << albumID;

//          albumURL = jsonObj["productUrl"].toString();
//          qDebug() << "Album link:" << albumURL;
//     }
//    manager->disconnect();

//    ShareAlbum(albumID);

//}

//QString GooglePhoto::getAlbumId(){
//    return GooglePhoto::albumID;
//}

//void GooglePhoto::GetAlbums(){
//    if (manager == nullptr) {
//        manager = new QNetworkAccessManager(this);
//    }

//    QUrl endpoint("https://photoslibrary.googleapis.com/v1/albums");
//    QNetworkRequest req(endpoint);
//    req.setRawHeader("Authorization","Bearer "+ token.toUtf8());

//    manager->get(req);

//    connect(this->manager, SIGNAL(finished(QNetworkReply*)),
//            this, SLOT(GetAlbumsReply(QNetworkReply*)));
//}

//void GooglePhoto::GetAlbumsReply(QNetworkReply * reply){
//    if(reply->error()) {
//        qDebug() << "Get Shared Albums Error" << reply->readAll();
//    } else {

//        QJsonDocument jsonDoc = QJsonDocument::fromJson(reply->readAll());
//        QJsonObject jsonObj = jsonDoc.object();

//        qDebug() << jsonObj; //["mediaItems"].toArray()["mediaItem"].toObject()["description"];

//     }
//    manager->disconnect();
//}

//void GooglePhoto::ShareAlbum(QString AlbumID){
//    if (manager == nullptr) {
//         manager = new QNetworkAccessManager(this);
//     }

//    QString endpoint ("https://photoslibrary.googleapis.com/v1/albums/");

//    QUrl reqURL(endpoint + AlbumID + QString(":share"));
//    QNetworkRequest req(reqURL);
//    req.setRawHeader("Authorization","Bearer "+ token.toUtf8());
//    req.setRawHeader("Content-Type","application/json");

//    QJsonObject temp{
//        {"isCollaborative", "false"},
//        {"isCommentable", "false"}
//    };

//    QJsonObject jsonObj{
//        {"sharedAlbumOptions", temp}
//    };

//    QJsonDocument doc (jsonObj);

////    qDebug() << doc;

//    QByteArray jsonRequest = doc.toJson(QJsonDocument::Compact);
//    QByteArray postDataSize = QByteArray::number(jsonRequest.size());
//    req.setRawHeader("Content-Length", postDataSize);

//    manager->post(req,jsonRequest);

//    connect(this->manager, SIGNAL(finished(QNetworkReply*)),
//            this, SLOT(ShareAlbumReply(QNetworkReply*)));
//}
//void GooglePhoto::ShareAlbumReply(QNetworkReply * reply){
//    if(reply->error()) {
//        qDebug() << "Sharing Albums Error" << reply->readAll();
//    } else {
//        qDebug() << "Sharing Albums Success";

//        QJsonDocument jsonDoc = QJsonDocument::fromJson(reply->readAll());
//        QJsonObject jsonObj = jsonDoc.object();

//        shareableURL =  jsonObj["shareInfo"].toObject()["shareableUrl"].toString();
////        qDebug() << shareableURL;

//     }
//    manager->disconnect();
//    CreateMedia(albumID);

//}


//void GooglePhoto::_SendEmail(){
//    qDebug() << "_Sending email with link...";

//    if (manager == nullptr) {
//         manager = new QNetworkAccessManager(this);
//     }

////    shareableURL = QString("https://photos.app.goo.gl/U59jf5pMxV1FHV4H8");
//    QString message ("From: khuongnguyensac@gmail.com\n"
//                    "To: khuong.dinh.ng@gmail.com,vulevu121@gmail.com,timz1992@yahoo.com  \n"
//                     "Subject: Sending Email is DONE!\n"
//                     "\n"
//                     "Time to up the pricing!\n"
//                     "Shareable Album Link:" + shareableURL );

//    QByteArray encoded = message.toUtf8().toBase64(QByteArray::Base64UrlEncoding);
////    qDebug() << encoded ;


//    /* Ensure encoded message is URL safe */
//    encoded.replace("+","-");
//    encoded.replace("/","_");
////    encoded.replace("=","*");

//    qDebug() << encoded ;

//    QJsonObject jsonObj;
//    jsonObj ["raw"] = QString(encoded);


//    QJsonDocument doc (jsonObj);

//    QByteArray jsonRequest = doc.toJson(QJsonDocument::Compact);
//    QByteArray postDataSize = QByteArray::number(jsonRequest.size());

//    QString endPoint ("https://www.googleapis.com/gmail/v1/users/");
//    QUrl sendURL(endPoint + "me"+ "/messages/send");
//    QNetworkRequest sendReq(sendURL);
//    qDebug() << sendURL;

//    sendReq.setRawHeader("Authorization","Bearer "+ token.toUtf8());
//    sendReq.setRawHeader("Content-Type","application/json");
//    sendReq.setRawHeader("Content-Length", postDataSize);

//    manager->post(sendReq,jsonRequest);

//    connect(this->manager, SIGNAL(finished(QNetworkReply*)),
//            this, SLOT(_SendEmailReply(QNetworkReply*)));
//}

//void GooglePhoto::_SendEmailReply(QNetworkReply * reply){
//    if(reply->error()) {
//        qDebug() << "_Sending Email Error" << reply->readAll();
//        manager->disconnect();

//    } else {
//        qDebug() << "_Sending Email Success";

//        QJsonDocument jsonDoc = QJsonDocument::fromJson(reply->readAll());
//        QJsonObject jsonObj = jsonDoc.object();

//        qDebug() << jsonObj;

//        manager->disconnect();

//     }

//}

//void GooglePhoto::DraftEmail(){
//    qDebug() << "Drafting email with link...";

//    if (manager == nullptr) {
//         manager = new QNetworkAccessManager(this);
//     }

//    shareableURL = QString("https://photos.app.goo.gl/U59jf5pMxV1FHV4H8");
//    QString message ("From: khuongnguyensac@gmail.com\n"
//                    "To: khuong.dinh.ng@gmail.com\n"
//                     "Subject: Third Test\n"
//                     "\n"
////                   "Link:" + shareableURL );
//                     "Link: https://photos.app.goo.gl/U59jf5pMxV1FHV4H8");

//    QByteArray encoded = message.toUtf8().toBase64(QByteArray::Base64UrlEncoding);
//    qDebug() << encoded ;


//    /* Ensure encoded message is URL safe */
//    encoded.replace("+","-");
//    encoded.replace("/","_");
////    encoded.replace("=","*");

//    qDebug() << encoded ;

//    QJsonObject temp;
//    temp ["raw"] = QString(encoded);

//    QJsonObject jsonObj;
//    jsonObj["message"] = temp;

//    QJsonDocument doc (jsonObj);

//    QByteArray jsonRequest = doc.toJson(QJsonDocument::Compact);
//    QByteArray postDataSize = QByteArray::number(jsonRequest.size());

//    QString endPoint ("https://www.googleapis.com/gmail/v1/users/");
//    QUrl draftURL(endPoint + "me"+ "/drafts");
//    QNetworkRequest createDraftReq(draftURL);

//    createDraftReq.setRawHeader("Authorization","Bearer "+ token.toUtf8());
//    createDraftReq.setRawHeader("Content-Type","application/json");
//    createDraftReq.setRawHeader("Content-Length", postDataSize);

//    manager->post(createDraftReq,jsonRequest);

//    connect(this->manager, SIGNAL(finished(QNetworkReply*)),
//            this, SLOT(DraftEmailReply(QNetworkReply*)));
//}

//void GooglePhoto::DraftEmailReply(QNetworkReply * reply){
//    if(reply->error()) {
//        qDebug() << "Drafting Email Error" << reply->readAll();
//        manager->disconnect();

//    } else {
//        qDebug() << "Drafting Email Success";

//        QJsonDocument jsonDoc = QJsonDocument::fromJson(reply->readAll());
//        QJsonObject jsonObj = jsonDoc.object();

//        /* Success response model
//         {
//             "id": "r2420125699170800686",
//             "message": {
//                        "id": "16be4d8ccb84234a",
//                        "threadId": "16be4d8ccb84234a",
//                        "labelIds": ["DRAFT"]
//             }
//           }
//        */

////        qDebug() << jsonObj;
//        QString id = jsonObj["id"].toString();
//        qDebug() <<  id;

////        draftId = jsonObj["id"].toString();
////        qDebug() << draftId;
//        manager->disconnect();

////        SendEmail(id);
//     }

//}


//void GooglePhoto::SendEmail(QString draftID){
//    qDebug() << "Sending email...";

//    if (manager == nullptr) {
//         manager = new QNetworkAccessManager(this);
//     }
//    QString ID ("r6633021279641280350");
////    qDebug() << draftID;

//    QJsonObject jsonObj;
//    jsonObj["id"] = ID;

//    QJsonDocument doc (jsonObj);

//    QByteArray jsonRequest = doc.toJson(QJsonDocument::Compact);
//    QByteArray postDataSize = QByteArray::number(jsonRequest.size());

//    QString endPoint ("https://www.googleapis.com/gmail/v1/users/");
//    QUrl sendURL(endPoint + "me"+ "/drafts/send");
//    QNetworkRequest sendDraftReq(sendURL);

//    sendDraftReq.setRawHeader("Authorization","Bearer "+ token.toUtf8());
//    sendDraftReq.setRawHeader("Content-Type","application/json");

//    sendDraftReq.setRawHeader("Content-Length", postDataSize);

//    manager->post(sendDraftReq,jsonRequest);

//    connect(this->manager, SIGNAL(finished(QNetworkReply*)),
//            this, SLOT(SendEmailReply(QNetworkReply*)));
//}

//void GooglePhoto::SendEmailReply(QNetworkReply * reply){
//    if(reply->error()) {
//        qDebug() << "Sending Email Error" << reply->readAll();
//    } else {
//        qDebug() << "Sending Email Success";

//        QJsonDocument jsonDoc = QJsonDocument::fromJson(reply->readAll());
//        QJsonObject jsonObj = jsonDoc.object();

//        /* Success response model
//         {
//            {
//             "id": "16be4bf443ed7aa7",
//             "threadId": "16be4bf443ed7aa7",
//             "labelIds": [
//              "SENT"
//             ]
//            }
//             }
//           }
//        */

//        qDebug() << jsonObj;

//     }
//    manager->disconnect();

//}


