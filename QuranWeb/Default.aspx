<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="QuranWeb.Default" ValidateRequest="false" %>

<%@ OutputCache Location="None" NoStore="true" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Quran Reader - <%= PageTitle %></title>

    <meta http-equiv="Content-Type" content="text/html;charset=UTF-8" />

    <link href="scripts/jsqari/skin/jsqari.skin.css" rel="stylesheet" />
    <link rel="stylesheet" media="screen" href="style.css?v=15" />
    <link type="text/css" href="scripts/basic/css/basic.css?v=1" rel="stylesheet" media="screen" />            
 

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

                    <div id="menu" class="minimizable">
                        <div id="language_area">
                        <label>Language: <asp:DropDownList ID="ddlLanguageFilter" runat="server" AutoPostBack="true"
                            OnSelectedIndexChanged="ddlLanguageFilter_SelectedIndexChanged">
                        </asp:DropDownList></label>
                        </div>
                        <div id="search_area">
                        <label>Search:
                            <input id="search" type="text" size="20" /></label>
                        </div>
                        <div id="options_area">
                            <a href="/Settings.aspx">Options</a>
                        </div>
                    </div>
                    <div id="relevant_topics">
                        <p class="type">Relevant Topics</p>
                        <i>
                            <asp:Panel ID="pnlRelevantVerses" runat="server"></asp:Panel>
                            <br />
                        </i>
                        <a href="/TopicIndex.html">View Topic Index</a>
                    </div>

                    <% if (!MinimalMode) { %>
                    <div id="player">
                        
                        <form class="jsqari-interface">
		                    <ul>
			                    <li class="single display_none">
			                    From:</li>
			                    <li>
				                    <span>
					                    <select id="jsqari-ui-surah-from-selector" class="medium">
						                    <option value="1">1. Al-Faatiha</option>
						                    <option value="2">2. Al-Baqarah</option>
						                    <option value="3">3. Aale 'Imran</option>
						                    <option value="4">4. An-Nisaa</option>
						                    <option value="5">5. Al-Maaidah</option>
						                    <option value="6">6. Al-An'aam</option>
						                    <option value="7">7. Al-A'raaf</option>
						                    <option value="8">8. Al-Anfaal</option>
						                    <option value="9">9. At-Tawbah</option>
						                    <option value="10">10. Younus</option>
						                    <option value="11">11. Huud</option>
						                    <option value="12">12. Yusuf</option>
						                    <option value="13">13. Ar-Ra'ad</option>
						                    <option value="14">14. Ibraheem</option>
						                    <option value="15">15. Al-Hijr</option>
						                    <option value="16">16. An-Nahl</option>
						                    <option value="17">17. Al-Israa</option>
						                    <option value="18">18. Al-Kahf</option>
						                    <option value="19">19. Maryam</option>
						                    <option value="20">20. Taha</option>
						                    <option value="21">21. Al-Anbiya</option>
						                    <option value="22">22. Al-Hajj</option>
						                    <option value="23">23. Al-Muminoon</option>
						                    <option value="24">24. An-Noor</option>
						                    <option value="25">25. Al-Furqaan</option>
						                    <option value="26">26. Ash-Shu'araa</option>
						                    <option value="27">27. An-Naml</option>
						                    <option value="28">28. Al-Qasas</option>
						                    <option value="29">29. Al-'Ankaboot</option>
						                    <option value="30">30. Ar-Ruum</option>
						                    <option value="31">31. Luqmaan</option>
						                    <option value="32">32. As-Sajdah</option>
						                    <option value="33">33. Al-Ahzaab</option>
						                    <option value="34">34. Saba</option>
						                    <option value="35">35. Faatir</option>
						                    <option value="36">36. Yaseen</option>
						                    <option value="37">37. As-Saffat</option>
						                    <option value="38">38. Saad</option>
						                    <option value="39">39. Az-Zumar</option>
						                    <option value="40">40. Ghafir</option>
						                    <option value="41">41. Fussilat</option>
						                    <option value="42">42. Ash-Shura</option>
						                    <option value="43">43. Az-Zukhruf</option>
						                    <option value="44">44. Ad-Dukhan</option>
						                    <option value="45">45. Al-Jathiya</option>
						                    <option value="46">46. Al-Ahqaf</option>
						                    <option value="47">47. Muhammad</option>
						                    <option value="48">48. Al-Fath</option>
						                    <option value="49">49. Al-Hujuraat</option>
						                    <option value="50">50. Qaf</option>
						                    <option value="51">51. Adh-Dhariyat</option>
						                    <option value="52">52. At-Tur</option>
						                    <option value="53">53. An-Najm</option>
						                    <option value="54">54. Al-Qamar</option>
						                    <option value="55">55. Ar-Rahman</option>
						                    <option value="56">56. Al-Waqia</option>
						                    <option value="57">57. Al-Hadid</option>
						                    <option value="58">58. Al-Mujadila</option>
						                    <option value="59">59. Al-Hashr</option>
						                    <option value="60">60. Al-Mumtahina</option>
						                    <option value="61">61. As-Saff</option>
						                    <option value="62">62. Al-Jumua</option>
						                    <option value="63">63. Al-Munafiqoon</option>
						                    <option value="64">64. At-Taghabun</option>
						                    <option value="65">65. At-Talaq</option>
						                    <option value="66">66. At-Tahrim</option>
						                    <option value="67">67. Al-Mulk</option>
						                    <option value="68">68. Al-Qalam</option>
						                    <option value="69">69. Al-Haaqqah</option>
						                    <option value="70">70. Al-Ma'arij</option>
						                    <option value="71">71. Nooh</option>
						                    <option value="72">72. Al-Jinn</option>
						                    <option value="73">73. Al-Muzzammil</option>
						                    <option value="74">74. Al-Muddaththir</option>
						                    <option value="75">75. Al-Qiyamah</option>
						                    <option value="76">76. Al-Insaan</option>
						                    <option value="77">77. Al-Mursalat</option>
						                    <option value="78">78. An-Naba</option>
						                    <option value="79">79. An-Naziat</option>
						                    <option value="80">80. Abasa</option>
						                    <option value="81">81. At-Takwir</option>
						                    <option value="82">82. Al-Infitar</option>
						                    <option value="83">83. Al-Mutaffifin</option>
						                    <option value="84">84. Al-Inshiqaaq</option>
						                    <option value="85">85. Al-Burooj</option>
						                    <option value="86">86. At-Tariq</option>
						                    <option value="87">87. Al-A'la</option>
						                    <option value="88">88. Al-Ghashiyah</option>
						                    <option value="89">89. Al-Fajr</option>
						                    <option value="90">90. Al-Balad</option>
						                    <option value="91">91. Ash-Shams</option>
						                    <option value="92">92. Al-Lail</option>
						                    <option value="93">93. Ad-Duha</option>
						                    <option value="94">94. Ash-Sharh</option>
						                    <option value="95">95. At-Tin</option>
						                    <option value="96">96. Al-'Alaq</option>
						                    <option value="97">97. Al-Qadr</option>
						                    <option value="98">98. Al-Bayyinah</option>
						                    <option value="99">99. Az-Zalzalah</option>
						                    <option value="100">100. Al-'Adiyat</option>
						                    <option value="101">101. Al-Qariyah</option>
						                    <option value="102">102. At-Takathur</option>
						                    <option value="103">103. Al-'Asr</option>
						                    <option value="104">104. Al-Humazah</option>
						                    <option value="105">105. Al-Fil</option>
						                    <option value="106">106. Quraysh</option>
						                    <option value="107">107. Al-Maoun</option>
						                    <option value="108">108. Al-Kawthar</option>
						                    <option value="109">109. Al-Kafiroon</option>
						                    <option value="110">110. An-Nasr</option>
						                    <option value="111">111. Al-Masad</option>
						                    <option value="112">112. Al-Ikhlaas</option>
						                    <option value="113">113. Al-Falaq</option>
						                    <option value="114">114. An-Naas</option>
					                    </select>
				                    </span>

				                    <span>
					                    <select id="jsqari-ui-ayah-from-selector" class="small">
						                    <option value="1">1</option>
						                    <option value="2">2</option>
						                    <option value="3">3</option>
						                    <option value="4">4</option>
						                    <option value="5">5</option>
						                    <option value="6">6</option>
						                    <option value="7">7</option>
					                    </select>
				                    </span>

			                    </li>
			                    <li class="single display_none">
			                    To:</li>
			                    <li class="display_none">
				                    <span>
					                    <select id="jsqari-ui-surah-to-selector" class="medium">
						                    <option value="1">1. Al-Faatiha</option>
						                    <option value="2">2. Al-Baqarah</option>
						                    <option value="3">3. Aale 'Imran</option>
						                    <option value="4">4. An-Nisaa</option>
						                    <option value="5">5. Al-Maaidah</option>
						                    <option value="6">6. Al-An'aam</option>
						                    <option value="7">7. Al-A'raaf</option>
						                    <option value="8">8. Al-Anfaal</option>
						                    <option value="9">9. At-Tawbah</option>
						                    <option value="10">10. Younus</option>
						                    <option value="11">11. Huud</option>
						                    <option value="12">12. Yusuf</option>
						                    <option value="13">13. Ar-Ra'ad</option>
						                    <option value="14">14. Ibraheem</option>
						                    <option value="15">15. Al-Hijr</option>
						                    <option value="16">16. An-Nahl</option>
						                    <option value="17">17. Al-Israa</option>
						                    <option value="18">18. Al-Kahf</option>
						                    <option value="19">19. Maryam</option>
						                    <option value="20">20. Taha</option>
						                    <option value="21">21. Al-Anbiya</option>
						                    <option value="22">22. Al-Hajj</option>
						                    <option value="23">23. Al-Muminoon</option>
						                    <option value="24">24. An-Noor</option>
						                    <option value="25">25. Al-Furqaan</option>
						                    <option value="26">26. Ash-Shu'araa</option>
						                    <option value="27">27. An-Naml</option>
						                    <option value="28">28. Al-Qasas</option>
						                    <option value="29">29. Al-'Ankaboot</option>
						                    <option value="30">30. Ar-Ruum</option>
						                    <option value="31">31. Luqmaan</option>
						                    <option value="32">32. As-Sajdah</option>
						                    <option value="33">33. Al-Ahzaab</option>
						                    <option value="34">34. Saba</option>
						                    <option value="35">35. Faatir</option>
						                    <option value="36">36. Yaseen</option>
						                    <option value="37">37. As-Saffat</option>
						                    <option value="38">38. Saad</option>
						                    <option value="39">39. Az-Zumar</option>
						                    <option value="40">40. Ghafir</option>
						                    <option value="41">41. Fussilat</option>
						                    <option value="42">42. Ash-Shura</option>
						                    <option value="43">43. Az-Zukhruf</option>
						                    <option value="44">44. Ad-Dukhan</option>
						                    <option value="45">45. Al-Jathiya</option>
						                    <option value="46">46. Al-Ahqaf</option>
						                    <option value="47">47. Muhammad</option>
						                    <option value="48">48. Al-Fath</option>
						                    <option value="49">49. Al-Hujuraat</option>
						                    <option value="50">50. Qaf</option>
						                    <option value="51">51. Adh-Dhariyat</option>
						                    <option value="52">52. At-Tur</option>
						                    <option value="53">53. An-Najm</option>
						                    <option value="54">54. Al-Qamar</option>
						                    <option value="55">55. Ar-Rahman</option>
						                    <option value="56">56. Al-Waqia</option>
						                    <option value="57">57. Al-Hadid</option>
						                    <option value="58">58. Al-Mujadila</option>
						                    <option value="59">59. Al-Hashr</option>
						                    <option value="60">60. Al-Mumtahina</option>
						                    <option value="61">61. As-Saff</option>
						                    <option value="62">62. Al-Jumua</option>
						                    <option value="63">63. Al-Munafiqoon</option>
						                    <option value="64">64. At-Taghabun</option>
						                    <option value="65">65. At-Talaq</option>
						                    <option value="66">66. At-Tahrim</option>
						                    <option value="67">67. Al-Mulk</option>
						                    <option value="68">68. Al-Qalam</option>
						                    <option value="69">69. Al-Haaqqah</option>
						                    <option value="70">70. Al-Ma'arij</option>
						                    <option value="71">71. Nooh</option>
						                    <option value="72">72. Al-Jinn</option>
						                    <option value="73">73. Al-Muzzammil</option>
						                    <option value="74">74. Al-Muddaththir</option>
						                    <option value="75">75. Al-Qiyamah</option>
						                    <option value="76">76. Al-Insaan</option>
						                    <option value="77">77. Al-Mursalat</option>
						                    <option value="78">78. An-Naba</option>
						                    <option value="79">79. An-Naziat</option>
						                    <option value="80">80. Abasa</option>
						                    <option value="81">81. At-Takwir</option>
						                    <option value="82">82. Al-Infitar</option>
						                    <option value="83">83. Al-Mutaffifin</option>
						                    <option value="84">84. Al-Inshiqaaq</option>
						                    <option value="85">85. Al-Burooj</option>
						                    <option value="86">86. At-Tariq</option>
						                    <option value="87">87. Al-A'la</option>
						                    <option value="88">88. Al-Ghashiyah</option>
						                    <option value="89">89. Al-Fajr</option>
						                    <option value="90">90. Al-Balad</option>
						                    <option value="91">91. Ash-Shams</option>
						                    <option value="92">92. Al-Lail</option>
						                    <option value="93">93. Ad-Duha</option>
						                    <option value="94">94. Ash-Sharh</option>
						                    <option value="95">95. At-Tin</option>
						                    <option value="96">96. Al-'Alaq</option>
						                    <option value="97">97. Al-Qadr</option>
						                    <option value="98">98. Al-Bayyinah</option>
						                    <option value="99">99. Az-Zalzalah</option>
						                    <option value="100">100. Al-'Adiyat</option>
						                    <option value="101">101. Al-Qariyah</option>
						                    <option value="102">102. At-Takathur</option>
						                    <option value="103">103. Al-'Asr</option>
						                    <option value="104">104. Al-Humazah</option>
						                    <option value="105">105. Al-Fil</option>
						                    <option value="106">106. Quraysh</option>
						                    <option value="107">107. Al-Maoun</option>
						                    <option value="108">108. Al-Kawthar</option>
						                    <option value="109">109. Al-Kafiroon</option>
						                    <option value="110">110. An-Nasr</option>
						                    <option value="111">111. Al-Masad</option>
						                    <option value="112">112. Al-Ikhlaas</option>
						                    <option value="113">113. Al-Falaq</option>
						                    <option value="114">114. An-Naas</option>
					                    </select>
				                    </span>

				                    <span>
					                    <select id="jsqari-ui-ayah-to-selector" class="small">
						                    <option value="1">1</option>
						                    <option value="2">2</option>
						                    <option value="3">3</option>
						                    <option value="4">4</option>
						                    <option value="5">5</option>
						                    <option value="6">6</option>
						                    <option value="7">7</option>
					                    </select>
				                    </span>

			                    </li>

			                    <li class="single">
				                    <label for="jsqari-ui-repeat-ayah-selector">Repeat Ayah</label>
				                    <select id="jsqari-ui-repeat-ayah-selector" class="medium">
					                    <option value="1">1</option>
					                    <option value="2">2</option>
					                    <option value="3">3</option>
					                    <option value="5">5</option>
					                    <option value="10">10</option>
				                    </select>
			                    </li>

			                    <li class="single display_none">
				                    <label for="jsqari-ui-repeat-section-selector">Repeat Section</label>
				                    <select id="jsqari-ui-repeat-section-selector" class="medium">
					                    <option value="1">1</option>
					                    <option value="2">2</option>
					                    <option value="3">3</option>
					                    <option value="5">5</option>
					                    <option value="10">10</option>
					                    <option value="Infinite">Infinite</option>
				                    </select>
			                    </li>
			
			                    <li class="single display_none">

				                    <label for="jsqari-ui-reciter-selector">Reciter</label>
				                    <select id="jsqari-ui-reciter-selector" class="medium">
					                    <option value="Alafasy_64kbps/">Al-Afasy</option>
					                    <option value="Ahmed_ibn_Ali_al-Ajamy_64kbps_QuranExplorer.Com/">Al-Ajamy</option>
					                    <option value="Salaah_AbdulRahman_Bukhatir_128kbps/">Bukhatir</option>
					                    <option value="Ghamadi_40kbps/">Ghamadi</option>
					                    <option value="Hudhaify_64kbps/">Hudhaify</option>
					                    <option value="Husary_64kbps/">Husary</option>
					                    <option value="Menshawi_16kbps/">Minshawy</option>
					                    <option value="Maher_AlMuaiqly_64kbps/">Muaiqly</option>
					                    <option value="Abu_Bakr_Ash-Shaatree_64kbps/">Shaatri</option>
					                    <option value="Saood_ash-Shuraym_64kbps/">Shuraym</option>
					                    <option value="Abdurrahmaan_As-Sudais_64kbps/">Sudais</option>
				                    </select>

			                    </li>
			
			                    <li class="single display_none">
				                    <label for="jsqari-ui-current-playing">Current</label>
				                    <output id="jsqari-ui-current-playing">Waiting</output>			

			                    </li>



		                    </ul>
	                    </form>

	                    <div id="jquery_jplayer_1" class="jp-jplayer"></div>

	                    <div class="jp-audio" style="width: 275px">
		                    <div class="jp-type-single">
			                    <div id="jp_interface_1" class="jp-interface">
				                    <ul class="jp-controls">
					                    <li><a href="#" class="jp-play" tabindex="1">play</a></li>
					                    <li><a href="#" class="jp-pause" tabindex="1">pause</a></li>
					                    <li><a href="#" class="jp-stop" tabindex="1">stop</a></li>
					                    <li><a href="#" class="jp-mute" tabindex="1">mute</a></li>
					                    <li><a href="#" class="jp-unmute" tabindex="1">unmute</a></li>
				                    </ul>
				                    <div class="jp-progress">
					                    <div class="jp-seek-bar">
						                    <div class="jp-play-bar"></div>
					                    </div>
				                    </div>
				                    <div class="jp-volume-bar">
					                    <div class="jp-volume-bar-value"></div>
				                    </div>
				                    <div class="jp-current-time"></div>
				                    <div class="jp-duration"></div>
			                    </div>
			                    <!--
			                    <div id="jp_playlist_1" class="jp-playlist">
				                    <ul>
					                    <li>Al-Quran</li>
				                    </ul>
			                    </div>
			                    -->
		                    </div>
	                    </div>
                        
                    </div>
                    <% } %>


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

