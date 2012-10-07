using QuranObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace QuranWeb
{
    public partial class Search : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            var criteria = Request["query"];
            //if (!criteria.Contains(' '))
            //   criteria = criteria + ' ';
            var arabic = Convert.ToBoolean(Request["arabic"]);
            var translationID = arabic ? 45 : 7;
            var searchTranslationIDs = new int[] { 6, 12, 45, 50, 5 };

            using (var quran = new QuranContext())
            {
                var verse = from a in quran.Ayahs
                            where searchTranslationIDs.Contains(a.TranslatorID) && a.Content.Contains(criteria)
                            group a by new { a.SurahNo, a.AyahNo } into anAyah
                            select new  
                            {
                                SurahNo = anAyah.Key.SurahNo,
                                AyahNo = anAyah.Key.AyahNo,
                                Result = (arabic ? "<big>" : "") + anAyah.FirstOrDefault().Content.Replace(criteria, "<em>" + criteria + "</em>") + (arabic ? "" : " - <small>[" + anAyah.FirstOrDefault().Translator.Name + "]</small>") + (arabic ? "</big>" : ""),
                                Other = (from b in quran.Ayahs
                                           where b.AyahNo == anAyah.Key.AyahNo
                                           && b.SurahNo == anAyah.Key.SurahNo
                                           && b.TranslatorID == translationID
                                         select (arabic ? "" : "<big>") + b.Content + (arabic ? " - <small>[" + b.Translator.Name + "]</small>" : "") + (arabic ? "" : "</big>")).FirstOrDefault()
                            };

                SearchResultGridView.DataSource = verse.Take(50).ToList();
                SearchResultGridView.DataBind();
            }
        }
    }
}