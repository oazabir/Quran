<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Corpus.aspx.cs" Inherits="QuranWeb.Corpus" %>
<%@ OutputCache Location="ServerAndClient" Duration="2592000" VaryByParam="*" %>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Corpus - Word by Word translation</title>
    <link rel="stylesheet" media="screen" href="/style.css" />
    <script src="/scripts/jquery-1.4.3.min.js" type="text/javascript"></script>
    <script type='text/javascript' src='/scripts/basic/js/jquery.simplemodal.js'></script>
    <script src="/scripts/qTip/jquery.qtip-1.0.0-rc3.min.js" type="text/javascript"></script>
    <style type="text/css">
        #simplemodal-container { z-index: 20000; background-color: white; }
    </style>    
    <script type="text/javascript">
        $(document).ready(function () {
            //                $(".wordbyword img").each(function () {
            //                    var e = $(this);
            //                    $(this).mouseover(function () {
            //                        var parent = $(this).parents(".wordbyword");
            //                        parent.css({ "height": "auto" });
            //                        parent.find('.grammar').show('slow');
            //                    });
            //                    $(this).mouseout(function () {
            //                        var parent = $(this).parents(".wordbyword");
            //                        parent.css({ "height": "160px" });
            //                        parent.find('.grammar').hide('slow');
            //                    });
            //                });
            $(".wordbyword").each(function (i, r) {
                $(this).qtip({
                    content: $(this).find(".grammar").html(),
                    position: {
                        corner: {
                            target: 'topMiddle',
                            tooltip: 'bottomMiddle'
                        }
                    }
                });

                //                    $(this).mouseenter(function () {
                //                        var width = $(this).width();
                //                        $(this).width(width);

                //                        //                        var pos = $(this).position();
                //                        //                        $(this).css({ "height": "auto", "position": "absolute", "top": pos.top + "px", "left": pos.left + "px" });

                //                        //$(this).next().css("margin-left", width + "px");
                //                        $(this).css("height", "auto");
                //                        $(this).find('.grammar').show('slow');
                //                    });
                //                    $(this).mouseleave(function () {
                //                        $(this).css({ "height": "100px" });
                //                        //$(this).next().css("margin-left", "0");

                //                        $(this).find('.grammar').hide('slow');
                //                    });
                $(this).click(function (e) {
                    var currentUrl = document.location.href.replace(/\/$/g, '');
                    currentUrl = currentUrl.replace(/\?.*/, '');
                    $('#basic-modal-content>iframe').attr('src', currentUrl + '/' + (i + 1));
                    $('#basic-modal-content').modal();
                    $('#simplemodal-container').css('z-index', '20000');
                    return false;
                });
            });
        });
    </script>
</head>
<body>
    <%= GenerateHtml() %>
</body>
</html>