</body>

    <script src="/scripts/jquery-1.4.3.min.js" type="text/javascript"></script>
    <script defer="defer" src="/scripts/jquery.searchabledropdown-1.0.8.min.js"></script>
    <script type="text/javascript" src="/scripts/jsqari/jquery.jplayer.min.js?v=1"></script>
	<script type="text/javascript" src="/scripts/jsqari/jsqari.js?v=1"></script>

    <% if (EditMode)
       { %>
    <link rel="Stylesheet" type="text/css" href="/jHtmlArea/style/jHtmlArea.css" />
    <script src="/scripts/jquery.htmlClean-min.js"></script>
    <script src="/jHtmlArea/scripts/jHtmlArea-0.7.0.min.js"></script>
    <% } %>

    <script src="/scripts/uframe/htmlparser.js" type="text/javascript"></script>
    <script src="/scripts/uframe/UFrame.js" type="text/javascript"></script>

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
                
                $('<iframe id="iframe_' + nextSurah + '_' + nextAyah + '" src="' + iframeUrl + '" style="width:100%; height:400px; border:none" scrolling="no" frameborder="no" />')
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

                params: { 
                    "surah": surah, 
                    "ayah": ayah, 
                    version: '7', 
                    "cookie": document.cookie 
                }   // parameters to post/get to 
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

        if (!minimal) {
            jQuery(document).ready(function(){

                jsQari = new JSQari();
                jsQari.init();

                jsQari.setFromPosition(surah, ayah);
                jsQari.setPlayMode('surah');
                jsQari.setFromPosition(surah, ayah);

                jsQari.callback = function(s,a)
                {
                    var iframe = $("#iframe_" + s + "_" + a);
                    $('html, body').animate({
                        scrollTop: iframe.offset().top
                    }, 2000);                    

                    iframe.stop().css("opacity", "0.5")
                           .animate({ opacity: "1.0"}, 1000);
                }
            });
        }

    </script>

<!-- YAMLI CODE START -->
<script type="text/javascript" src="http://api.yamli.com/js/yamli_api.js"></script>
<script type="text/javascript">
    if (!minimal) {
        if (typeof(Yamli) == "object" && Yamli.init( { uiLanguage: "en" , startMode: "onOrUserDefault" } ))
        {
            Yamli.yamlify( "search", { settingsPlacement: "bottomLeft" } );
        }
    }
</script>
<!-- YAMLI CODE END -->

<script id="_webengage_script_tag" type="text/javascript">
    if (!minimal) {
        jQuery(document).ready(function() {

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
        });
    }
</script>

</html>
