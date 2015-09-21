﻿using System;
using System.Collections.Generic;
using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;

namespace WisR.DomainModels
{
    public class MultipleChoiceQuestion : Question
    {
        public override string Id { get; set; }
        public override string RoomId { get; set; }
        public override string CreatedById { get; set; }
        public override List<Vote> Votes { get; set; }
        public override string Img { get; set; }
        public override string QuestionText { get; set; } = "much bool";
        public override List<ResponseOption> ResponseOptions { get; set; }
        public override List<Answer> Result { get; set; }
        public override string CreationTimestamp { get; set; }
        public override string ExpireTimestamp { get; set; }
    }
}