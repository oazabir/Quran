using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.Adapters;

namespace QuranWeb
{
    public class FormRewriterControlAdapter : ControlAdapter
    {
        protected override void Render(System.Web.UI.HtmlTextWriter writer)
        {
            base.Render(new RewriteFormHtmlTextWriter(writer));
        }
    }

    class RewriteFormHtmlTextWriter : HtmlTextWriter
    {
        public RewriteFormHtmlTextWriter(HtmlTextWriter writer) : base(writer)
        {
            this.InnerWriter = writer.InnerWriter;
        }

        public RewriteFormHtmlTextWriter(System.IO.TextWriter writer)
            : base(writer)
        {
            this.InnerWriter = writer;
        }

        public override void WriteAttribute(string name, string value, bool encode)
        {
            if (name == "action")
            {
                var context = HttpContext.Current;

                if (context.Items["ActionAlreadyWritten"] == null)
                {
                    value = context.Request.RawUrl;
                    context.Items["ActionAlreadyWritten"] = true;
                }
            }

            base.WriteAttribute(name, value, encode);
        }
       
    }
}