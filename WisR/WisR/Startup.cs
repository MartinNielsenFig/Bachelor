using System.Web.Mvc;
using Microsoft.Owin;
using Owin;
using SimpleInjector;
using SimpleInjector.Integration.Web.Mvc;
using WisR.Providers;


[assembly: OwinStartupAttribute(typeof(WisR.Startup))]
namespace WisR
{
    public partial class Startup
    {
        public void Configuration(IAppBuilder app)
        {
            ConfigureAuth(app);
            app.MapSignalR();
            var container = new Container();
            container.Register<IRabbitSubscriber, RabbitSubscriber>(Lifestyle.Singleton);
            DependencyResolver.SetResolver(new SimpleInjectorDependencyResolver(container));
        }
    }
}
