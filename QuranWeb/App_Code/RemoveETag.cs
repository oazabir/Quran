using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace QuranWeb.App_Code
{
    public class RemoveASPNETStuff : IHttpModule
    {
        public void Init(HttpApplication application)
        {
            application.PostReleaseRequestState += new EventHandler(application_PostReleaseRequestState);
        }

        void application_PostReleaseRequestState(object sender, EventArgs e)
        {
            HttpContext.Current.Response.Headers.Remove("Server");
            HttpContext.Current.Response.Headers.Remove("X-AspNet-Version");
            HttpContext.Current.Response.Headers.Remove("ETag");
        }

        public void Dispose()
        {
            
        }
    }
}