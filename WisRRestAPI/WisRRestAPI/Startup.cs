using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Web.Mvc;
using Microsoft.Owin;
using Owin;
using RabbitMQ.Client;
using SimpleInjector;
using SimpleInjector.Integration.Web.Mvc;
using WisRRestAPI.DomainModel;
using WisRRestAPI.Providers;

[assembly: OwinStartup(typeof(WisRRestAPI.Startup))]

namespace WisRRestAPI
{
    public partial class Startup
    {
        public void Configuration(IAppBuilder app)
        {
            ConfigureAuth(app);
            var container = new Container();
            container.Register<IdbHandler, dbHandler>(Lifestyle.Singleton);
            container.Register<IRoomRepository, RoomRepository>(Lifestyle.Singleton);
            container.Register<IChatRepository, ChatRepository>(Lifestyle.Singleton);
            container.Register<IQuestionRepository, QuestionRepository>(Lifestyle.Singleton);
            container.Register<IUserRepository, UserRepository>(Lifestyle.Singleton);
            container.Register<IRabbitPublisher, rabbitPublisher>(Lifestyle.Singleton);
            DependencyResolver.SetResolver(new SimpleInjectorDependencyResolver(container));
        }
    }
}
