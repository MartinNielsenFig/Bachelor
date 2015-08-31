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
        Task<List<IQuestion>> GetAllQuestions();
        Task<IQuestion> GetQuestion(string id);
        void AddQuestion(IQuestion item);
        void AddQuestionObject(object item);
        Task<DeleteResult> RemoveQuestion(string id);
        Task<IQuestion> UpdateQuestion(string id, IQuestion item);
    }
}
