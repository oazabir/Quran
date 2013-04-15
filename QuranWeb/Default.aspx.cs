using System;
using System.Linq;
using System.Web.UI;
using QuranObjects;
using System.Web;
using System.Text.RegularExpressions;
using System.Web.UI.WebControls;
using System.Collections.Generic;

namespace QuranWeb
{
    public partial class Default : System.Web.UI.Page
    {
        private QuranContext _Quran; 

        protected int NextSurahNo { get; set; }
        protected int NextAyahNo { get; set; }
        protected string PageTitle { get; set; }

        protected int SurahNo
        {
            get
            {
                return Convert.ToInt32(Request["surah"] ?? "1");
            }
        }

        protected int AyahNo
        {
            get
            {
                return Convert.ToInt32(Request["ayah"] ?? "1");
            }
        }

        protected bool MinimalMode
        {
            get
            {
                return Request["minimal"] != null;
            }
        }

        protected bool EditMode
        {
            get
            {
                return Request["edit"] != null;
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            _Quran = new QuranContext();

            if (Request["surah"] == null)
            {
                var lastCookie = Request.Cookies["last"];
                if (lastCookie == null)
                    Response.Redirect("1/1");
                else
                    Response.Redirect(lastCookie.Value);
            }

            var surah = this.SurahNo;
            var ayah = this.AyahNo;

            if(IsPostBack)
            {
            }
            else
            {
                LoadLanguageDropdown();
                LoadSurahDropdown();

                ddlSurahs.SelectedIndex = surah - 1;
                ddlSurahs.SelectedValue = ddlSurahs.Items[ddlSurahs.SelectedIndex].Value;

                LoadAyahDropdown();

                if (ayah <= ddlAyahs.Items.Count)
                {
                    ddlAyahs.SelectedIndex = ayah - 1;
                    ddlAyahs.SelectedValue = ddlAyahs.Items[ddlAyahs.SelectedIndex].Value;
                }

                CalculateNextSurahAndAyah(surah, ayah);
                
                //LoadPageContent(int.Parse(ddlSurahs.SelectedValue), 1);   
            }
        }

        protected override void OnPreRender(EventArgs e)
        {
            base.OnPreRender(e);

            var surah = int.Parse(ddlSurahs.SelectedValue ?? "1");
            var ayah = int.Parse(ddlAyahs.SelectedValue ?? "1");

            LoadPageContent(surah, ayah);
            RefreshNavigationState();

            ShowMyTranslation(surah, ayah);

            AyahLabel.Text = surah.ToString() + ":" + ayah.ToString();

            WordByWordContainer.Visible = !(Request.Cookies["w"] != null && Request.Cookies["w"].Value == "1");

            Response.Cookies.Set(new System.Web.HttpCookie("last", ddlSurahs.SelectedValue + "/" + ddlAyahs.SelectedValue));

            ShowHideMyTranslationEditor();

            var surahName = GetSurahName(surah);
            this.PageTitle = surahName; // +" " + surah + ":" + ayah;            
        }

        private void ShowHideMyTranslationEditor()
        {
            if (Request.QueryString["edit"] == null)
            {
                pnlMyTranslationEdit.Visible = false;
            }
            else
            {
                pnlMyTranslationEdit.Visible = true;
            }
        }

        private void ShowMyTranslation(int surah, int ayah)
        {
            var showBangla = Request.Cookies["b"] != null && Request.Cookies["b"].Value == "1";
            
            BanglaInProgress.Visible = showBangla;

            if (!showBangla)
                return;

            var existingTranslation = _Quran.MyTranslations.FirstOrDefault(t => t.SurahNo == surah && t.AyahNo == ayah);
            if (existingTranslation != null)
            {
                NewPara.Checked = existingTranslation.NewParaAfterThis;
                Heading.Text = existingTranslation.Heading;
                MyTranslation.Text = existingTranslation.Translation;
                Footnote.Text = existingTranslation.Footnote;

                //lblMyTranslation.Text = existingTranslation.Translation;
                var text = existingTranslation.Translation;
                text = new Regex(@"\*+").Replace(text, (match) =>
                {
                    // Each * is footnote number
                    int footnoteIndex = match.Value.Length;
                    //var footnoteId = "Footnote_" + existingTranslation.SurahNo + "_" + existingTranslation.AyahNo + "_" + footnoteIndex;
                    return "<sup>" + (char)('a' + (char)(footnoteIndex - 1)) + "</sup>";
                });
                lblMyTranslation.Text = text;

                //lblFootnote.Text = existingTranslation.Footnote;
                var matches = new Regex(@"(\*+)([^\*]*)").Matches(existingTranslation.Footnote);
                var footnoteHtml = "";
                foreach (Match match in matches)
                {
                    var footnoteCounter = match.Groups[1].Value.Length;
                    var footnoteText = match.Groups[2].Value;

                    footnoteHtml += "<p class=\"footnote\"><sup>"
                        + (char)('a' + (char)(footnoteCounter - 1)) + "</sup> "
                        + footnoteText + "</p>";
                }
                lblFootnote.Text = footnoteHtml;
            }
            else
            {
                NewPara.Checked = false;
                Heading.Text = string.Empty;
                MyTranslation.Text = string.Empty;
                Footnote.Text = string.Empty;

                lblMyTranslation.Text = string.Empty;
                lblFootnote.Text = string.Empty;
            }

            //var banglaCookie = Response.Cookies.AllKeys.Contains("bangla") ? Response.Cookies["bangla"] : Request.Cookies.Get("bangla");
            if (showBangla)
            {
                pnlMyTranslationView.Visible = true;
                //ToggleBangla.Text = "Hide";
            }
            else
            {
                //ToggleBangla.Text = "Show";
                pnlMyTranslationView.Visible = false;
            }
        }

        protected void ddlSurahs_SelectedIndexChanged(object sender, EventArgs e)
        {
            Response.Redirect("~/" + ddlSurahs.SelectedValue + "/1");
        }
        
        protected void ddlLanguageFilter_SelectedIndexChanged(object sender, EventArgs e)
        {
            var languageId = int.Parse(ddlLanguageFilter.SelectedValue);
            Response.Cookies.Set(new System.Web.HttpCookie("language", ddlLanguageFilter.SelectedValue));
            LoadSurahDropdown();
        }
        
        private void LoadLanguageDropdown()
        {
            ddlLanguageFilter.Items.Clear();

            var cacheKey = "Languages";
            var languages = Cache[cacheKey] as List<Language>;
            if (languages == null)
            {
                languages = _Quran.Languages.OrderBy(t => t.ID).ToList();
                Cache[cacheKey] = languages;
            }

            foreach (var language in languages)
            {
                var item = new ListItem(language.Name, language.ID.ToString());
                // item.Selected = cookie == null ? translator.ShowDefault : !hideTranslations.Contains(translator.ID.ToString());
                ddlLanguageFilter.Items.Add(item);
            }

            var languageIDCookie = Request.Cookies["language"];
            if (languageIDCookie != null)
                ddlLanguageFilter.SelectedValue = languageIDCookie.Value;
            //lblLanguageAll.Visible = ddlLanguageFilter.SelectedValue == "0" ? false : true;
        }

        private string GetSurahName(int surahNo)
        {
            var languageId = int.Parse(ddlLanguageFilter.SelectedValue);
            if (languageId == 0) 
                languageId = 1;

            var surahName = GetSurahNames(languageId).ElementAt(surahNo - 1).Name;

            return surahName;
        }

        private List<V_Surah> GetSurahNames(int languageId)
        {
            var cacheKey = "SurahNames." + languageId;
            var surahNames = Cache[cacheKey] as List<V_Surah>;
            if (surahNames == null)
            {
                surahNames = (from a in _Quran.V_Surahs
                    where a.LanguageID == languageId
                    orderby a.ID
                    select a).ToList();
                Cache[cacheKey] = surahNames;
                return surahNames;
            }
            else
            {
                return surahNames;
            }
            
        }

        private void LoadSurahDropdown()
        {
            int surahNo = ddlSurahs.SelectedIndex;
            ddlSurahs.Items.Clear();

            var languageId = int.Parse(ddlLanguageFilter.SelectedValue);
            ////var languageId = 1;
            ////var languageIDCookie = Request.Cookies["language"];
            ////if (languageIDCookie != null)
            ////    languageId = Convert.ToInt16(languageIDCookie.Value);
            if (languageId == 0) languageId = 1;
            var surahs = GetSurahNames(languageId);

            foreach (var surah in surahs.OrderBy(t => t.ID))
            {
                var item = new ListItem(surah.Name, surah.ID.ToString());
                // item.Selected = cookie == null ? translator.ShowDefault : !hideTranslations.Contains(translator.ID.ToString());
                ddlSurahs.Items.Add(item);
            }

            if (surahNo < 0) surahNo = 0;
            ddlSurahs.SelectedIndex = surahNo;
        }

        private void LoadAyahDropdown()
        {
            var surahNo = int.Parse(ddlSurahs.SelectedValue);

            var ayahCount =
                GetAyahCount(surahNo);

            ddlAyahs.Items.Clear();

            for (var i = 1; i <= ayahCount; ++i)
            {
                ddlAyahs.Items.Add(i.ToString());
            }
            
        }

        private int GetAyahCount(int surahNo)
        {
            var cacheKey = "AyahCount." + surahNo;
            var ayahCount = Cache[cacheKey];
            if (ayahCount == null)
            {
                ayahCount = (from a in _Quran.Ayahs where a.SurahNo == surahNo orderby a.AyahNo descending select a).FirstOrDefault().AyahNo;
                Cache[cacheKey] = ayahCount;
                return (int)ayahCount;
            }
            else
            {
                return (int)ayahCount;
            }
            
        }

        private void LoadPageContent(int surah, int ayah)
        {
            var translations = GetTranslations(surah, ayah).AsQueryable();

            var cookie = Request.Cookies["hide"];
            var cookieValue = cookie == null ? string.Empty : cookie.Value;
            var hiddenTranslations = cookieValue.Split(',');

            if (cookie == null)
                translations = translations
                    .Where(t => t.Translator.ShowDefault)
                    .OrderBy(t => t.Translator.Order);
            else
                translations = translations.Where(t => !hiddenTranslations.Contains(t.TranslatorID.ToString())).OrderBy(t => t.Translator.Order);

            var languageId = int.Parse(ddlLanguageFilter.SelectedValue);
            foreach (var translation in translations)
            {                
                var control = new LiteralControl(string.Format("<div class=\"translator\">{0}</div><p class=\"content\">{1}</p>", 
                    translation.Translator.Name, translation.Content));

                if (translation.Translator.Type == 0)
                    pnlOriginal.Controls.Add(control);
                else if (translation.Translator.Type == 1)
                {
                    if (languageId == 0 || translation.Translator.LanguageID == languageId)
                    {
                        pnlAccepted.Controls.Add(control);
                        pnlAccepted.Visible = true;
                    }
                    else
                    {
                        pnlGenAcceptedAll.Controls.Add(control);
                        pnlGenAcceptedAll.Visible = true;
                    }
                }
                else if (translation.Translator.Type == 2)
                {
                    if (languageId == 0 || translation.Translator.LanguageID == languageId)
                    {
                        pnlControversal.Controls.Add(control);
                        pnlControversal.Visible = true;
                    }
                    else
                    {
                        pnlControversalAll.Controls.Add(control);
                        pnlControversalAll.Visible = true;
                    }
                }

                else if (translation.Translator.Type == 3)
                {
                    if (languageId == 0 || translation.Translator.LanguageID == languageId)
                    {
                        pnlNonMuslim.Controls.Add(control);
                        pnlNonMuslim.Visible = true;
                    }
                    else
                    {
                        pnlNonMuslimAll.Controls.Add(control);
                        pnlNonMuslimAll.Visible = true;
                    }
                }
                else if (translation.Translator.Type == 4)
                {
                    pnlTransliteration.Controls.Add(control);
                }
            }

            //Render related topics
            var selectedVerse = surah.ToString() + ":" + ayah.ToString();

            var cacheKey = "TopicMap." + surah + "." + ayah;
            var topics = Cache[cacheKey] as List<TopicAyahsMap>;
            if (topics == null)
            {
                topics = (from t in _Quran.TopicAyahsMaps
                          where t.Ayahs.Contains("\"" + selectedVerse + "\"")
                          select t).ToList();
                Cache[cacheKey] = topics;
            }
            
            var topicName = string.Empty;
            foreach (var topic in topics)
            {
                topicName += string.Format("<a class=\"topic\" href='#' onclick='topicDetails({1}); return false;'>{0}</a>", topic.Topic.Trim(), topic.ID.ToString()) + ", ";
            }

            topicName = !string.IsNullOrEmpty(topicName) ? topicName.Substring(0, topicName.LastIndexOf(',')) : "No relevant topic found";
            pnlRelevantVerses.Controls.Add(new LiteralControl(topicName));

            RefreshNavigationState();
        }

        private List<Ayah> GetTranslations(int surah, int ayah)
        {
            var cacheKey = "Translations." + surah + "." + ayah;
            var cached = Cache[cacheKey] as List<Ayah>;
            if (cached != null)
                return cached;
            else
            {
                var translations = (from a in _Quran.Ayahs
                        where a.SurahNo == surah && a.AyahNo == ayah
                        orderby a.Translator.Order
                        select a).ToList();
                Cache[cacheKey] = translations;
                return translations;
            }
        }

        protected void ddlAyahs_SelectedIndexChanged(object sender, EventArgs e)
        {
            Response.Redirect("~/" + ddlSurahs.SelectedValue + "/" + ddlAyahs.SelectedValue);
            //LoadPageContent(int.Parse(ddlSurahs.SelectedValue), int.Parse(ddlAyahs.SelectedValue));
        }

        protected void ChangeAyah_Clicked(object sender, EventArgs e)
        {
            Response.Redirect("~/" + ddlSurahs.SelectedValue + "/" + ddlAyahs.SelectedValue);
            //LoadPageContent(int.Parse(ddlSurahs.SelectedValue), int.Parse(ddlAyahs.SelectedValue));
        }

        private void RefreshNavigationState()
        {
            var currentSurahNo = ddlSurahs.SelectedIndex + 1;
            var currentAyahNo = ddlAyahs.SelectedIndex + 1;

            // Prev ayah link
            if (ddlAyahs.SelectedIndex == 0)
            {
                // find the last ayah of the previous surah
                if (ddlSurahs.SelectedIndex > 0)
                {
                    //var lastAyahNo = (from ayah in _Quran.Ayahs
                    //                  where ayah.SurahNo == currentSurahNo-1
                    //                  orderby ayah.AyahNo descending
                    //                  select ayah.AyahNo).First();
                    var lastAyahNo = GetAyahCount(currentSurahNo - 1);
                    PrevAyah.NavigateUrl = (currentSurahNo-1).ToString() + "/" + lastAyahNo.ToString();
                    PrevAyah.Enabled = true;
                }
                else
                    PrevAyah.Enabled = false;
            }
            else
            {
                PrevAyah.NavigateUrl = currentSurahNo.ToString() + "/" + (currentAyahNo - 1).ToString();
            }

            CalculateNextSurahAndAyah(currentSurahNo, currentAyahNo);

            NextAyah.NavigateUrl = NextSurahNo + "/" + NextAyahNo;

            if (Request.QueryString["edit"] != null)
            {
                PrevAyah.NavigateUrl += "?edit=1";
                NextAyah.NavigateUrl += "?edit=1";
            }

            //PrevAyah2.Enabled = PrevAyah.Enabled;
            //PrevAyah2.NavigateUrl = PrevAyah.NavigateUrl;
            //NextAyah2.Enabled = NextAyah.Enabled;
            //NextAyah2.NavigateUrl = NextAyah.NavigateUrl;
        }

        private void CalculateNextSurahAndAyah(int currentSurahNo, int currentAyahNo)
        {
            // Next ayah link
            if (ddlAyahs.SelectedIndex == ddlAyahs.Items.Count - 1)
            {
                // Last ayah, find the next surah
                if (currentSurahNo < 114)
                {
                    NextSurahNo = (currentSurahNo + 1);
                    NextAyahNo = 1;
                }
                else
                {
                    NextAyah.Enabled = false;
                }
            }
            else
            {
                //NextAyah.NavigateUrl = currentSurahNo.ToString() + "/" + (currentAyahNo + 1).ToString();
                NextSurahNo = currentSurahNo;
                NextAyahNo = currentAyahNo + 1;
            }
        }

        protected void Save_Clicked(object sender, EventArgs e)
        {
            var heading = Heading.Text;
            var myTranslation = HttpUtility.HtmlDecode(MyTranslation.Text);
            var footnote = HttpUtility.HtmlDecode(Footnote.Text);
            var newPara = NewPara.Checked;

            var surah = int.Parse(Request["surah"] ?? "1");
            var ayah = int.Parse(Request["ayah"] ?? "1");

            var existingTranslation = _Quran.MyTranslations.FirstOrDefault(t => t.SurahNo == surah && t.AyahNo == ayah);
            if (existingTranslation == null)
            {
                var newTranslation = new MyTranslation
                {
                    AyahNo = ayah,
                    SurahNo = surah,
                    Heading = heading,
                    Translation = myTranslation,
                    Footnote = footnote,
                    NewParaAfterThis = newPara,
                    CreatedDate = DateTime.Now,
                    LastUpdateDate = DateTime.Now
                };

                _Quran.MyTranslations.Add(newTranslation);
                _Quran.SaveChanges();
            }
            else
            {
                existingTranslation.NewParaAfterThis = newPara;
                existingTranslation.SurahNo = surah;
                existingTranslation.AyahNo = ayah;
                existingTranslation.Heading = heading;
                existingTranslation.Translation = myTranslation;
                existingTranslation.Footnote = footnote;
                existingTranslation.LastUpdateDate = DateTime.Now;
                
                _Quran.SaveChanges();
            }
        }

        //protected void ToggleBangla_Click(object sender, EventArgs e)
        //{
        //    var cookie = Request.Cookies["bangla"];
        //    if (cookie == null)
        //    {
        //        Response.Cookies.Add(new HttpCookie("bangla", "show")
        //        {
        //            Path = "/"
        //        });                
        //    }
        //    else
        //    {
        //        if (cookie.Value == "hide")
        //            cookie.Value = "show";
        //        else
        //            cookie.Value = "hide";
                
        //        Response.Cookies.Set(cookie);
        //    }
        //}

        public override void Dispose()
        {
            base.Dispose();
            
            _Quran.Dispose();
        }
    }
}