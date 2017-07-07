#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QDebug>
#include <QtWebView>
#include <QQmlContext>
///#include "qaeswrap.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QtWebView::initialize();
    QQmlApplicationEngine engine;

    //QQmlContext *context = engine.rootContext();
    ///QAesWrap* aes = new QAesWrap("&!!&!!!@", "w2wJCnctEG09danPPI7SxQ==", QAesWrap::AES_256);
    ///context->setContextProperty("AES", aes);
    ///
    engine.load(QUrl(QStringLiteral("../../test.qml")));

    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
