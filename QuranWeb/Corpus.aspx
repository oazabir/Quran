<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Corpus.aspx.cs" Inherits="QuranWeb.Corpus" %>
<%@ OutputCache Location="ServerAndClient" Duration="2592000" VaryByParam="*" %>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Corpus - Word by Word translation</title>
    <link rel="stylesheet" media="screen" href="/corpus.css?v=5" />
    <script src="/scripts/jquery-1.4.3.min.js" type="text/javascript"></script>
    <script type='text/javascript' src='/scripts/basic/js/jquery.simplemodal.js'></script>
    <script src="/scripts/qTip/jquery.qtip-1.0.0-rc3.min.js" type="text/javascript"></script>
    <style type="text/css">
        #simplemodal-container { z-index: 20000; background-color: white; }
    </style>    
    <script type="text/javascript">
        $(document).ready(function () {
            
            $(".wordbyword").each(function (i, r) {
                
                $(r).qtip({
                    content: $(this).find(".grammar").html(),
                    position: {
                        corner: {
                            target: 'bottomMiddle',
                            tooltip: 'topLeft'
                        }
                    }
                });

                $("a", r).each(function(i, e){
                    $(r).attr("href", $(e).attr("href"));
                    $(e).attr("href_org", $(e).attr("href"))
                        .attr("href", "#");                    
                });

                $(this).click(function (e) {
                    //var currentUrl = document.location.href.replace(/\/$/g, '');
                    //currentUrl = currentUrl.replace(/\?.*/, '');
                    var baseUrl = document.location.href.substr(0, document.location.href.indexOf('/', 'http://'.length));
                    var corpusUrl = $(this).attr("href");
                    var locationUrl = corpusUrl.substring(corpusUrl.indexOf('(') + 1, corpusUrl.indexOf(')')).replace(/:/g, '/');
                    var popupUrl = baseUrl + '/' + locationUrl;

                    //$('#basic-modal-content>iframe').attr('src', currentUrl + '/' + (i + 1));
                    $('#basic-modal-content>iframe').attr('src', popupUrl);
                    $('#basic-modal-content').modal();
                    $('#simplemodal-container').css('z-index', '20000');
                    return false;
                })
                    
            });
            
        });
    </script>
</head>
<body>
    <%= GenerateHtml() %>
    <div class="clear"></div>
</body>
</html>
