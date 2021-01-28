import QtQuick 2.12

QtObject {
    id: userInfo

    readonly property string kKeyUsername: "username"
    readonly property string kKeyFullName: "fullName"
    readonly property string kKeyEmail: "email"
    readonly property string kKeyThumbnail: "thumbnail"
    readonly property var keys: ( [
                                     kKeyUsername,
                                     kKeyFullName,
                                     kKeyEmail,
                                     kKeyThumbnail
                                 ])

    property string username
    property string fullName
    property string email
    property string thumbnail

    function loadFromJson(data) {
        for (let key of keys) {
            userInfo[key] = data[key] || "";
        }
    }

    function toJson() {
        return keys.reduce( function (p,c) {
            p[c] = userInfo[c];
            return p;
        }, ( { } ) );
    }
}
