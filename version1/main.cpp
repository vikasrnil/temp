#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QtCore/QCoreApplication>

#include "operations.h"
#include "implement.h"
#include "farmbackend.h"
#include "Connection.h"

int main(int argc, char *argv[])
{
    // Enable Qt Virtual Keyboard
    qputenv("QT_IM_MODULE", QByteArray("qtvirtualkeyboard"));

    // Required before QML loads WebEngineView
    //QtWebEngineQuick::initialize();
    QCoreApplication::setAttribute(Qt::AA_ShareOpenGLContexts);

    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;
    
    // Tractor backend
    Operations operations;
    engine.rootContext()->setContextProperty("operations", &operations);

    // Implement backend
    Implement implementBackend;
    engine.rootContext()->setContextProperty("implementBackend", &implementBackend);

    // Farm backend
    FarmBackend farmBackend;
    engine.rootContext()->setContextProperty("farmBackend", &farmBackend);

    // WiFi backend
    Connection wifi;
    engine.rootContext()->setContextProperty("wifi", &wifi);

    engine.load(QUrl(QStringLiteral("qrc:/qml/Main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
