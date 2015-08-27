using System;
using System.Collections.Generic;
using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;

namespace WisR.DomainModels
{
    public class Question
    {
        [BsonId]
        public string Id { get; set; }
        public QuestionType QuestionType { get; set; }
        public string QuestionText { get; set; }
        public List<ResponseOption> ResponseOptions { get; set; }
        public string Img { get; set; }
        public List<Answer> Result { get; set; }
        public int UpVotes { get; set; }
        public int DownVotes { get; set; }
        public string CreatedById { get; set; }

        public Question()
        {
            Id = "sdg";
            QuestionType=QuestionType.BrainStorming;
            QuestionText = "Questiontexterino";
            ResponseOptions= new List<ResponseOption>(){ new ResponseOption(),new ResponseOption()};
            Img = "No image";
            Result=new List<Answer>() {new Answer(),new Answer()};
            UpVotes = 10;
            DownVotes = 2;
            CreatedById = "Martins mor";
        }
    }
}