using System;
using System.Linq;
using System.Web.UI;
using QuranObjects;
using System.Web;
using System.Text.RegularExpressions;

namespace QuranWeb
{
    public partial class Default : System.Web.UI.Page
    {
        private readonly QuranContext _Quran = new QuranContext();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Request["surah"] == null)
            {
                var lastCookie = Request.Cookies["last"];
                if (lastCookie == null)
                    Response.Redirect("1/1");
                else
                    Response.Redirect(lastCookie.Value);
            }

            var surah = int.Parse(Request["surah"] ?? "1");
            var ayah = int.Parse(Request["ayah"] ?? "1");

            if(IsPostBack)
            {
            }
            else
            {
                for(var i = 1; i < 115; ++i)
                {
                    ddlSurahs.Items.Add(i.ToString());
                }

                ddlSurahs.SelectedIndex = surah - 1;
                ddlSurahs.SelectedValue = ddlSurahs.Items[ddlSurahs.SelectedIndex].Value;

                LoadAyahDropdown();

                ddlAyahs.SelectedIndex = ayah - 1;
                ddlAyahs.SelectedValue = ddlAyahs.Items[ddlAyahs.SelectedIndex].Value;
                
                //LoadPageContent(int.Parse(ddlSurahs.SelectedValue), 1);   
            }
        }

        protected override void OnPreRender(EventArgs e)
        {
            base.OnPreRender(e);

            var surah = int.Parse(ddlSurahs.SelectedValue ?? "1");
            var ayah = int.Parse(ddlAyahs.SelectedValue ?? "1");

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

            LoadPageContent(surah, ayah);
            RefreshNavigationState();


            var banglaCookie = Response.Cookies.AllKeys.Contains("bangla") ? Response.Cookies["bangla"] : Request.Cookies.Get("bangla");
            if (banglaCookie != null && banglaCookie.Value == "show")
            {
                pnlMyTranslationView.Visible = true;
                ToggleBangla.Text = "Hide";
            }
            else
            {
                if (banglaCookie != null && string.IsNullOrEmpty(banglaCookie.Value)) 
                    banglaCookie.Value = "hide";

                ToggleBangla.Text = "Show";
                pnlMyTranslationView.Visible = false;
            }

            Response.Cookies.Set(new System.Web.HttpCookie("last", ddlSurahs.SelectedValue + "/" + ddlAyahs.SelectedValue));

            if (Request.QueryString["edit"] == null)
            {
                pnlMyTranslationEdit.Visible = false;                
            }
            else
            {
                pnlMyTranslationEdit.Visible = true;
            }

            _Quran.Dispose();
        }

        protected void ddlSurahs_SelectedIndexChanged(object sender, EventArgs e)
        {
            Response.Redirect("~/" + ddlSurahs.SelectedValue + "/1");
        }

        private void LoadAyahDropdown()
        {
            var surahNo = int.Parse(ddlSurahs.SelectedValue);

            var ayahCount =
                (from a in _Quran.Ayahs where a.SurahNo == surahNo orderby a.AyahNo descending select a).FirstOrDefault().AyahNo;

            ddlAyahs.Items.Clear();

            for (var i = 1; i <= ayahCount; ++i)
            {
                ddlAyahs.Items.Add(i.ToString());
            }
            
            //ddlAyahs.SelectedValue = "1";
            //LoadPageContent(surahNo, 1);               
        }

        private void LoadPageContent(int surah, int ayah)
        {
            var translations = (from a in _Quran.Ayahs 
                              where a.SurahNo == surah && a.AyahNo == ayah 
                              orderby a.Translator.Order 
                              select a).ToList().AsQueryable();

            var cookie = Request.Cookies["hide"];
            var cookieValue = cookie == null ? string.Empty : cookie.Value;
            var hiddenTranslations = cookieValue.Split(',');

            if (cookie == null)
                translations = translations
                    .Where(t => t.Translator.ShowDefault)
                    .OrderBy(t => t.Translator.Order);
            else
                translations = translations.Where(t => !hiddenTranslations.Contains(t.TranslatorID.ToString())).OrderBy(t => t.Translator.Order);

            foreach (var translation in translations)
            {                
                var control = new LiteralControl(string.Format("<div class=\"translator\">{0}</div><p class=\"content\">{1}</p>", 
                    translation.Translator.Name, translation.Content));

                if (translation.Translator.Type == 0)
                    pnlOriginal.Controls.Add(control);
                else if (translation.Translator.Type == 1)
                    pnlAccepted.Controls.Add(control);
                else if (translation.Translator.Type == 2)
                    pnlControversal.Controls.Add(control);
                else if (translation.Translator.Type == 3)
                    pnlNonMuslim.Controls.Add(control);
                else if (translation.Translator.Type == 4)
                    pnlTransliteration.Controls.Add(control);
            }

            //Render related topics
            var selectedVerse = surah.ToString() + ":" + ayah.ToString();
            var topics = (from t in _Quran.TopicAyahsMaps
                          where t.Ayahs.Contains("\"" + selectedVerse + "\"")
                          select t);

            var topicName = string.Empty;
            foreach (var topic in topics)
            {
                topicName += string.Format("<a class=\"topic\" href='#' onclick='topicDetails({1}); return false;'>{0}</a>", topic.Topic.Trim(), topic.ID.ToString()) + ",";
            }

            topicName = !string.IsNullOrEmpty(topicName) ? topicName.Substring(0, topicName.LastIndexOf(',')) : "No relevant topic found";
            pnlRelevantVerses.Controls.Add(new LiteralControl(topicName));

            RefreshNavigationState();
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
                    var lastAyahNo = (from ayah in _Quran.Ayahs
                                      where ayah.SurahNo == currentSurahNo-1
                                      orderby ayah.AyahNo descending
                                      select ayah.AyahNo).First();
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

            // Next ayah link
            if (ddlAyahs.SelectedIndex == ddlAyahs.Items.Count - 1)
            {
                // Last ayah, find the next surah
                if (currentSurahNo < 114)
                {
                    NextAyah.NavigateUrl = (currentSurahNo + 1).ToString() + "/1";
                }
                else
                {
                    NextAyah.Enabled = false;
                }
            }
            else
            {
                NextAyah.NavigateUrl = currentSurahNo.ToString() + "/" + (currentAyahNo + 1).ToString();
            }

            if (Request.QueryString["edit"] != null)
            {
                PrevAyah.NavigateUrl += "?edit=1";
                NextAyah.NavigateUrl += "?edit=1";
            }


            PrevAyah2.Enabled = PrevAyah.Enabled;
            PrevAyah2.NavigateUrl = PrevAyah.NavigateUrl;
            NextAyah2.Enabled = NextAyah.Enabled;
            NextAyah2.NavigateUrl = NextAyah.NavigateUrl;
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

        protected void ToggleBangla_Click(object sender, EventArgs e)
        {
            var cookie = Request.Cookies["bangla"];
            if (cookie == null)
            {
                Response.Cookies.Add(new HttpCookie("bangla", "show")
                {
                    Path = "/"
                });                
            }
            else
            {
                if (cookie.Value == "hide")
                    cookie.Value = "show";
                else
                    cookie.Value = "hide";
                
                Response.Cookies.Set(cookie);
            }
        }


    }
}