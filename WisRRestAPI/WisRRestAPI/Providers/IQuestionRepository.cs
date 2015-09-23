using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.AccessControl;
using System.Text;
using System.Threading.Tasks;
using MongoDB.Driver;
using WisR.DomainModels;

namespace WisRRestAPI.DomainModel
{
    public interface IQuestionRepository
    {
        Task<List<Question>> GetAllQuestions();
        Task<Question> GetQuestion(string id);
        Task<Question> GetQuestionWithoutImage(string id);
        Task<List<Question>> GetQuestionsForRoom(string roomId);
        Task<List<Question>> GetQuestionsForRoomWithoutImages(string roomId);
        Task<Question> GetImageByQuestionId(string questionId);
        void AddQuestion(Question item);
        void AddQuestionObject(object item);
        Task<DeleteResult> RemoveQuestion(string id);
        Task<Question> UpdateQuestion(string id, Question item);
        UpdateResult UpdateQuestionResults(string id, Question item);
        UpdateResult UpdateQuestionVotes(string id, Question item);
    }
}
