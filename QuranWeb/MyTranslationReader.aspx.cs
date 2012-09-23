using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Text.RegularExpressions;

namespace QuranWeb
{
    public partial class MyTranslationReader : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            var surah = int.Parse(Request["surah"] ?? "1");

            using (var quran = new QuranObjects.QuranContext())
            {
                var translations = from mt in quran.MyTranslations where mt.SurahNo == surah select mt;

                foreach (var translation in translations)
                {
                    if (translation.Heading.Length > 0)
                    {
                        pnlTranslations.Controls.Add(new LiteralControl("<p class=\"heading\">" + translation.Heading + "</p>"));
                    }

                    var text = translation.Translation;
                    text = new Regex(@"\*+").Replace(text, (match) =>
                        {
                            // Each * is footnote number
                            int footnoteIndex = match.Value.Length;
                            var footnoteId = "Footnote_" + translation.SurahNo + "_" + translation.AyahNo + "_" + footnoteIndex;
                            return "<sup><a class=\"footnote_link\" onclick=\"showFootnote('" + footnoteId + "')\" href=\"#" + footnoteId + "\">" + (char)('a' + (char)(footnoteIndex - 1)) + "</a></sup> ";
                        });

                    // Generate the verse number
                    var translationAyahNoEnglish = translation.AyahNo.ToString();
                    var banglaVerseNo = new String(Array.ConvertAll(translationAyahNoEnglish.ToCharArray(), (c) => (char)('০' + (char)(c - '0'))));

                    pnlTranslations.Controls.Add(new LiteralControl("<p class=\"translation\"> " +
                        "<sup><a href=\"" + translation.SurahNo + "/" + translation.AyahNo + "\">" + banglaVerseNo + "</a></sup> " +
                        text + "</p>"));

                    var matches = new Regex(@"(\*+)([^\*]*)").Matches(translation.Footnote);
                    foreach (Match match in matches)
                    {
                        var footnoteCounter = match.Groups[1].Value.Length;
                        var footnoteText = match.Groups[2].Value;

                        pnlFootnotes.Controls.Add(new LiteralControl("<p class=\"footnote\" id=\"" + "Footnote_" + translation.SurahNo + "_" + translation.AyahNo + "_" + footnoteCounter + "\">"
                            + translation.AyahNo + (char)('a' + (char)(footnoteCounter - 1)) + ": "
                            + footnoteText + "</p>"));
                    }


                    if (translation.NewParaAfterThis)
                        pnlTranslations.Controls.Add(new LiteralControl("<p />"));
                }
            }
        }
    }
}