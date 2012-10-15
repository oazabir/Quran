using QuranObjects;
using System;
using System.Linq;
using System.Web.UI;

namespace QuranWeb
{
    public partial class TopicAyahs : System.Web.UI.Page
    {
        private readonly QuranContext _Quran = new QuranContext();

        protected void Page_Load(object sender, EventArgs e)
        {
            var topicId = int.Parse(Request["topicId"] ?? "-1");

            if (!IsPostBack)
            {
                LoadPageContent(topicId);
            }
        }

        private void LoadPageContent(int topicId)
        {
            var topic = _Quran.TopicAyahsMaps.FirstOrDefault(t => t.ID == topicId);

            if (topic != null)
            {
                topicName.InnerHtml = "<b>Topic:</b> " + topic.Topic;

                var ayahs = topic.Ayahs.Split(',');
                foreach (var ayah in ayahs)
                {
                    if (!string.IsNullOrEmpty(ayah))
                    {
                        var suras = ayah.Trim('\"').Split(':');
                        if (suras.Length == 2)
                        {
                            LoadTranslations(int.Parse(suras[0]), int.Parse(suras[1]));
                        }
                    }
                }
            }
            else
            {
                topicName.InnerHtml = "<b>Topic:</b> Topic not found";
            }
        }

        /// <summary>
        /// Load arabic & abdel haleem translations
        /// </summary>
        /// <param name="surah"></param>
        /// <param name="ayah"></param>
        private void LoadTranslations(int surahNo, int ayahNo)
        {
            var translations = (from a in _Quran.Ayahs
                                where a.SurahNo == surahNo && a.AyahNo == ayahNo && (a.Translator.Order == 1 || a.Translator.Order == 3)
                                orderby a.Translator.Order
                                select a).ToList().AsQueryable();
            
            string script = "<p class=\"title\"><h3>" + surahNo.ToString() + ":" + ayahNo.ToString() + "</h3></p>";
            foreach (var translation in translations)
            {

                script += string.Format("<div class=\"translator\">{0}</div><p class=\"content\">{1}</p>", 
                    translation.Translator.Name, translation.Content);                
            }

            var control = new LiteralControl(script);
            pnlVerses.Controls.Add(control);
        }
    }
}