using System;
using System.Collections.Generic;
using System.Web.Mvc;
using Microsoft.Ajax.Utilities;
using MongoDB.Bson;
using WisR.DomainModels;
using WisR.Providers;
using WisR.DomainModel;
using WisRRestAPI;

namespace WisR.Controllers
{
    /// <summary>
    /// Romm controller is used by the room page for, question and chatmessage json-nification
    /// </summary>
    public class RoomController : BaseController
    {
        private readonly IRabbitSubscriber _rabbitSubscriber;

        public RoomController(IRabbitSubscriber rabbitSubscriber)
        {
            _rabbitSubscriber = rabbitSubscriber;
            _rabbitSubscriber.subscribe("CreateChatMessage");
            _rabbitSubscriber.subscribe("CreateQuestion");
        }

        // GET: Room
        public ActionResult Index(string roomId)
        {
            ViewBag.roomId = roomId;
            return View();
        }

        /// <summary>
        /// To json question convertion.
        /// </summary>
        /// <param name="CreatedBy">Created by.</param>
        /// <param name="CreatedByUserName">Name of the user.</param>
        /// <param name="RoomId">The room identifier.</param>
        /// <param name="Image">The image.</param>
        /// <param name="QuestionText">The question text.</param>
        /// <param name="ResponseOptions">The response options.</param>
        /// <param name="QuestionResult">The question result.</param>
        /// <param name="CreationTimestamp">The creation timestamp.</param>
        /// <param name="ExpireTimestamp">The expire timestamp.</param>
        /// <param name="QuetionsType">Type of the quetions.</param>
        /// <param name="Votes">The votes.</param>
        /// <returns></returns>
        public string toJsonQuestion(string CreatedBy,string CreatedByUserName, string RoomId, string Image, string QuestionText,
            string ResponseOptions, string QuestionResult, string CreationTimestamp, string ExpireTimestamp,
            string QuetionsType, string Votes)
        {
            List<ErrorCodes> errors = new List<ErrorCodes>();
            ErrorTypes errorType = ErrorTypes.Ok;

            var question = new MultipleChoiceQuestion();

            var tempList = new List<ResponseOption>();

            try
            {
                if (!ResponseOptions.IsNullOrWhiteSpace())
                {
                    foreach (var response in ResponseOptions.Split(','))
                    {
                        tempList.Add(new ResponseOption { Value = response });
                    }
                }
                var tempListResult = new List<Answer>();
                if (!QuestionResult.IsNullOrWhiteSpace())
                {
                    foreach (var result in QuestionResult.Split(','))
                    {
                        var tempResult = result.Split('-');
                        tempListResult.Add(new Answer { Value = tempResult[0], UserId = tempResult[1] });
                    }
                }

                var tempListVotes = new List<Vote>();
                if (!Votes.IsNullOrWhiteSpace())
                {
                    foreach (var vote in Votes.Split(','))
                    {
                        var tempVote = vote.Split(':');
                        tempListVotes.Add(new Vote { CreatedById = tempVote[1], Value = Convert.ToInt16(tempVote[0]) });
                    }
                }

                question.CreatedById = CreatedBy;
                question.CreatedByUserDisplayName = CreatedByUserName;
                question.RoomId = RoomId;
                question.Votes = tempListVotes;
                question.Img = Image;
                question.QuestionText = QuestionText;
                question.ResponseOptions = tempList;
                question.CreationTimestamp = CreationTimestamp;
                question.Result = tempListResult;
                question.ExpireTimestamp = ExpireTimestamp;
            }
            catch (Exception)
            {
                errors.Add(ErrorCodes.WrongQuestionFormat);
                return new Notification(null, ErrorTypes.Error, errors).ToJson();
            }


            return new Notification(question.ToJson(),errorType,errors).ToJson();
            ;
        }

        /// <summary>
        /// To json chat message conversion.
        /// </summary>
        /// <param name="userId">The user identifier.</param>
        /// <param name="userDisplayName">Name of the user.</param>
        /// <param name="roomId">The room identifier.</param>
        /// <param name="text">The text.</param>
        /// <returns></returns>
        public string toJsonChatMessage(string userId,string userDisplayName, string roomId, string text)
        {
            List<ErrorCodes> errors = new List<ErrorCodes>();
            ErrorTypes errorType = ErrorTypes.Ok;

            var chatMessage = new ChatMessage();
            try
            {
                chatMessage.ByUserId = userId;
                chatMessage.ByUserDisplayName = userDisplayName;
                chatMessage.RoomId = roomId;
                chatMessage.Value = text;
                chatMessage.Timestamp =
                    (DateTime.UtcNow.Subtract(new DateTime(1970, 1, 1))).TotalMilliseconds.ToString().Replace(",", ".");
            }
            catch (Exception)
            {
                errors.Add(ErrorCodes.WrongMessageFormat);
                return new Notification(null, ErrorTypes.Error, errors).ToJson();
            }
           
            return new Notification(chatMessage.ToJson(), errorType, errors).ToJson();
        }
    }
}