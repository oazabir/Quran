<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Search.aspx.cs" Inherits="QuranWeb.Search" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Search</title>
    <style>
        * {
            font-family: Georgia;
            font-size: 12pt;
        }
        em {
            font-size: 12pt;
            font-style: normal;
            background-color: lightgreen;
        }

        big {
            font-size: 18pt;
            line-height: 1.5em;
            font-family: Arial;
        }

        small {
            font-size: 10pt;
            color: gray;
        }

    </style>
</head>
<body>
    <div>
        <label>Search: <input id="search" type="text" size="20" /></label>
    </div>
    <hr />
    <form id="form1" runat="server">
        <asp:GridView ID="SearchResultGridView" runat="server" AutoGenerateColumns="False">
            <Columns>
                <asp:BoundField DataField="SurahNo" HeaderText="Surah" />
                <asp:BoundField DataField="AyahNo" HeaderText="Ayah" />
                <asp:BoundField DataField="Result" HeaderText="Arabic" HtmlEncode="false" />
                <asp:BoundField DataField="Other" HeaderText="Translation" HtmlEncode="false" />
                <asp:HyperLinkField DataNavigateUrlFields="SurahNo,AyahNo" DataNavigateUrlFormatString="/{0}/{1}" HeaderText="Goto" Text="Goto" />
            </Columns>
        </asp:GridView>
    </form>
</body>
    <script src="/scripts/jquery-1.4.3.min.js" type="text/javascript"></script>

<!-- YAMLI CODE START -->
<script type="text/javascript" src="http://api.yamli.com/js/yamli_api.js"></script>
<script type="text/javascript">
    if (typeof (Yamli) == "object" && Yamli.init({ uiLanguage: "en", startMode: "onOrUserDefault" })) {
        Yamli.yamlify("search", { settingsPlacement: "bottomLeft" });
    }
</script>
<!-- YAMLI CODE END -->

    <script>
        $(document).ready(function () {
            $('#search')                
                .focus(function () {
                    $(this).val("");
                })
                .keypress(function (event) {
                    if (event.keyCode == 13) {
                        var text = $(this).val();
                        document.location = "/Search.aspx?query=" + encodeURI(text) + "&arabic=" + Yamli.getInstances()[0].getEnabled();
                        return false;
                    }
                });
        });

    </script>
</html>
