using System.Collections.Generic;
using MongoDB.Bson;

namespace WisR.DomainModels
{
    public abstract class Question
    {
        public abstract string CreatedById { get; set; }
        public abstract int Downvote { get; set; }
        public abstract ObjectId Id { get; set; }
        public abstract string Img { get; set; }
        public abstract string QuestionText { get; set; }
        public abstract List<ResponseOption> ResponseOptions { get; set; }
        public abstract List<Answer> Result { get; set; }
        public abstract int Upvote { get; set; }
    }
}