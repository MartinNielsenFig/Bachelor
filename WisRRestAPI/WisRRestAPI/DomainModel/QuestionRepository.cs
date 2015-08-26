using System.Collections.Generic;
using System.Configuration;
using System.Threading.Tasks;
using MongoDB.Driver;
using WisR.DomainModels;

namespace WisRRestAPI.DomainModel
{
    public class QuestionRepository:IQuestionRepository
    {
        private readonly IMongoDatabase _database;

        public QuestionRepository(string connection)
        {
            if (string.IsNullOrWhiteSpace(connection))
            {
                connection = ConfigurationManager.AppSettings["mongoString"];
            }

            var client = new MongoClient(connection);
            _database = client.GetDatabase("bachelor");
        }

        public Task<List<Question>> GetAllQuestions()
        {
            var questions = _database.GetCollection<Question>("question").Find(_=>true).ToListAsync();
            return questions;
        }

        public Task<Question> GetQuestion(string id)
        {
            var question = _database.GetCollection<Question>("question").Find(x => x.Id==id).SingleAsync();
            return question;
        }

        public void AddQuestion(Question item)
        {
            _database.GetCollection<Question>("question").InsertOneAsync(item);
        }

        public Task<DeleteResult> RemoveQuestion(string id)
        {
            var task=_database.GetCollection<Question>("question").DeleteOneAsync(x => x.Id == id);
            return task;

        }

        public Task<Question> UpdateQuestion(string id, Question item)
        {
            var task = _database.GetCollection<Question>("question").FindOneAndReplaceAsync(x=>x.Id==id,item);
            return task;
        }
    }
}