#ifndef __NetworkRequest__
#define __NetworkRequest__

#import <QObject>
#include <QNetworkAccessManager>
#include <QQmlEngine>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QAuthenticator>
#include "NetworkError.h"
#include "ReadyState.h"

class NetworkRequest : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QUrl url MEMBER m_Url NOTIFY urlChanged)
    Q_PROPERTY(QString user MEMBER m_User NOTIFY userChanged)
    Q_PROPERTY(QString password MEMBER m_Password NOTIFY passwordChanged)
    Q_PROPERTY(QString realm MEMBER m_Realm NOTIFY realmChanged)
    Q_PROPERTY(QByteArray response READ response NOTIFY responseChanged)
    Q_PROPERTY(QString responseText READ responseText NOTIFY responseChanged)
    Q_PROPERTY(NetworkErrorEnum::NetworkError error READ error NOTIFY errorChanged)
    Q_PROPERTY(QString errorString READ errorString NOTIFY errorStringChanged)
    Q_PROPERTY(ReadyStateEnum::ReadyState readyState READ readyState NOTIFY readyStateChanged)
    Q_PROPERTY(bool busy READ busy NOTIFY readyStateChanged)

public:
    NetworkRequest(QObject* parent = nullptr) :
        QObject(parent),
        m_Manager(nullptr),
        m_Reply(nullptr),
        m_Error(NetworkErrorEnum::NoError),
        m_ReadyState(ReadyStateEnum::UNSENT)
    {
    }

    Q_INVOKABLE void send(const QVariant& data = QVariant())
    {
        Q_UNUSED(data)
        setResponse(QByteArray());
        setError(NetworkErrorEnum::NoError);
        setErrorString(QString());
        setReadyState(ReadyStateEnum::OPENED);
        m_Reply = manager()->get(QNetworkRequest(m_Url));
    }

signals:
    void urlChanged();
    void userChanged();
    void passwordChanged();
    void realmChanged();
    void responseChanged();
    void errorChanged();
    void errorStringChanged();
    void readyStateChanged();

protected slots:
    void onAuthenticationRequired(QNetworkReply *reply, QAuthenticator *authenticator)
    {
        Q_UNUSED(reply)
        authenticator->setUser(m_User);
        authenticator->setPassword(m_Password);
        authenticator->setRealm(m_Realm);
    }

    void onFinished(QNetworkReply* reply)
    {
        if (reply != m_Reply)
        {
            return;
        }

        setResponse(m_Reply->readAll());
        setError(static_cast<NetworkErrorEnum::NetworkError>(m_Reply->error()));
        setErrorString(m_Reply->errorString());

        m_Reply->deleteLater();
        m_Reply = nullptr;

        setReadyState(ReadyStateEnum::DONE);
    }

protected:
    QNetworkAccessManager* m_Manager;
    QNetworkReply* m_Reply;
    QUrl m_Url;
    QString m_User;
    QString m_Password;
    QString m_Realm;
    QByteArray m_Response;
    NetworkErrorEnum::NetworkError m_Error;
    QString m_ErrorString;
    ReadyStateEnum::ReadyState m_ReadyState;

    QByteArray response() const { return m_Response; }
    QString responseText() const { return QString::fromUtf8(m_Response); }

    NetworkErrorEnum::NetworkError error() const { return m_Error; }
    void setError(NetworkErrorEnum::NetworkError error)
    {
        if (m_Error == error)
        {
            return;
        }

        m_Error = error;

        emit errorChanged();
    }

    QString errorString() const { return m_ErrorString; }
    void setErrorString(const QString& errorString)
    {
        if (m_ErrorString == errorString)
        {
            return;
        }

        m_ErrorString = errorString;

        emit errorStringChanged();
    }

    ReadyStateEnum::ReadyState readyState() const { return m_ReadyState; }
    void setReadyState(ReadyStateEnum::ReadyState readyState)
    {
        if (m_ReadyState == readyState)
        {
            return;
        }

        m_ReadyState = readyState;

        emit readyStateChanged();
    }

    bool busy() const
    {
        switch (m_ReadyState)
        {
        case ReadyStateEnum::UNSENT:
        case ReadyStateEnum::DONE:
            return false;

        default:
            return true;
        }
    }

    QNetworkAccessManager* manager()
    {
        if (m_Manager)
        {
            return m_Manager;
        }

        m_Manager = qmlEngine(this)->networkAccessManager();
        connect(m_Manager, &QNetworkAccessManager::authenticationRequired, this, &NetworkRequest::onAuthenticationRequired);
        connect(m_Manager, &QNetworkAccessManager::finished, this, &NetworkRequest::onFinished);
        return m_Manager;
    }

    void setResponse(const QByteArray& response)
    {
        if (m_Response == response)
        {
            return;
        }

        m_Response = response;

        emit responseChanged();
    }

};

#endif
