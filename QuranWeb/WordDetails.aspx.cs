using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using QuranObjects;

namespace QuranWeb
{
    public partial class WordDetails : System.Web.UI.Page
    {
    
        protected void Page_Load(object sender, EventArgs e)
        {
            var surah = int.Parse(Request["surah"] ?? "1");
            var ayah = int.Parse(Request["ayah"] ?? "1");
            var word = int.Parse(Request["word"] ?? "1");

            using (QuranContext quran = new QuranContext())
            {
                var meaning = (from m in quran.Meanings
                               where m.SurahNo == surah && m.VerseNo == ayah && m.WordNo == word
                               select new
                               {
                                   Meaning = m,
                                   ArabicWord = m.ArabicWord,
                                   GrammarForm = m.GrammarForm,
                                   Root = m.Root,
                                   OtherMeaningsOfSameArabic = from om in quran.Meanings
                                                               where om.ArabicWordID == m.ArabicWordID
                                                               select om,
                                   OtherMeaningsOfSameRoot = from or in quran.Meanings
                                                             where or.RootID == m.RootID
                                                             group or by or.EnglishMeaning into groupedMeaning
                                                             orderby groupedMeaning.Count() descending
                                                             select new
                                                             {
                                                                 EnglishMeaning = groupedMeaning.Key,
                                                                 Usage = groupedMeaning.Count(),
                                                                 AllMeanings = from am in quran.Meanings
                                                                               where am.RootID == m.RootID && am.EnglishMeaning == groupedMeaning.Key
                                                                               select am    
                                                             }
                               }).First();

                RootArabic.Text = meaning.Root.RootArabic.Replace(" ", "");
                RootEnglish.Text = meaning.Root.RootEnglish;
                RootMeanings.Text = meaning.Root.Meanings;
                if (!Page.IsPostBack)
                    BanglaMeanings.Text = meaning.Root.BanglaMeanings;

                TheWord.Text = meaning.ArabicWord.Arabic;
                OtherMeaningsOfArabic.DataSource = meaning.OtherMeaningsOfSameArabic;
                OtherMeaningsOfArabic.DataBind();

                OtherMeaningsOfRoot.DataSource = meaning.OtherMeaningsOfSameRoot;
                OtherMeaningsOfRoot.DataBind();
                

                var arabicWordsFromRoot = from arabicWords in quran.ArabicWords
                                          where arabicWords.RootID == meaning.Root.ID
                                          select arabicWords;

                var meaningFromRoot = (from rootMeaning in quran.Meanings
                                       where rootMeaning.RootID == meaning.Root.ID
                                       group rootMeaning by new { rootMeaning.GrammarForm.Grammar, rootMeaning.ArabicWordID, rootMeaning.ArabicWord.Arabic, rootMeaning.EnglishMeaning } into groupedMeaning
                                       orderby groupedMeaning.Key.Grammar ascending, groupedMeaning.Count() descending
                                       select new
                                       {                                           
                                           Arabic = groupedMeaning.Key.Arabic,
                                           EnglishMeaning = groupedMeaning.Key.EnglishMeaning,
                                           Grammar = groupedMeaning.Key.Grammar,
                                           Usage = groupedMeaning.Count(),
                                           SameArabicWord = (groupedMeaning.Key.Arabic == meaning.ArabicWord.Arabic),
                                           Verses = from v in quran.Meanings
                                                    where v.ArabicWordID == groupedMeaning.Key.ArabicWordID
                                                    && v.EnglishMeaning == groupedMeaning.Key.EnglishMeaning
                                                    select v
                                       }).ToList();
                MeaningList.DataSource = meaningFromRoot;
                MeaningList.DataBind();

                TotalRootUsage.Text = meaningFromRoot.Sum(m => m.Usage).ToString();

                DictionaryLink.NavigateUrl = string.Format(DictionaryLink.NavigateUrl, meaning.Root.RootArabic.Replace(" ", ""));
            }

        }


        protected void SaveBanglaMeanings_Clicked(object sender, EventArgs e)
        {
            var surah = int.Parse(Request["surah"] ?? "1");
            var ayah = int.Parse(Request["ayah"] ?? "1");
            var word = int.Parse(Request["word"] ?? "1");

            using (QuranContext quran = new QuranContext())
            {
                var meaning = (from m in quran.Meanings
                               where m.SurahNo == surah && m.VerseNo == ayah && m.WordNo == word
                               select m).First();

                var root = (from r in quran.Roots where r.ID == meaning.RootID select r).First();
                root.BanglaMeanings = BanglaMeanings.Text.Trim();
                quran.SaveChanges();
            }
        }
    }
}