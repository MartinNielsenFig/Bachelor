using System.Collections.Generic;
using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;

namespace WisR.DomainModels
{
    [BsonKnownTypes(typeof(MultipleChoiceQuestion), typeof(TextualQuestion))]
    public abstract class Question
    {
        [BsonId]
        public abstract string Id { get; set; }
        public abstract string RoomId { get; set; }
        public abstract string CreatedById { get; set; }
        public abstract List<Vote> Votes { get; set; }
        public abstract string Img { get; set; }
        public abstract string QuestionText { get; set; }
        public abstract List<ResponseOption> ResponseOptions { get; set; }
        public abstract List<Answer> Result { get; set; }
        public abstract string CreationTimestamp { get; set; }
        public abstract string ExpireTimestamp { get; set; }
    }
}