import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.12
import QtQuick.Layouts 1.12
import ArcGIS.AppFramework.Testing 1.0

    Page {
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
                    placeholderText: qsTr("Specify Portal URL")
                }

                AppComboBox {
                    id: authTypeComboBox

                    model: [
                        properties.kAuthTypeIWA,
                        properties.kAuthTypeOAuth
                    ]
                    source: properties
                    role: "authType"
                }

                ColumnLayout {
                    Layout.fillWidth: true

                    visible: properties.isIWA

                    AppTextInput {
                        source: properties
                        role: "iwaUser"
                        placeholderText: qsTr("Specify IWA User")
                    }

                    AppTextInput {
                        source: properties
                        role: "iwaPassword"
                        placeholderText: qsTr("Specify IWA Password")
                        echoMode: TextInput.Password
                    }

                    AppTextInput {
                        source: properties
                        role: "iwaRealm"
                        placeholderText: qsTr("Specify IWA Realm")
                    }
                }

                AppTextInput {
                    source: properties
                    role: "proxy"
                    placeholderText: qsTr("Specify Proxy")
                }

                Button {
                    text: qsTr("Send")
                    font.pointSize: styles.textPointSize
                    enabled: !networkRequest || !networkRequest.busy

                    onClicked: doSend()
                }

                Frame {
                    Layout.fillWidth: true

                    background: Rectangle {
                        color: styles.textInputBackgroundColor
                        border.color: styles.textInputBorderColor
                    }

                    Text {
                        text: responseText
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
                    visible: error && errorString
                    font.pointSize: styles.textPointSize
                    color: styles.errorTextColor
                }

                Text {
                    text: qsTr("%1 (%2)")
                    .arg(ReadyState.stringify(networkRequest ? networkRequest.readyState : 0))
                    .arg(networkRequest ? networkRequest.readyState : "")
                    visible: networkRequest && networkRequest.busy
                    font.pointSize: styles.textPointSize
                }

            }
        }

    NetworkRequest {
        id: userInfoRequest

        url: "%1/sharing/rest/community/self?f=json".arg(properties.resolvedUrl)

        onReadyStateChanged: {
            if (readyState !== ReadyState.DONE)
            {
                return;
            }
        }

        function submit() {
            console.log("url: ", userInfoRequest.url);
            send();
        }
    }

    NetworkRequest {
        id: networkRequest

        property var resolved
        property var rejected
        property var responseJson: null

        onReadyStateChanged: {
            if (readyState !== ReadyState.DONE) {
                return;
            }

            app.error = error;
            app.errorString = errorString;
            app.responseText = responseText;

            if (error !== NetworkError.NoError) {
                rejected(new Error(errorString));
                return;
            }

            try {
                responseJson = JSON.parse(responseText);
            } catch (err) {
                rejected(new Error(err.message));
                return;
            }

            resolved(networkRequest);
        }

        function newSendPromise(url, ...params) {
            return new Promise( function (resolved, rejected) {
                app.error = NetworkError.NoError;
                app.errorString = "";
                app.responseText = "";

                networkRequest.url = url;
                networkRequest.resolved = resolved;
                networkRequest.rejected = rejected;
                networkRequest.responseJson = null;
                if (properties.isIWA) {
                    networkRequest.user = properties.iwaUser;
                    networkRequest.password = properties.iwaPassword;
                    networkRequest.realm = properties.iwaRealm;
                }

                networkRequest.send(...params);
            } );
        }
    }

    function newUserInfoPromise() {
        let url = properties.url + "/sharing/rest/community/self?f=pjson";
        let data = { "f": "pjson" };
        return networkRequest.newSendPromise(url, data);
    }

    function showUserInfo(req) {
        userInfo.loadFromJson(req.responseJson);
        console.log("userInfo: ", JSON.stringify(userInfo.toJson()));
    }

    function showError(err) {
        console.log("OMG! ", err);
    }

    function doSend() {
        saveProperties();

        setProxy();

        newUserInfoPromise()
        .then( showUserInfo )
        .catch( showError )
        ;
    }
}
