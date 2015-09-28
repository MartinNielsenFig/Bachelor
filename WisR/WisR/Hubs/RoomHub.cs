using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Microsoft.AspNet.SignalR;
using MongoDB.Bson;
using MongoDB.Bson.Serialization;
using WisR.DomainModels;

namespace WisR.Hubs
{
    public class RoomHub : Hub
    {
        public void Send(string room)
        {
            // Call the broadcastMessage method to update clients.
            var context = GlobalHost.ConnectionManager.GetHubContext<RoomHub>();
            context.Clients.All.broadcastRoom(room);
        }

        public void Update(string room)
        {
            // Call the broadcastMessage method to update clients.
            var context = GlobalHost.ConnectionManager.GetHubContext<RoomHub>();
            context.Clients.All.broadcastUpdateRoom(room);
        }
    }
}