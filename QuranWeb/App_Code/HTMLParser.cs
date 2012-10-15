using System;
using System.Diagnostics;
using System.IO;
using System.Text.RegularExpressions;
using System.Web.UI;
using System.Web.UI.WebControls;
using HtmlAgilityPack;
using System.Net;
using System.Web;
using System.Text;

namespace QuranWeb
{
    public class HTMLParser
    {
        private const string _VerseUrl = "http://corpus.quran.com/wordbyword.jsp?chapter={0}&verse={1}";
        private const string _SiteHeader = "http://corpus.quran.com";
        private readonly Regex _LocationRegEx = new Regex("location=((.+?))", RegexOptions.Compiled);

        public string GetHTML(string url)
        {
            var request = WebRequest.Create(url);
            var reader = new StreamReader(request.GetResponse().GetResponseStream());
            return reader.ReadToEnd();
        }

        public static string GetCorpusHtml(int surah, int ayah)
        {
            var url = string.Format(_VerseUrl, surah, ayah);
            var document = HttpContext.Current.Cache[url] as HtmlDocument;
            if (document == null)
            {
                var htmlWeb = new HtmlWeb();
                document = htmlWeb.Load(url);
                HttpContext.Current.Cache[url] = document;
            }
            var table = document.DocumentNode.SelectNodes("//table[2]")[1];
            var trs = table.Elements("tr");
            var startProcessing = false;

            StringBuilder buffer = new StringBuilder();
            foreach (var tr in trs)
            {
                if(tr.GetAttributeValue("class", "").Equals("head"))
                {
                    startProcessing = true;
                    continue;
                }
                else if(startProcessing)
                {
                    var tds = tr.SelectNodes("td");
                    var firstCol = tds[0].InnerHtml.Trim();
                    
                    var locationTokens =
                        firstCol.Replace("<span class=\"location\">(", string.Empty).Replace(")</span>", string.Empty).
                            Split(':');

                    if (int.Parse(locationTokens[1]) < ayah)
                        continue;

                    if(int.Parse(locationTokens[1]) > ayah)
                        break;

                    var tokens = firstCol.Split(new[] { "<br>" }, StringSplitOptions.RemoveEmptyEntries);

                    //if(_LocationRegEx.Match())

                    var thirdCol = tds.Count > 2 ? tds[2].InnerHtml.Trim() : string.Empty;

                    var html = "<div class=\"alignleft wordbyword\">"
                        + "<div class=\"meaning\">" + tokens[2] + "</div>" 
                        + "<div class=\"transliteration\">" + tokens[1] + "</div>"                        
                        + tds[1].InnerHtml.Replace("href=\"", "href=\"http://corpus.quran.com")
                        + "<div class=\"grammar\">" + thirdCol + "</div>"                         
                        + "</div>";
                    html = html.Replace("<img src=\"", "<img border=\"0\" src=\"" + _SiteHeader);
                    html = html.Replace("<a href=\"", "<a class=\"iframe\" href=\"" + _SiteHeader);
                    html = html.Replace("/images/verses/", _SiteHeader + "/images/verses/");

                    buffer.Append(html);
                }
                else
                {
                    continue;
                }

                
            }


            return buffer.ToString();
        }
    }
}