#include "MoveMouse.h"

MoveMouse::MoveMouse(QObject *parent) : QObject(parent)
{

}


void MoveMouse::move(int x, int y) {
    QPoint movePoint(x, y);
    QCursor::setPos(movePoint);
}
