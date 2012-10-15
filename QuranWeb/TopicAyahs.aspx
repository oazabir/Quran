<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TopicAyahs.aspx.cs" Inherits="QuranWeb.TopicAyahs" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link rel="stylesheet" media="screen" href="/style.css" />
    <style type="text/css">
        #topicHeader {position:fixed; top:0; left:0; z-index:2000; width:100%;background: white;}
        .topic { font-style: italic; display: inline; font-size: 140% }        
        .relatedAyahs { font-style: italic; display: inline; font-size: 10pt; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <header>
            <div id="topicHeader" class="minimizable">
                <span id="topicName" class="topic" runat="server"></span>                    
            </div>
            <br />
            <br />
        </header>        
        <div>
            <asp:Panel ID="pnlVerses" CssClass="relatedAyahs" runat="server"></asp:Panel>            
        </div>
    </form>
</body>
</html>
