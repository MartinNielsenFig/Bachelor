using System.Collections.Generic;
using System.Configuration;
using System.Threading.Tasks;
using MongoDB.Bson;
using MongoDB.Driver;
using WisR.DomainModels;

namespace WisRRestAPI.DomainModel
{
    public class QuestionRepository : IQuestionRepository
    {
        private readonly IMongoDatabase _database;

        public QuestionRepository(IdbHandler dbHandler)
        {
            _database = dbHandler.getDb();
        }

        public Task<List<IQuestion>> GetAllQuestions()
        {
            var questions = _database.GetCollection<IQuestion>("question").Find(_ => true).ToListAsync();
            return questions;
        }

        public Task<IQuestion> GetQuestion(string id)
        {
            var question = _database.GetCollection<IQuestion>("question").Find(x => x.Id == ObjectId.Parse(id)).SingleAsync();
            return question;
        }

        public void AddQuestion(IQuestion item)
        {
            _database.GetCollection<IQuestion>("question").InsertOneAsync(item);
        }

        public Task<DeleteResult> RemoveQuestion(string id)
        {
            var task = _database.GetCollection<IQuestion>("question").DeleteOneAsync(x => x.Id == ObjectId.Parse(id));
            return task;

        }

        public Task<IQuestion> UpdateQuestion(string id, IQuestion item)
        {
            var task = _database.GetCollection<IQuestion>("question").FindOneAndReplaceAsync(x => x.Id == ObjectId.Parse(id), item);
            return task;
        }
    }
}