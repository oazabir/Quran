<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="WordDetails.aspx.cs" Inherits="QuranWeb.WordDetails" %>
<%@ Import Namespace="QuranObjects" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Word Details</title>

    <style>

    * { font-family: Georgia }
    p { margin: 5px }
    .the_word { font-weight: bold } 
    .root_english { font-style: italic; display: inline; font-size: 150% }
    .root_arabic { font-style: italic; display: inline; color: green; font-size: 150% }
    .root_meanings { border-bottom: 1px dashed gray; padding-bottom: 5px }
    .other_meanings_of_arabic { }
    .other_meanings_of_root { border-bottom: 1px dashed gray; padding-bottom: 5px }
    
    .arabic_word { display: inline; color: Navy }
    .english_word { display: inline; color: black }
    
    .other_meanings_arabic { }
    .other_meanings_arabic_verse { color: Navy }
    
    .same_arabic_word_True { background-color: Lightgreen }
    .same_arabic_word_False { }
    
    .bottom_bar { border-bottom: 1px dashed lightgrey }
    
    .verse_ref { text-decoration: none; font-size: 70% }
    
    label { font-weight: bold; margin-right: 10px } 
    
    .bangla_meaning_textbox { border: 1px dotted grey; font-size: 14pt; width: 350px }
    
    tr { padding: 5px } 
    table { text-align: left }
    td { padding: 3px }
    </style>
    <link type="text/css" href="/scripts/basic/css/basic.css" rel="stylesheet" media="screen" />
    <style>
        #simplemodal-container { width: 500px; height: 400px; z-index: 20000; background-color: white; }
    </style>
    <script src="/scripts/jquery-1.4.3.min.js" type="text/javascript"></script>
    <script type="text/javascript" src="/scripts/basic/js/jquery.simplemodal.js"></script>
    <script type="text/javascript" src="scripts/uframe/aa-ha-index.js"></script>
    <script type="text/javascript" src="scripts/uframe/aa-hw-index.js"></script>
    <script type="text/javascript" src="scripts/uframe/aa-ll-index.js"></script>
    <script type="text/javascript" src="scripts/Dictionary.js"></script>
    <script type="text/javascript">
        jQuery(document).ready(function () {
            $("a.verse_ref").click(function (e) {
                $('#basic-modal-content>iframe').attr('src', $(this).attr("href") + "?minimal=1");
                $('#basic-modal-content').modal();
                return false;
            });

            var root = $('.root_arabic').text().replace(" ", "");
            var hash = do_search(root);
            $('#classical_dictionary').attr("href", "http://ejtaal.net/m/aa/" + hash);
        });
    </script>
</head>
<body>
    <form id="form1" runat="server"  accept-charset="utf-8" >
    <div>
    
        <p class="the_word"><asp:Literal ID="TheWord" runat="server" /></p>
        <p class="root_english"><asp:Literal ID="RootEnglish" runat="server" /> (<span class="root_arabic"><asp:Literal ID="RootArabic" runat="server" /></span>)</p>
        <p class="root_meanings"><label>Lexicon: </label><asp:Literal ID="RootMeanings" runat="server" /><small>Source: Project Root List</small></p>
        <p class="root_meanings"><asp:HyperLink ID="DictionaryLink" runat="server" NavigateUrl="http://dictionary.speakarabicquickly.com/dictionary/search/{0}" Target="_blank">Modern Dictionary</asp:HyperLink> |  <a id="classical_dictionary" target="_blank" href="http://ejtaal.net/m/aa/#">Hans, Lane, Hava</a> </p>
        <p class="root_meanings"><label>Bangla: </label><asp:TextBox ID="BanglaMeanings" runat="server" Columns="50" CssClass="bangla_meaning_textbox" /><asp:Button runat="server" ID="SaveBanglaMeanings" OnClick="SaveBanglaMeanings_Clicked" Text="Save" /></p>
        <p class="other_meanings_of_arabic"><label>Other translations of same arabic:</label> 
            <asp:Repeater ID="OtherMeaningsOfArabic" runat="server">
                <ItemTemplate><span class="other_meanings_arabic"><%# DataBinder.Eval(Container.DataItem, "EnglishMeaning") %></span> 
                    <a class="verse_ref" target="_top" href="/<%# DataBinder.Eval(Container.DataItem, "SurahNo") %>/<%# DataBinder.Eval(Container.DataItem, "VerseNo") %>">(<%# DataBinder.Eval(Container.DataItem, "SurahNo") %>:<%# DataBinder.Eval(Container.DataItem, "VerseNo") %>:<%# DataBinder.Eval(Container.DataItem, "WordNo") %>)</a></ItemTemplate>
                <SeparatorTemplate>, </SeparatorTemplate>
            </asp:Repeater>
        </p>
        <p class="other_meanings_of_root"><label>Other translations of same root: </label>
            <asp:Repeater ID="OtherMeaningsOfRoot" runat="server">
                <ItemTemplate>
                    <span class="other_meanings_root"><%# DataBinder.Eval(Container.DataItem, "EnglishMeaning") %> <sup><%# DataBinder.Eval(Container.DataItem, "Usage") %></sup></span>                     
                </ItemTemplate>
                <SeparatorTemplate>, </SeparatorTemplate>
            </asp:Repeater>, Total: <asp:Label ID="TotalRootUsage" runat="server" />
        </p>


        <table cellpadding="0" cellspacing="0" >
            <thead>
                <tr>
                    <th>Transliteration</th>
                    <th>Meaning</th>
                    <th>Grammar</th>
                    <th>Usage count</th>
                </tr>
            </thead>
            <tbody>
                <asp:Repeater runat="server" ID="MeaningList">            
                    <ItemTemplate>
                        <tr class="same_arabic_word_<%# DataBinder.Eval(Container.DataItem, "SameArabicWord") %>">
                            <td class="arabic_word"><%# DataBinder.Eval(Container.DataItem, "Arabic") %></td>
                            <td class="english_meaning"><%# DataBinder.Eval(Container.DataItem, "EnglishMeaning") %></td>
                            <td class="grammar"><%# DataBinder.Eval(Container.DataItem, "Grammar") %></td>
                            <td class="occurences"><%# DataBinder.Eval(Container.DataItem, "Usage") %></td>
                        </tr>

                        <tr class="same_arabic_word_<%# DataBinder.Eval(Container.DataItem, "SameArabicWord") %>">
                            <td class="bottom_bar matched_verses" colspan="4">
                                <asp:Repeater ID="OtherVerses" runat="server" DataSource='<%# DataBinder.Eval(Container.DataItem, "Verses") %>'>
                                    <ItemTemplate><a target="_top" class="verse_ref" href="/<%# DataBinder.Eval(Container.DataItem, "SurahNo") %>/<%# DataBinder.Eval(Container.DataItem, "VerseNo") %>"><%# DataBinder.Eval(Container.DataItem, "SurahNo") %>:<%# DataBinder.Eval(Container.DataItem, "VerseNo") %>:<%# DataBinder.Eval(Container.DataItem, "WordNo") %></a></ItemTemplate>
                                    <SeparatorTemplate>, </SeparatorTemplate>
                                </asp:Repeater>
                            </td>
                        </tr>
                    </ItemTemplate>
                </asp:Repeater>
            </tbody>
        </table>
        
    </div>

    <div id="basic-modal-content">
        <iframe src="" style="width:500px; height:400px; boder: none" frameborder="0"></iframe>
    </div>
    </form>
</body>
</html>
