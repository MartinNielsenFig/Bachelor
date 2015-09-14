using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Microsoft.AspNet.SignalR;

namespace WisR.Hubs
{
    public class ChatHub : Hub
    {
        public void Send(string chatMessage)
        {
            // Call the broadcastMessage method to update clients.
            var context = GlobalHost.ConnectionManager.GetHubContext<ChatHub>();
            context.Clients.All.broadcastChatMessage(chatMessage);
        }
    }
}