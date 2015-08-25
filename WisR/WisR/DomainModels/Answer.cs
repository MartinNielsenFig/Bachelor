using MongoDB.Bson;

namespace WisR.DomainModels
{
    public class Answer
    {
        public string Value { get; set; }
        ObjectId User { get; set; }
    }
}