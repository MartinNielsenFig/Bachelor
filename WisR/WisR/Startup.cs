using Microsoft.Owin;
using Owin;

[assembly: OwinStartupAttribute(typeof(WisR.Startup))]
namespace WisR
{
    public partial class Startup
    {
        public void Configuration(IAppBuilder app)
        {
            ConfigureAuth(app);
        }
    }
}
