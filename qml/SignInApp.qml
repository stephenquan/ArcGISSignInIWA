import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.12
import QtQuick.Layouts 1.12
import ArcGIS.AppFramework.Testing 1.0

Page {
    id: app

    title: qsTr("ArcGIS Sign In (IWA)")

    property NetworkRequest networkRequest
    property bool loading: true

    property int error
    property string errorString
    property string responseText

    PortalProperties {
        id: properties
    }

    QtObject {
        id: styles

        property int textPointSize: 12
        property color textInputBackgroundColor: "#ffffee"
        property color textInputBorderColor: "#e0e0e0"
        property color errorTextColor: "red"
    }

    UserInfo {
        id: userInfo
    }

    StackView {
        id: stackView

        anchors.fill: parent

        initialItem: SignInPage {
        }
    }

    Networking {
        id: networking

        useSystemProxy: true
    }

    Settings {
        id: settings
    }

    Component.onCompleted: {
        loadProperties();
        app.loading = false;
    }

    function saveProperties() {
        let data = properties.toJson();
        settings.setValue("properties", JSON.stringify(data));
        console.log("save: ", JSON.stringify(data));
    }

    function loadProperties() {
        let data = JSON.parse(settings.value("properties"));
        properties.loadFromJson(data);
        console.log("load: ", JSON.stringify(data));
    }

    function setProxy() {
        if (properties.proxy) {
            networking.proxy = properties.proxy;
        } else {
            networking.useSystemProxy = true;
        }
    }

}
