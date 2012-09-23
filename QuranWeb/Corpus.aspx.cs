using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace QuranWeb
{
    public partial class Corpus : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        protected string GenerateHtml()
        {
            try
            {
                var surah = int.Parse(Request["surah"] ?? "1");
                var ayah = int.Parse(Request["ayah"] ?? "1");

                return HTMLParser.GetCorpusHtml(surah, ayah);
            }
            catch (Exception x)
            {
                return x.Message;
            }
        }
    }
}