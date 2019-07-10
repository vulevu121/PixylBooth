QT += gui quick widgets multimedia network printsupport
CONFIG += c++11

TEMPLATE = app
win32:VERSION = 0.92
else:VERSION = 0.92

RC_ICONS = 1718703_0d0_icon.ico

# The following define makes your compiler emit warnings if you use
# any Qt feature that has been marked deprecated (the exact warnings
# depend on your compiler). Refer to the documentation for the
# deprecated API to know how to port your code away from it.
DEFINES += QT_DEPRECATED_WARNINGS

# You can also make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
# You can also select to disable deprecated APIs only up to a certain version of Qt.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += \
    CSVFile.cpp \
    Firebase.cpp \
    main.cpp \
    ProcessPhotos.cpp \
    PrintPhotos.cpp \
    SonyLiveview.cpp \
    SonyAPI.cpp

RESOURCES += qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH = "C:\Qt\5.12.2\msvc2017_64\qml"

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =


# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

HEADERS += \
    CSVFile.h \
    Firebase.h \
    process.h \
    ProcessPhotos.h \
    PrintPhotos.h \
    SonyLiveview.h \
    SonyAPI.h

DISTFILES +=