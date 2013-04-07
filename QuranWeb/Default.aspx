<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="QuranWeb.Default" ValidateRequest="false" %>

<%@ OutputCache Location="None" NoStore="true" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Quran Reader - <%= PageTitle %></title>

    <meta http-equiv="Content-Type" content="text/html;charset=UTF-8" />

    <link rel="stylesheet" media="screen" href="/1/1/style.css?v=13" />
    <link type="text/css" href="/scripts/basic/css/basic.css?v=1" rel="stylesheet" media="screen" />
    <script src="/scripts/jquery-1.4.3.min.js" type="text/javascript"></script>
    <script src="scripts/jquery.searchabledropdown-1.0.8.min.js"></script>

    <% if (EditMode)
       { %>
    <link rel="Stylesheet" type="text/css" href="/jHtmlArea/style/jHtmlArea.css" />
    <script src="/scripts/jquery.htmlClean-min.js"></script>
    <script src="/jHtmlArea/scripts/jHtmlArea-0.7.0.min.js"></script>
    <% } %>

    <script src="scripts/uframe/htmlparser.js" type="text/javascript"></script>
    <script src="scripts/uframe/UFrame.js" type="text/javascript"></script>

    <%--<script type='text/javascript' src='/scripts/basic/js/jquery.simplemodal.js'></script>
        <script src="/scripts/qTip/jquery.qtip-1.0.0-rc3.min.js" type="text/javascript"></script>--%>

    <script type="text/javascript">

        var parts = window.location.pathname.split('/');
        var ayah = parts.length > 2 ? parts[parts.length - 1] : "1";
        var surah = parts.length > 2 ? parts[parts.length - 2] : parts[parts.length - 1];

        var nextSurah = <%= NextSurahNo %>;
        var nextAyah = <%= NextAyahNo %>;

        var minimal = <%= MinimalMode ? "true" : "false" %>;
        var qs = (function (a) {
            if (a == "") return {};
            var b = {};
            for (var i = 0; i < a.length; ++i) {
                var p = a[i].split('=');
                if (p.length != 2) continue;
                b[p[0]] = decodeURIComponent(p[1].replace(/\+/g, " "));
            }
            return b;
        })(window.location.search.substr(1).split('&'));

        window.loadNextAyah = function (event, force) {
            var scrollTop = $(window).scrollTop();
            var docHeight = $(document.body).height();
            var windowHeight = $(window).height();

            if (force || (docHeight > windowHeight && (scrollTop >= docHeight - windowHeight - 100))) {
                console.log(force + " (scrollTop >= docHeight - windowHeight - 100)" + (scrollTop >= docHeight - windowHeight - 100));
                // stop receiving scroll notification until the next ayah iframe loads
                $(window).unbind("scroll");

                // load the next ayah
                var iframeUrl = "/" + nextSurah + "/" + nextAyah + "?minimal=true";
                
                $('<iframe src="' + iframeUrl + '" style="width:100%; height:400px; border:none" scrolling="no" frameborder="no" />')
                    .appendTo(document.body)
                    .load(function(){
                        if (nextAyah < $('#ddlAyahs').children().length)                            
                            $(window).bind("scroll", window.loadNextAyah);

                        nextAyah ++;
                    });

                
            }
        }

        window.resizeIframe = function (height, url, surah, ayah) {
            $("iframe").each(function (index, item) {
                var frame = $(item);
                var frameSrc = "" + frame.attr("src");
                if (url.indexOf(frameSrc) > 0) {
                    frame.height(height);
                }
            });
        }

        jQuery(document).ready(function () {

            if (minimal) {
                window.setInterval(function() {                    
                    window.parent.resizeIframe($(document).height(), document.location.href);
                }, 1000);
            }
            else {
                $(window).bind("scroll", window.loadNextAyah);
                window.setTimeout(function() {
                    if ($(document.body).height() <= $(window).height())
                        window.setTimeout(function() { window.loadNextAyah(null, true); }, 2000);
                }, 1000);
            }

            $("#<%=ddlSurahs.ClientID %>").searchable();
            
            $('#Goto')
                .focus(function () {
                    $(this).val("");
                })
                .keypress(function (event) {
                    if (event.keyCode == 13) {
                        var text = $(this).val();
                        var matches = text.match(/[^0-9]*(\d+)[^0-9]*(\d+)/);
                        if (matches.length > 1) {
                            var surah = matches[1];
                            var ayah = matches[2] || 1;
                            document.location.href = "/" + surah + "/" + ayah;
                        }
                        return false;
                    }
                });

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

            if ($("#MyTranslation").length > 0) {
                $("#MyTranslation").htmlarea({
                    css: "jHtmlArea/style/jHtmlArea.Editor.css",
                    toolbar: ["html", "bold", "italic", "subscript", "superscript"]
                });
                $("#Footnote").htmlarea({
                    css: "jHtmlArea/style/jHtmlArea.Editor.css",
                    toolbar: ["html", "bold", "italic", "subscript", "superscript"]
                });
            }


            UFrameManager.init({
                id: "corpus",  // id of the DIV

                loadFrom: "/corpus.aspx",
                initialLoad: "GET",
                params: { "surah": surah, "ayah": ayah, version: '2', "cookie": document.cookie },   // parameters to post/get to 

            });
        });

        function cleanHtml() {

            jHtmlArea($("#MyTranslation")).updateTextArea();
            jHtmlArea($("#Footnote")).updateTextArea();

            var translation = $("#MyTranslation").val();
            var footnote = $("#Footnote").val();
            var heading = $("#Heading").val();

            translation = translation.replace(/<!--(.*)-->/g, "");
            footnote = footnote.replace(/<!--(.*)-->/g, "");

            $("#MyTranslation").val(cleanTags($.htmlClean(translation, { allowedTags: ["em", "sub", "sup"] })));
            $("#Footnote").val(cleanTags($.htmlClean(footnote, { allowedTags: ["em", "sub", "sup"] })));
            $("#Heading").val(cleanTags($.htmlClean(heading, { allowedTags: ["em", "sub", "sup"] })));

            jHtmlArea($("#MyTranslation")).updateHtmlArea();
            jHtmlArea($("#Footnote")).updateHtmlArea();

            //                var fullcontent = $('#Heading').val() + '\r\n' + $('#MyTranslation').val() + '\r\n' + $('#Footnote').val();
            //                jQuery.copy(fullcontent);
        }

        function cleanTags(str) {
            str = str.replace(/<em><em>/g, "<em>");
            str = str.replace(/<\/em><\/em>/g, "</em>")
            str = str.replace(/<([^>]*)>\s*<\/\1>/g, ""); //empty tags
            return str.replace(/<\/(\w+)>(\S)/g, "</$1> $2");
        }

        //Open a popup window that shows all related ayats against a topic
        function topicDetails(topicId) {
            var url = document.location.protocol + '//' + document.location.host + '/TopicAyahs.aspx?topicId=' + topicId;
            $('#basic-modal-content>iframe').attr('src', url);
            $('#basic-modal-content').modal();
            $('#simplemodal-container').css('z-index', '20000');
            return false;
        }

        function ShowHideAllLanguage() {
            ShowHideAllSection('pnlGenAcceptedAll');
            ShowHideAllSection('pnlControversalAll');
            ShowHideAllSection('pnlNonMuslimAll');

            return false;
        }
        function ShowHideAllSection(id) {
            var pnl = id;
            var lbl = 'lblLanguageAll';
            if (document.getElementById(pnl).style.display == 'none') {
                document.getElementById(pnl).style.display = 'block';
                SetText(document.getElementById(lbl), "[Hide Other Languages]");
            }
            else {
                document.getElementById(pnl).style.display = 'none';
                SetText(document.getElementById(lbl), "[Show All Languages]");
            }
            return false;
        }
        function SetText(elem, changeVal) {
            if ((elem.textContent) && (typeof (elem.textContent) != "undefined")) {
                elem.textContent = changeVal;
            } else {
                elem.innerText = changeVal;
            }
        }

    </script>

    <style>
        <% if (MinimalMode)
           { %>
            .minimizable { display: none }                                              
        <% } %>                                              
        </style>

    <script type="text/javascript">

        var _gaq = _gaq || [];
        _gaq.push(['_setAccount', 'UA-31192943-1']);
        _gaq.push(['_trackPageview']);

        (function () {
            var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
            ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
            var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
        })();

    </script>
