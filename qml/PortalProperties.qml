import QtQuick 2.12

QtObject {
    id: properties

    readonly property string kKeyUrl: "url"
    readonly property string kKeyAuthType: "authType"
    readonly property string kKeyIwaUser: "iwaUser"
    readonly property string kKeyIwaPassword: "iwaPassword"
    readonly property string kKeyIwaRealm: "iwaRealm"
    readonly property string kKeyProxy: "proxy"

    readonly property var keys: ( [
                                     kKeyUrl,
                                     kKeyAuthType,
                                     kKeyIwaUser,
                                     kKeyIwaPassword,
                                     kKeyIwaRealm,
                                     kKeyProxy
                                 ])

    property url urlDefault: "https://www.arcgis.com/sharing/rest?f=pjson"
    property url urlResolved: !url ? urlDefault : url
    property string url: urlDefault

    readonly property string kAuthTypeIWA: 'IWA'
    readonly property string kAuthTypeOAuth: 'OAuth'

    readonly property string authTypeDefault: kAuthTypeIWA
    property string authType: defaultAuthType
    readonly property bool isIWA: authType === kAuthTypeIWA

    property string iwaUser: ""
    property string iwaPassword: ""
    property string iwaRealm: ""
    property string proxy

    function loadFromJson(data) {
        for (let key of keys) {
            properties[key] = data[key] || data[key + "Default"] || "";
        }
    }

    function toJson() {
        return keys.reduce( function (p,c) {
            p[c] = properties[c];
            return p;
        }, ( { } ) );
    }
}
