<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Settings.aspx.cs" Inherits="QuranWeb.Settings" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Quran Reader Settings</title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
        <a href="<%= GoBackUrl %>">Go back</a>
        <asp:CheckBoxList ID="TranslationsList" runat="server" />

        <asp:Button ID="Save" Text="Save" runat="server" OnClick="Save_Clicked" />
    </div>
    </form>
</body>
</html>
