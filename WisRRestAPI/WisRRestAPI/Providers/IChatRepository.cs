using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using MongoDB.Driver;
using WisRRestAPI.DomainModel;

namespace WisRRestAPI.Providers
{
    public interface IChatRepository
    {
        Task<List<ChatMessage>> GetAllChatMessages();
        Task<ChatMessage> GetChatMessage(string id);
        string AddChatMessage(ChatMessage item);
        Task<DeleteResult> RemoveChatMessage(string id);
        Task<ChatMessage> UpdateChatMessage(string id, ChatMessage item);
    }
}
