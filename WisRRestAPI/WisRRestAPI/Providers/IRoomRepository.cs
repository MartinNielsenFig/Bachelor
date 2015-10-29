using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using MongoDB.Driver;
using WisR.DomainModels;

namespace WisRRestAPI.DomainModel
{
    public interface IRoomRepository
    {
        Task<List<Room>> GetAllRooms();
        Task<Room> GetRoom(string id);
        Task<Room> GetRoomBySecret(string secret);
        string AddRoom(Room item);
        Task<DeleteResult> DeleteRoom(string id);
        Task<Room> UpdateRoom(string id, Room item);
        bool DoesRoomExist(string id);
    }
}
