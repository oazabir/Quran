<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="QuranWeb.Default" ValidateRequest="false" %>
<%@ OutputCache Location="None" NoStore="true" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
    <head runat="server">
        <title>Quran Reader</title>

        <meta http-equiv="Content-Type" content="text/html;charset=UTF-8" />

        <link rel="stylesheet" media="screen" href="/style.css" />
        <link type="text/css" href="/scripts/basic/css/basic.css" rel="stylesheet" media="screen" />
        <script src="/scripts/jquery-1.4.3.min.js" type="text/javascript"></script>
        
        <link rel="Stylesheet" type="text/css" href="/jHtmlArea/style/jHtmlArea.css" />
        <script  type="text/javascript" src="/scripts/jquery.htmlClean-min.js"></script>
        <script  type="text/javascript" src="/jHtmlArea/scripts/jHtmlArea-0.7.0.min.js"></script>

        <script src="scripts/uframe/htmlparser.js" type="text/javascript"></script>
        <script src="scripts/uframe/UFrame.js" type="text/javascript"></script>
        
        <%--<script type='text/javascript' src='/scripts/basic/js/jquery.simplemodal.js'></script>
        <script src="/scripts/qTip/jquery.qtip-1.0.0-rc3.min.js" type="text/javascript"></script>--%>
        
        <script type="text/javascript">
            
            var parts = window.location.pathname.split('/');
            var ayah = parts[parts.length - 1];
            var surah = parts[parts.length - 2];

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

            jQuery(document).ready(function () {

                $('#Goto')
                    .focus(function () { 
                        $(this).val(""); 
                    })
                    .keypress(function(event) { 
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

                $("#MyTranslation").htmlarea({
                    css: "jHtmlArea/style/jHtmlArea.Editor.css",
                    toolbar: ["html", "bold", "italic", "subscript", "superscript"]
                });
                $("#Footnote").htmlarea({
                    css: "jHtmlArea/style/jHtmlArea.Editor.css",
                    toolbar: ["html", "bold", "italic", "subscript", "superscript"]
                });

                UFrameManager.init({
                    id: "corpus",  // id of the DIV

                    loadFrom: "/corpus.aspx",
                    initialLoad: "GET",                    
                    params: {"surah":surah, "ayah":ayah},   // parameters to post/get to 
                    
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
            function ShowHideAllLanguage()
            {
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

            function getCookie(c_name) {
                var i, x, y, ARRcookies = document.cookie.split(";");
                for (i = 0; i < ARRcookies.length; i++) {
                    x = ARRcookies[i].substr(0, ARRcookies[i].indexOf("="));
                    y = ARRcookies[i].substr(ARRcookies[i].indexOf("=") + 1);
                    x = x.replace(/^\s+|\s+$/g, "");
                    if (x == c_name) {
                        return unescape(y);
                    }
                }
            }

	    </script>

        <style  type="text/css">
        <% if( Request["minimal"] == "1") { %>
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

<form id="form1" runat="server" accept-charset="utf-8" >
  
<asp:Panel ID="pnlMyTranslationEdit" runat="server" CssClass="minimizable editor">
    <p>Heading</p>
    <asp:TextBox ID="Heading" runat="server" TextMode="SingleLine" Columns="30" Font-Size="14pt" />
    <p>Translation</p>
    <asp:TextBox ID="MyTranslation" runat="server" TextMode="MultiLine" Columns="32" Rows="12" Font-Size="14pt" />
    <p>Footnote</p>
    <asp:TextBox ID="Footnote" runat="server" TextMode="MultiLine" Columns="40" Rows="10" Font-Size="12pt"/>            
    <p><asp:CheckBox ID="NewPara" runat="server" Text="New para after this?" /></p>
    <hr />
    <asp:Button ID="Save" class="button" runat="server" Text="Save" OnClientClick="cleanHtml()" OnClick="Save_Clicked" />
    <hr />
    <p>Checklist</p>
    <p>
        <label><input type="checkbox" /> I and We, You singularity and plurality addressed?</label><br />
        <label><input type="checkbox" /> Pronouns are matched with superscript label?</label><br />
        <label><input type="checkbox" /> Additional words italiced?</label><br />
        <label><input type="checkbox" /> Multi meaning words within brackets?</label><br />
        <label><input type="checkbox" /> Footnote * matches?</label><br />
        <label><input type="checkbox" /> Female nound and verbs highlighted?</label><br />
        <label><input type="checkbox" /> Punctuations from Abdel Haleem?</label><br />
        <label><input type="checkbox" /> Rational arguments from Edip?</label><br />
        <label><input type="checkbox" /> Footnote source added in bibliography and reference given?</label><br />
                        
    </p>
</asp:Panel>

<div id="container" class="<%= pnlMyTranslationEdit.Visible ? "editorOn" : "" %>">
    <header>
        <div id="header" class="minimizable">
            <div id="headline">
                <h1>Quran <%= Request["surah"]??"1" %>:<%= Request["ayah"]??"1" %></h1>
            </div>
            <div class="dropdowns">
                Surah: <asp:DropDownList ID="ddlSurahs" runat="server" autopostback="true"
                        onselectedindexchanged="ddlSurahs_SelectedIndexChanged"></asp:DropDownList><asp:Button runat="server" OnClick="ddlSurahs_SelectedIndexChanged" Text="Go" />
                        
                        <span style="width: 50px;"></span>
                Ayah: 
                    <asp:DropDownList ID="ddlAyahs" runat="server" autopostback="true"
                        onselectedindexchanged="ddlAyahs_SelectedIndexChanged"></asp:DropDownList>
                    <asp:Button runat="server" OnClick="ddlAyahs_SelectedIndexChanged" Text="Go" />

                Go to:
                <input id="Goto" type="text" value="" size="10"/>
            </div>
            <div class="navigation">
                <asp:HyperLink runat="server" Text="Prev" ID="PrevAyah" />
                <asp:HyperLink runat="server" Text="Next" ID="NextAyah" />
            </div>

            <div class="menu">
                <asp:DropDownList ID="ddlLanguageFilter" runat="server" autopostback="true"
                        onselectedindexchanged="ddlLanguageFilter_SelectedIndexChanged"></asp:DropDownList>
                <a href="/Settings.aspx">More Translations</a> 
            </div>
        </div>
    </header>

    <div id="main">
        <section>
            <div id="corpus" CssClass="wordsContainer minimizable <%= pnlMyTranslationEdit.Visible ? "editorOn" : "" %>">
                <p>Loading Word by Word Translation from corpus.quran.com...</p>
            </div>
            		
            <small class="clear">Source: <a href="http://corpus.quran.com">Quran.com</a></small>	
        </section>

        <section>
            <div class="clear">
                <p class="type">Arabic</p>
                <asp:Panel ID="pnlOriginal" runat="server"></asp:Panel>
                <asp:Panel ID="pnlTransliteration" runat="server"></asp:Panel>                
                
                <p class="type">Bangla (in progress) <small><asp:LinkButton ID="ToggleBangla" runat="server" OnClick="ToggleBangla_Click" Text="Hide Bangla" ForeColor="Navy" /></small></p>
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
              
                <p class="type">Generally Accepted</p>
                <asp:Panel ID="pnlAccepted" runat="server"></asp:Panel>
                 <asp:Panel ID="pnlGenAcceptedAll" runat="server"   Style="display:none" ></asp:Panel>
                <p class="type">Controversal</p>
                <asp:Panel ID="pnlControversal" runat="server"></asp:Panel>
                 <asp:Panel ID="pnlControversalAll" runat="server"     Style="display:none" ></asp:Panel>
                <p class="type">Non-Muslim and/or Orientalist</p>
                <asp:Panel ID="pnlNonMuslim" runat="server"></asp:Panel>
                 <asp:Panel ID="pnlNonMuslimAll" runat="server"    Style="display:none" ></asp:Panel>
                
            </div>
        </section>

        
        
        <section>        
            <div class="clear secondnavigation minimizable">
                <p>
                    <asp:HyperLink runat="server" Text="Prev" ID="PrevAyah2" />
                    <asp:HyperLink runat="server" Text="Next" ID="NextAyah2" />
                    |<a href="#" id="lnkLanguageAll" onclick="ShowHideAllLanguage();" >
                     <asp:Label ID="lblLanguageAll" runat="server" Text="[Show All Languages]"></asp:Label> </a>
                </p>
                <p>
                    <a href="/Settings.aspx">More Translations</a>
                </p>        
            </div>
            <hr />
        </section>

        <section>
            <div class="discussion minimizable">
                <div id="disqus_thread"></div>
                <script type="text/javascript">
                    /* * * CONFIGURATION VARIABLES: EDIT BEFORE PASTING INTO YOUR WEBPAGE * * */
                    var disqus_shortname = 'quran-omaralzabir'; // required: replace example with your forum shortname
                    var disqus_url = document.location.href.replace(/\?.*/, "");
                    /* * * DON'T EDIT BELOW THIS LINE * * */
                    (function () {
                        var dsq = document.createElement('script'); dsq.type = 'text/javascript'; dsq.async = true;
                        dsq.src = 'http://' + disqus_shortname + '.disqus.com/embed.js';
                        (document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]).appendChild(dsq);
                    })();
                </script>
            </div>
            
        </section>
    </div>

    <div id="basic-modal-content">
        <iframe src="" style="width:600px; height: 500px; border: none" frameborder="0"></iframe>
    </div>

    <footer>
        <div class="menu">
            Work in progress Bangla Translation: <a href="/MyTranslationReader.aspx?surah=<%= Request["surah"] %>">Entire Surah</a> | <a href="/GenerateWord.ashx?surah=<%= Request["surah"] %>">Word Doc</a> | <a href="/Rss.ashx">RSS</a>
        </div>
    </footer>
</div>
</form>
</body>
</html>
