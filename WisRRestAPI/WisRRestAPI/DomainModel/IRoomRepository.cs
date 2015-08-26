using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using MongoDB.Driver;
using WisR.DomainModels;

namespace WisRRestAPI.DomainModel
{
    interface IRoomRepository
    {
        Task<List<Room>> GetAllRooms();
        Task<Room> GetRoom(string id);
        void AddRoom(Room item);
        Task<DeleteResult> RemoveRoom(string id);
        Task<Room> UpdateRoom(string id, Room item);
    }
}
