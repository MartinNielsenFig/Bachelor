using System.Web;
using System.Web.Optimization;

namespace WisR
{
    public class BundleConfig
    {
        // For more information on bundling, visit http://go.microsoft.com/fwlink/?LinkId=301862
        public static void RegisterBundles(BundleCollection bundles)
        {

            bundles.Add(new ScriptBundle("~/bundles/jquery").Include(
                        "~/Scripts/jquery-{version}.js", 
                        "~/Scripts/WisRScripts/geolocationScripts.js", 
                        "~/Scripts/jquery.signalR-2.2.0.js", 
                        "~/Scripts/angular.js",
                        "~/Scripts/angular-animate.js",
                        "~/Scripts/angular-base64-upload.js",
                        "~/Scripts/WisRScripts/AngularModule.js",
                        "~/Scripts/WisRScripts/AngularConfig.js",
                        "~/Scripts/WisRScripts/AngularDirectivesScripts.js",
                        "~/Scripts/WisRScripts/AngularUserScripts.js",
                        "~/Scripts/WisRScripts/AngularHomeController.js", 
                        "~/Scripts/WisRScripts/AngularFiltersScripts.js", 
                        "~/Scripts/WisRScripts/AngularRoomController.js",
                        "~/Scripts/WisRScripts/Config.js"));
            
            bundles.Add(new ScriptBundle("~/bundles/jqueryval").Include(
                        "~/Scripts/jquery.validate*"));
            bundles.Add(new ScriptBundle("~/bundles/crypto").Include(
                        "~/Scripts/CryptoJS/rollups/sha512.js"));

            var chartBundle = new ScriptBundle("~/bundles/chartbundle").Include(
                "~/Scripts/chart.js", "~/Scripts/angular-chart.js");

            //disable minification of this bundle
            chartBundle.Transforms.Clear();
            bundles.Add(chartBundle);

            // Use the development version of Modernizr to develop with and learn from. Then, when you're
            // ready for production, use the build tool at http://modernizr.com to pick only the tests you need.
            bundles.Add(new ScriptBundle("~/bundles/modernizr").Include(
                        "~/Scripts/modernizr-*"));

            bundles.Add(new ScriptBundle("~/bundles/bootstrap").Include(
                      "~/Scripts/bootstrap.js",
                      "~/Scripts/bootstrap-filestyle.min.js",
                      "~/Scripts/respond.js",
                      "~/Scripts/scrollglue.js",
                      "~/Scripts/d3/d3.min.js",
                      "~/Scripts/d3/d3pie.min.js"));

            bundles.Add(new StyleBundle("~/Content/css").Include(
                      "~/Content/bootstrap.css",
                      "~/Content/site.css",
                      "~/Content/angular-chart.css"));
        }
    }
}
