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

        public Task<List<Question>> GetAllQuestions()
        {
            var questions = _database.GetCollection<Question>("question").Find(_ => true).ToListAsync();
            return questions;
        }

        public Task<Question> GetQuestion(string id)
        {
            var question = _database.GetCollection<Question>("question").Find(x => x.Id ==id).SingleAsync();
            return question;
        }

        public Task<Question> GetQuestionWithoutImage(string id)
        {
            var question = _database.GetCollection<Question>("question").Find(x => x.Id == id).Project<Question>(Builders<Question>.Projection.Exclude(doc => doc.Img)).SingleAsync();
            return question;
        }

        public Task<List<Question>> GetQuestionsForRoom(string roomId) {
            var qList = _database.GetCollection<Question>("question").Find(x => x.RoomId == roomId).ToListAsync();
            return qList;
        }

        public Task<List<Question>> GetQuestionsForRoomWithoutImages(string roomId)
        {
            var qList = _database.GetCollection<Question>("question").Find(x => x.RoomId == roomId).Project<Question>(Builders<Question>.Projection.Exclude(doc => doc.Img)).ToListAsync();
            return qList;
        }

        public Task<Question> GetImageByQuestionId(string questionId)
        {
            var qList = _database.GetCollection<Question>("question").Find(x => x.Id== questionId).Project<Question>(Builders<Question>.Projection.Include("_t").Include("Img")).SingleAsync();
            return qList;
        }

        public void AddQuestionObject(object item)
        {
            _database.GetCollection<object>("question").InsertOneAsync(item);

        }

        public void AddQuestion(Question item)
        {
            _database.GetCollection<Question>("question").InsertOneAsync(item);
        }

        public Task<DeleteResult> DeleteQuestion(string id)
        {
            var task = _database.GetCollection<Question>("question").DeleteOneAsync(x => x.Id == id);
            return task;

        }

        public Task<Question> UpdateQuestion(string id, Question item)
        {
            var task = _database.GetCollection<Question>("question").FindOneAndReplaceAsync(x => x.Id == id, item);
            return task;
        }

        public UpdateResult UpdateQuestionResults(string id, Question item)
        {
            var collection = _database.GetCollection<BsonDocument>("question");
            var filter = Builders<BsonDocument>.Filter.Eq("_id", id);
            var update = Builders<BsonDocument>.Update
                .Set("Result", item.Result);
            return collection.UpdateOneAsync(filter, update).Result;
        }

        public UpdateResult UpdateQuestionVotes(string id, Question item)
        {
            var collection = _database.GetCollection<BsonDocument>("question");
            var filter = Builders<BsonDocument>.Filter.Eq("_id", id);
            var update = Builders<BsonDocument>.Update
                .Set("Votes", item.Votes);
            return collection.UpdateOneAsync(filter, update).Result;
        }
    }
}