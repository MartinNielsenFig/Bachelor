using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Microsoft.AspNet.SignalR;

namespace WisR.Hubs
{
    public class QuestionHub : Hub
    {
        public void Send(string question)
        {
            // Call the broadcastMessage method to update clients.
            var context = GlobalHost.ConnectionManager.GetHubContext<QuestionHub>();
            context.Clients.All.broadcastQuestion(question);
        }
    }
}