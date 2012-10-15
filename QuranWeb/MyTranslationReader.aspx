<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="MyTranslationReader.aspx.cs" Inherits="QuranWeb.MyTranslationReader" %>
<%@ OutputCache Location="None" NoStore="true" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Modern Bangla Translation</title>

    <style>
        .heading { font-style: italic; font-size: 14pt; }
        .translation { display: inline; font-size: 16pt; text-indent: 20px; }
        .footnote { font-size: 14pt; }
        a { color: Green; text-decoration: none; }
        a.footnote_link { color: brown }
    </style>

    <script src="jquery-1.4.3.min.js" type="text/javascript"></script>
    <script type="text/javascript">
        function showFootnote(footnoteId) {
            $('#' + footnoteId).fadeIn('slow');
        }
    </script>
</head>

<body>
    <form id="form1" runat="server">
    <div>
        <asp:Panel ID="pnlTranslations" runat="server" />
        <hr />
        <asp:Panel ID="pnlFootnotes" runat="server" />
    </div>
    </form>
</body>
</html>
