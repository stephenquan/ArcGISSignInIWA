#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include "NetworkRequest.h"
#include "Networking.h"

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    qmlRegisterType<NetworkRequest>("ArcGIS.AppFramework.Testing", 1, 0, "NetworkRequest");
    qmlRegisterType<Networking>("ArcGIS.AppFramework.Testing", 1, 0, "Networking");

    const QUrl url(QStringLiteral("qrc:/qml/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
