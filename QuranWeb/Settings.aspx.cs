using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using QuranObjects;

namespace QuranWeb
{
    public partial class Settings : System.Web.UI.Page
    {
        private readonly QuranContext _Quran = new QuranContext();

        protected string GoBackUrl
        {
            get
            {
                var cookie = Request.Cookies["last"];
                var lastVerse = cookie == null ? "1/1" : cookie.Value;

                return lastVerse;
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                var cookie = Request.Cookies["hide"];
                var cookieValue = cookie == null ? string.Empty : cookie.Value;
                var hideTranslations = cookieValue.Split(',');

                TranslationsList.Items.Clear();
                foreach (var translator in _Quran.Translators.OrderBy(t => t.Order))
                {
                    var item = new ListItem(translator.Name, translator.ID.ToString());
                    item.Selected = cookie == null ? translator.ShowDefault : !hideTranslations.Contains(translator.ID.ToString());
                    TranslationsList.Items.Add(item);
                }

                LeftToRightCheckbox.Checked = Request.Cookies["l"] != null && Request.Cookies["l"].Value == "1";
                DisableWordByWord.Checked = Request.Cookies["w"] != null && Request.Cookies["w"].Value == "1";
                ShowInProgressBangla.Checked = Request.Cookies["b"] != null && Request.Cookies["b"].Value == "1";
            }
        }

        protected void Save_Clicked(object sender, EventArgs e)
        {
            var cookieValue = string.Join(",", (from item in TranslationsList.Items.Cast<ListItem>()
                              where !item.Selected
                              select item.Value).ToArray<string>());
            Response.Cookies.Set(new HttpCookie("hide") { Value = cookieValue });

            Response.Cookies.Set(new HttpCookie("l", LeftToRightCheckbox.Checked ? "1" : "0"));
            Response.Cookies.Set(new HttpCookie("w", DisableWordByWord.Checked ? "1" : "0"));
            Response.Cookies.Set(new HttpCookie("b", ShowInProgressBangla.Checked ? "1" : "0"));

            Response.Redirect(GoBackUrl);
        }

        protected override void OnPreRender(EventArgs e)
        {
            base.OnPreRender(e);

            _Quran.Dispose();
        }

        protected void Reset_Click(object sender, EventArgs e)
        {
            foreach (var cookieName in Request.Cookies.AllKeys)
            {
                var cookie = Request.Cookies[cookieName];
                Response.Cookies.Set(new HttpCookie(cookie.Name, string.Empty)
                {
                    Path = cookie.Path,
                    Expires = DateTime.Now.AddDays(-1)
                });
            }

            Response.Redirect("/");
        }
    }
}