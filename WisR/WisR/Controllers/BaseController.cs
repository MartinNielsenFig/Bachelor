using System.Configuration;
using System.Web.Mvc;
using WisR.Helper;

namespace WisR.Controllers
{
    /// <summary>
    /// Used to check if a session has choosen a language, else it take browsers standard
    /// </summary>
    public class BaseController : Controller
    {
        protected override bool DisableAsyncSupport
        {
            get { return true; }
        }

        protected override void ExecuteCore()
        {
            var culture = 0;
            if (Session == null || Session["CurrentCulture"] == null)
            {
                int.TryParse(ConfigurationManager.AppSettings["Culture"], out culture);
                Session["CurrentCulture"] = culture;
            }
            else
            {
                culture = (int) Session["CurrentCulture"];
            }
            // calling CultureHelper class properties for setting  
            CultureHelper.CurrentCulture = culture;

            base.ExecuteCore();
        }
    }
}