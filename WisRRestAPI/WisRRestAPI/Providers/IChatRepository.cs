using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using MongoDB.Driver;
using WisR.DomainModel;
using WisRRestAPI.DomainModel;

namespace WisRRestAPI.Providers
{
    public interface IChatRepository
    {
        Task<List<ChatMessage>> GetAllChatMessages();
        Task<List<ChatMessage>> GetAllChatMessagesByRoomId(string roomId);
        Task<ChatMessage> GetChatMessage(string id);
        void AddChatMessage(ChatMessage item);
        Task<DeleteResult> DeleteChatMessage(string id);
        Task<DeleteResult> DeleteAllChatMessageForRoomWithRoomId(string roomId);
        Task<ChatMessage> UpdateChatMessage(string id, ChatMessage item);
        List<ChatMessage> GetNewerMessages(ChatMessage msg);
    }
}
