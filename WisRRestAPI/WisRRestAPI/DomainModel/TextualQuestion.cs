using System.Collections.Generic;
using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;

namespace WisR.DomainModels
{
    public class TextualQuestion : Question
    {
        public override string Id { get; set; }
        public override string RoomId { get; set; }
        public override string CreatedById { get; set; }
        public override int Downvotes { get; set; }
        public override string Img { get; set; }
        public override string QuestionText { get; set; } = "very textual";
        public override List<ResponseOption> ResponseOptions { get; set; }
        public override List<Answer> Result { get; set; }
        public override int Upvotes { get; set; }

        public string SpecificText { get; set; } = "very specific";
    }
}