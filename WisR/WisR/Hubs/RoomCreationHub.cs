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
    public class RoomCreationHub : Hub
    {
        public void Send(string room)
        {
            // Call the broadcastMessage method to update clients.
            var context = GlobalHost.ConnectionManager.GetHubContext<RoomCreationHub>();
            context.Clients.All.broadcastRoom(room);
        }
    }
}