</head>
<body>

    <form id="form1" runat="server" accept-charset="utf-8">

        <asp:Panel ID="pnlMyTranslationEdit" runat="server" CssClass="minimizable editor">
            <p>Heading</p>
            <asp:TextBox ID="Heading" runat="server" TextMode="SingleLine" Columns="30" Font-Size="14pt" />
            <p>Translation</p>
            <asp:TextBox ID="MyTranslation" runat="server" TextMode="MultiLine" Columns="32" Rows="12" Font-Size="14pt" />
            <p>Footnote</p>
            <asp:TextBox ID="Footnote" runat="server" TextMode="MultiLine" Columns="40" Rows="10" Font-Size="12pt" />
            <p>
                <asp:CheckBox ID="NewPara" runat="server" Text="New para after this?" />
            </p>
            <hr />
            <asp:Button ID="Save" class="button" runat="server" Text="Save" OnClientClick="cleanHtml()" OnClick="Save_Clicked" />
            <hr />
            <p>Checklist</p>
            <p>
                <label>
                    <input type="checkbox" />
                    I and We, You singularity and plurality addressed?</label><br />
                <label>
                    <input type="checkbox" />
                    Pronouns are matched with superscript label?</label><br />
                <label>
                    <input type="checkbox" />
                    Additional words italiced?</label><br />
                <label>
                    <input type="checkbox" />
                    Multi meaning words within brackets?</label><br />
                <label>
                    <input type="checkbox" />
                    Footnote * matches?</label><br />
                <label>
                    <input type="checkbox" />
                    Female nound and verbs highlighted?</label><br />
                <label>
                    <input type="checkbox" />
                    Punctuations from Abdel Haleem?</label><br />
                <label>
                    <input type="checkbox" />
                    Rational arguments from Edip?</label><br />
                <label>
                    <input type="checkbox" />
                    Footnote source added in bibliography and reference given?</label><br />

            </p>
        </asp:Panel>

        <div id="container" class="<%= pnlMyTranslationEdit.Visible ? "editorOn" : "" %>">
            <div id="header" class="minimizable">
                <div id="headline">
                    <h1><%= PageTitle %></h1>
                </div>
                <div class="navigation minimizable">
                    <table>
                        <tr>
                            <td valign="middle">Surah:</td>
                            <td>
                                <asp:DropDownList ID="ddlSurahs" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlSurahs_SelectedIndexChanged"></asp:DropDownList></td>
                            <td>
                                <asp:Button runat="server" OnClick="ddlSurahs_SelectedIndexChanged" Text="Go" /></td>
                            <td valign="middle">Ayah:
                                <asp:DropDownList ID="ddlAyahs" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlAyahs_SelectedIndexChanged"></asp:DropDownList>
                                <asp:Button runat="server" OnClick="ddlAyahs_SelectedIndexChanged" Text="Go" />
                            </td>
                            <td valign="middle">Jump:<input id="Goto" type="text" value="" size="10" /></td>
                            <td>
                                <asp:HyperLink runat="server" Text="Prev" ID="PrevAyah" />
                                |
                                <asp:HyperLink runat="server" Text="Next" ID="NextAyah" /></td>
                        </tr>
                    </table>
                </div>

                <div id="menu" class="minimizable">
                    <asp:DropDownList ID="ddlLanguageFilter" runat="server" AutoPostBack="true"
                        OnSelectedIndexChanged="ddlLanguageFilter_SelectedIndexChanged">
                    </asp:DropDownList>
                    <label>Search:
                        <input id="search" type="text" size="20" /></label>
                    | <a href="/Settings.aspx">Options</a>
                </div>
            </div>

            <div id="main">
                <asp:Panel ID="WordByWordContainer" runat="server">
                    <div class="wordbyword_tip">Click on a word for detail analysis</div>
                    <div id="corpus" class="wordsContainer <%= pnlMyTranslationEdit.Visible ? "editorOn" : "" %>" >
                        <p>Loading Word by Word Translation from corpus.quran.com...</p>

                        <div class="clear"></div>
                    </div>

                    <div id="source_corpus">Source: <a href="http://corpus.quran.com">corpus.quran.com</a></div>
                </asp:Panel>
                <div id="translations">
                    <asp:Label ID="AyahLabel" runat="server" />

                    <div id="relevant_topics">
                        <p class="type">Relevant Topics</p>
                        <i>
                            <asp:Panel ID="pnlRelevantVerses" runat="server"></asp:Panel>
                            <br />
                        </i>
                        <a href="/TopicIndex.html">View Topic Index</a>
                    </div>

                    <div class="translation_text">

                        <!--<p class="type">Arabic</p>-->
                        <asp:Panel ID="pnlOriginal" runat="server"></asp:Panel>
                        
                        <asp:Panel ID="pnlTransliteration" runat="server"></asp:Panel>

                        <!--<p class="type">Generally Accepted</p>-->
                        <asp:Panel ID="pnlAccepted" runat="server"></asp:Panel>
                        <asp:Panel ID="pnlGenAcceptedAll" runat="server" Style="display: none"></asp:Panel>
                    
                        <asp:Panel ID="pnlControversal" runat="server" Visible="false">
                            <p class="type">Controversal</p>
                    
                        </asp:Panel>
                        <asp:Panel ID="pnlControversalAll" runat="server" Style="display: none">
                            <p class="type">Controversal</p>
                    
                        </asp:Panel>
                    
                        <asp:Panel ID="pnlNonMuslim" runat="server" Visible="false">
                            <p class="type">Non-Muslim and/or Orientalist</p>
                    
                        </asp:Panel>
                        <asp:Panel ID="pnlNonMuslimAll" runat="server" Style="display: none">
                            <p class="type">Non-Muslim and/or Orientalist</p>
                    
                        </asp:Panel>

                        <p class="type" id="BanglaInProgress" runat="server">
                            Bangla (in progress)                                 
                        </p>
                        <asp:Panel ID="pnlMyTranslationView" runat="server">
                            <p>
                                <asp:Label ID="lblHeading" class="my_translation_heading" runat="server" />
                            </p>
                            <p>
                                <asp:Label ID="lblMyTranslation" class="my_translation_text" runat="server" />
                            </p>
                            <p>
                                <asp:Label ID="lblFootnote" class="my_translation_footnote" runat="server" />
                            </p>
                        </asp:Panel>
                    </div>

                </div>
                <%--<div class="clear secondnavigation minimizable">
                    <asp:HyperLink runat="server" Text="Prev" ID="PrevAyah2" />
                    |
                    <asp:HyperLink runat="server" Text="Next" ID="NextAyah2" />
                    | <a href="/Settings.aspx">More Translations</a>
                </div>--%>
                
                
            </div>

            <div id="basic-modal-content">
                <iframe src="" style="width: 600px; height: 400px; border: none" frameborder="0"></iframe>
            </div>

            <!--
            <div class="menu minimizable">
                Work in progress Bangla Translation: <a href="/MyTranslationReader.aspx?surah=<%= SurahNo %>">Entire Surah</a> | <a href="/GenerateWord.ashx?surah=<%= SurahNo %>">Word Doc</a> | <a href="/Rss.ashx">RSS</a>
            </div>
            -->
            
        </div>
    </form>    
    <p class="source minimizable" align="right"><a href="https://github.com/oazabir/Quran/wiki">Get the Source Code</a></p>
    <hr />
            
    <script id="_webengage_script_tag" type="text/javascript">
        if (!minimal) {
            window.webengageWidgetInit = window.webengageWidgetInit || function(){
                webengage.init({
                    licenseCode:"aa13163a"
                }).onReady(function(){
                    webengage.render();
                });
            };

            (function(d){
                var _we = d.createElement('script');
                _we.type = 'text/javascript';
                _we.async = true;
                _we.src = (d.location.protocol == 'https:' ? "//ssl.widgets.webengage.com" : "//cdn.widgets.webengage.com") + "/js/widget/webengage-min-v-3.0.js";
                var _sNode = d.getElementById('_webengage_script_tag');
                _sNode.parentNode.insertBefore(_we, _sNode);
            })(document);
        }
</script>
</body>

<!-- YAMLI CODE START -->
<script type="text/javascript" src="http://api.yamli.com/js/yamli_api.js"></script>
<script type="text/javascript">
    if (!minimal) {
        if (typeof (Yamli) == "object" && Yamli.init({ uiLanguage: "en", startMode: "onOrUserDefault" })) {
            Yamli.yamlify("search", { settingsPlacement: "bottomLeft" });
        }
    }
</script>
<!-- YAMLI CODE END -->

</html>
