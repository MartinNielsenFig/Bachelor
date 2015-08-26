using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using MongoDB.Driver;
using WisR.DomainModels;

namespace WisRRestAPI.DomainModel
{
    public interface IUserRepository
    {
        Task<List<User>> GetAllUsers();
        Task<User> GetUser(string id);
        void AddUser(User item);
        Task<DeleteResult> RemoveUser(string id);
        Task<User> UpdateUser(string id, User item);
    }
}
