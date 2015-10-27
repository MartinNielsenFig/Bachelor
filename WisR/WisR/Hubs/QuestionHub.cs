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
        public void Update(string question)
        {
            // Call the broadcastMessage method to update clients.
            var context = GlobalHost.ConnectionManager.GetHubContext<QuestionHub>();
            context.Clients.All.broadcastUpdateQuestion(question);
        }

        public void AddResponse(string question)
        {
            // Call the broadcastMessage method to update clients.
            var context = GlobalHost.ConnectionManager.GetHubContext<QuestionHub>();
            context.Clients.All.broadcastUpdateResult(question);
        }

        public void AddVote(string question)
        {
            // Call the broadcastMessage method to update clients.
            var context = GlobalHost.ConnectionManager.GetHubContext<QuestionHub>();
            context.Clients.All.broadcastUpdateVotes(question);
        }

        public void Delete(string message)
        {
            // Call the broadcastdeletemessage method to delete question.
            var context = GlobalHost.ConnectionManager.GetHubContext<QuestionHub>();
            context.Clients.All.broadcastDeleteQuestion(message);
        }
    }
}