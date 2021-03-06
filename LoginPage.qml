import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import Qt.labs.settings 1.1

import "networkaccessmanager.js" as NAM

Page {
    title: qsTr("Login")

    property Settings serverSettings

    ColumnLayout {
        id: columnLayout
        anchors.centerIn: parent

        TextField { id: txtUser; placeholderText: "login" }

        TextField { id: txtPassword; placeholderText: "password"; echoMode: TextInput.Password }

        Button {
            id: loginButton
            Layout.preferredWidth: parent.width
            text: "login"
            onClicked: login()
            Text {
                id: errorText
                color: "#607D8B"
                horizontalAlignment: Label.AlignHCenter
                anchors { horizontalCenter: parent.horizontalCenter; top: loginButton.bottom; topMargin: columnLayout.spacing }
            }
        }
    }

    Settings {
        id: userSettings
        property alias user: txtUser.text
        property alias password: txtPassword.text
    }

    Component.onCompleted: {
        if (Qt.platform.os != "android") txtUser.forceActiveFocus()
        if (userSettings.user !== "" && userSettings.password !== "") {
            txtUser.text = userSettings.user
            txtPassword.text = userSettings.password
            login()
        }
    }

    function login() {
        NAM.busyIndicator = busyIndicator
        NAM.errorText = errorText
        NAM.httpRequest.onreadystatechange=function() {
            if (NAM.httpRequest.readyState === XMLHttpRequest.DONE && NAM.httpRequest.status != 0) {
                NAM.reset()
                var re = /<title>:: SEI - Controle de Processos ::<\/title>/
                if (re.test(NAM.httpRequest.responseText)) {
                    var processedResponseText = NAM.httpRequest.responseText.replace(/&nbsp;/g, '').replace(/<!DOCTYPE.*>/g, '').replace(/<meta.*>/g, '').replace(/&/g, '&amp;');
                    stackView.push("qrc:/MainPage.qml",
                                   {currentUser: txtUser.text,
                                    unitiesModelXml: processedResponseText,
                                    receivedModelXml: processedResponseText,
                                    generatedModelXml: processedResponseText,
                                    userSettings: userSettings
                                   })
                    if (Qt.platform.os == "android") {
                        configurator.username = txtUser.text
                        configurator.password = txtPassword.text
                    }
                } else {
                    errorText.text = "acesso negado"
                }
            }
        }
        NAM.post('https://sei.ifba.edu.br/sip/login.php?sigla_orgao_sistema=IFBA\&sigla_sistema=SEI',
                 'hdnCaptcha=' + internal.hdnCaptcha + '&hdnIdSistema=100000100&hdnMenuSistema=&hdnModuloSistema=&hdnSiglaOrgaoSistema=IFBA&hdnSiglaSistema=SEI&pwdSenha=' + txtPassword.text + '&sbmLogin=Acessar&selOrgao=0&txtUsuario=' + txtUser.text)
    }

    StackView.onRemoved: {
        serverSettings.serverURL = ""
        serverSettings.siglaOrgaoSistema = ""
        serverSettings.siglaSistema = "SEI"
    }
}
