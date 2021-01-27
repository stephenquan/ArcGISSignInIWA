import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.12
import QtQuick.Layouts 1.12
import ArcGIS.AppFramework.Testing 1.0

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("ArcGIS Sign In (IWA)")

    QtObject {
        id: properties

        property alias error: networkRequest.error
        property alias errorString: networkRequest.errorString
        property alias responseText: networkRequest.responseText
        property url defaultUrl: "https://www.arcgis.com/sharing/rest?f=pjson"
        property string url: defaultUrl
        property string user: ""
        property string password: ""
        property string realm: ""
        property string proxy
        property bool loading: true

        function save() {
            if (loading) {
                return;
            }

            let data = {
                "url": properties.url,
                "user" : properties.user,
                "password" : properties.password,
                "realm" : properties.realm,
                "proxy" : properties.proxy
            };

            settings.setValue("properties", JSON.stringify(data));
        }

        function load() {
            loading = true;
            let data = settings.value("properties");
            data = JSON.parse(data);
            if (!data) {
                loading = false;
                return;
            }

            properties.url = data["url"] || "";
            networkRequest.user = data["user"] || "";
            networkRequest.password = data["password"] || "";
            networkRequest.realm = data["realm"] || "";
            properties.proxy = data["proxy"] || "";
            loading = false;
        }

        Component.onCompleted: Qt.callLater(load)
    }

    QtObject {
        id: styles

        property int textPointSize: 12
        property color textInputBackgroundColor: "#ffffee"
        property color textInputBorderColor: "#e0e0e0"
        property color errorTextColor: "red"
    }

    Page {
        anchors.fill: parent

        Flickable {
            id: flickable

            anchors.fill: parent
            anchors.margins: 10

            contentWidth: columnLayout.width
            contentHeight: columnLayout.height
            clip: true

            ColumnLayout {
                id: columnLayout

                width: flickable.width

                AppTextInput {
                    source: properties
                    role: "url"
                    placeholderText: properties.defaultUrl
                }

                AppTextInput {
                    source: properties
                    role: "user"
                    placeholderText: qsTr("Specify Portal User")
                }

                AppTextInput {
                    source: properties
                    role: "password"
                    placeholderText: qsTr("Specify Portal Password")
                    echoMode: TextInput.Password
                }

                AppTextInput {
                    source: properties
                    role: "realm"
                    placeholderText: qsTr("Specify Portal Realm")
                }

                AppTextInput {
                    source: properties
                    role: "proxy"
                    placeholderText: qsTr("Specify Proxy")
                }

                Button {
                    text: qsTr("Send")
                    font.pointSize: styles.textPointSize
                    enabled: !networkRequest.busy

                    onClicked: doSend()
                }

                Frame {
                    Layout.fillWidth: true

                    background: Rectangle {
                        color: styles.textInputBackgroundColor
                        border.color: styles.textInputBorderColor
                    }

                    Text {
                        text: properties.responseText
                        font.pointSize: styles.textPointSize
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    }
                }
            }
        }

        footer: Frame {
            ColumnLayout {
                width: parent.width

                Text {
                    text: qsTr("Network Error %1: %2\n%3")
                          .arg(properties.error)
                          .arg(NetworkError.stringify(properties.error))
                          .arg(properties.errorString)
                    visible: properties.error && properties.errorString
                    font.pointSize: styles.textPointSize
                    color: styles.errorTextColor
                }

                Text {
                    text: qsTr("%1 (%2)")
                    .arg(ReadyState.stringify(networkRequest.readyState))
                    .arg(networkRequest.readyState)
                    visible: networkRequest.busy
                    font.pointSize: styles.textPointSize
                }

            }
        }
    }

    NetworkRequest {
        id: networkRequest

        onReadyStateChanged: {
            if (readyState !== ReadyState.DONE)
            {
                return;
            }
        }
    }

    Networking {
        id: networking

        useSystemProxy: true
    }

    Settings {
        id: settings
    }

    function doSend() {
        properties.save();
        networkRequest.url = !properties.url ? properties.defaultUrl : properties.url
        networkRequest.user = properties.user;
        networkRequest.password = properties.password;
        networkRequest.realm = properties.realm;
        if (properties.proxy) {
            networking.proxy = properties.proxy;
        } else {
            networking.useSystemProxy = true;
        }
        networkRequest.send();
    }
}
