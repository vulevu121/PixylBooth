#ifndef MOVEMOUSE_H
#define MOVEMOUSE_H

#include <QObject>
#include <QCursor>


class MoveMouse : public QObject
{
    Q_OBJECT
public:
    explicit MoveMouse(QObject *parent = nullptr);

signals:

public slots:
    void move(int x, int y);
};

#endif // MOVEMOUSE_H
