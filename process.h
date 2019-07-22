#ifndef PROCESS_H
#define PROCESS_H

#endif // PROCESS_H


#include <QProcess>
#include <QVariant>

class Process : public QProcess {
    Q_OBJECT

public:
    Process(QObject *parent = nullptr) : QProcess(parent) { }

//    void start2(const QString &program) {
//        QProcess *process = new QProcess(this);
//        process->start(program);
//    }

    Q_INVOKABLE void start(const QString &program, const QVariantList &arguments) {
        QStringList args;

        // convert QVariantList from QML to QStringList for QProcess 

        for (int i = 0; i < arguments.length(); i++)
            args << arguments[i].toString();

        QProcess::start(program, args);
    }

    Q_INVOKABLE QByteArray readAll() {
        return QProcess::readAll();
    }

    Q_INVOKABLE QByteArray readAllStandardOutput() {
        return QProcess::readAllStandardOutput();
    }

    Q_INVOKABLE void kill() {
        return QProcess::kill();
    }
private:
    QProcess *process = nullptr;
};
