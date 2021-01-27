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
        property string proxy

        onProxyChanged: {
            networking.proxy = proxy;
        }
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
                    source: networkRequest
                    role: "user"
                    placeholderText: qsTr("Specify Portal User")
                }

                AppTextInput {
                    source: networkRequest
                    role: "password"
                    placeholderText: qsTr("Specify Portal Password")
                    echoMode: TextInput.Password
                }

                AppTextInput {
                    source: networkRequest
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
                    text: properties.errorString
                    visible: properties.error && properties.errorString
                    font.pointSize: styles.textPointSize
                    color: styles.errorTextColor
                }

            }
        }
    }

    NetworkRequest {
        id: networkRequest

        onFinished: {
            console.log("networkRequest.error: ", networkRequest.error);
            console.log("networkRequest.errorString: ", networkRequest.errorString);
            console.log("networkRequest.responseText: ", responseText);
        }
    }

    Networking {
        id: networking

        useSystemProxy: true
    }

    function doSend() {
        networkRequest.url = !properties.url ? properties.defaultUrl : properties.url
        console.log("properties.url: ", properties.url);
        console.log("networkRequest.url: ", networkRequest.url);
        console.log("networking.proxy: ", networking.proxy);
        networkRequest.send();
    }
}
