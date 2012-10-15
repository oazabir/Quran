using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Xml.Linq;
using System.Xml;
using System.Text;

namespace QuranWeb
{
    /// <summary>
    /// Summary description for Rss
    /// </summary>
    public class Rss : IHttpHandler
    {

        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "application/rss+xml";
            XNamespace media = "http://search.yahoo.com/mrss";

            using (var quran = new QuranObjects.QuranContext())
            {
                var translations = (from translation in quran.MyTranslations
                                    orderby translation.LastUpdateDate descending
                                    select translation).Take(25).ToList();

                XDocument rss = new XDocument(
                    new XElement("rss", new XAttribute("version", "2.0"),
                        new XElement("channel",
                            new XElement("title", "Quran Modern Bangla Translation Updates"),
                            new XElement("link", "http://quran.omaralzabir.com"),
                            new XElement("description", ""),
                            new XElement("language", ""),
                            new XElement("pubDate", DateTime.Now.ToString("r")),
                            new XElement("generator", "XLinq"),

                            from mytranslation in translations
                            select new XElement("item",
                                       new XElement("title", (mytranslation.CreatedDate == mytranslation.LastUpdateDate ? "Add: " : "Update: ") + mytranslation.SurahNo + ":" + mytranslation.AyahNo),
                                       new XElement("link", "http://quran.omaralzabir.com/" + mytranslation.SurahNo + "/" + mytranslation.AyahNo,
                                           new XAttribute("rel", "alternate"),
                                           new XAttribute("type", "text/html"),
                                           new XAttribute("href", "http://quran.omaralzabir.com/" + mytranslation.SurahNo + "/" + mytranslation.AyahNo)),
                                       new XElement("id", mytranslation.ID.ToString() + mytranslation.LastUpdateDate.Ticks.ToString()),
                                       new XElement("pubDate", mytranslation.LastUpdateDate.ToLongDateString()),
                                       new XElement("description",
                                           new XCData(
                                               string.Format("<h2>{0}</h2><p style=\"font-size: 16pt\">{1}</p><p style=\"font-size: 14pt\">{2}</p><p><hr /></p>", mytranslation.Heading, mytranslation.Translation, mytranslation.Footnote) +
                                               string.Join("", 
                                                   (from translation in quran.Ayahs
                                                    where translation.SurahNo == mytranslation.SurahNo && 
                                                    translation.AyahNo == mytranslation.AyahNo && translation.Translator.ShowDefault == true
                                                    orderby translation.Translator.Order
                                                    select ("<p style=\"margin:0; padding:0; font: italic 16px/18px georgia;color: #6798BF;display: block;font-size: 10pt;line-height: 18px;margin-left: 10px;\">" + translation.Translator.Name + "</p>" +
                                                    "<p style=\"margin:0; padding:0; font-size: 14pt;font-family: Georgia;text-align: left;line-height: 24px;margin-left: 10px;\">" + translation.Content + "</p>")))
                                           )
                                       ),
                                       new XElement("author", "Omar AL Zabir")
                                  )
                             )
                        )
                    );
                using (XmlWriter writer = new XmlTextWriter(context.Response.OutputStream, Encoding.UTF8))
                {
                    rss.WriteTo(writer);                    
                }
            }
        }

        public bool IsReusable
        {
            get
            {
                return false;
            }
        }
    }
}