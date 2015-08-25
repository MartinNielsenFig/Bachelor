using System;
using System.Collections.Generic;
using MongoDB.Bson;

namespace WisR.DomainModels
{
    public class Question
    {
        public QuestionType QuestionType { get; set; }
        public string QuestionText { get; set; }
        public List<ResponseOption> ResponseOptions { get; set; }
        public string Img { get; set; }
        public List<Answer> Result { get; set; }
        public int UpVotes { get; set; }
        public int DownVotes { get; set; }
        public ObjectId CreatedBy { get; set; }
    }
}