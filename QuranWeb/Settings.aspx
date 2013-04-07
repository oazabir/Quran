<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Settings.aspx.cs" Inherits="QuranWeb.Settings" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Quran Reader Settings</title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
        <asp:Button ID="Save" Text="Save" runat="server" OnClick="Save_Clicked" />
        <asp:Button ID="Reset" Text="Reset" runat="server" OnClick="Reset_Click" />
        
        <fieldset>
            <legend>Settings</legend>
            <p>
                <asp:CheckBox ID="LeftToRightCheckbox" runat="server" Text="Show word by word translation left to right." />
            </p>
            <p>
                <asp:CheckBox ID="DisableWordByWord" runat="server" Text="Don't show word by word transaction." />
            </p>
            <p>
                <asp:CheckBox ID="ShowInProgressBangla" runat="server" Text="Show in progress Bangla transaction." />
            </p>
        </fieldset>
        <fieldset>
            <legend>Translations to show</legend>
            <asp:CheckBoxList ID="TranslationsList" runat="server" />

        </fieldset>
        
    </div>
    </form>
</body>
</html>
