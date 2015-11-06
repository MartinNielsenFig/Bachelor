using Microsoft.VisualStudio.TestTools.UnitTesting;
using Moq;
using WisR.Providers;

namespace WisR.Controllers.Tests
{
    [TestClass]
    public class RoomControllerTests
    {
        [TestMethod]
        public void toJsonChatMessageTest()
        {
            //Arrange
            var rabbitMock = new Mock<IRabbitSubscriber>();
            var controller = new RoomController(rabbitMock.Object);
            var userid = "Test user id";
            var userDisplayname = "Test user displayname";
            var roomId = "Test room id";
            var text = "Test text";


            //Act
            var testChatMsg = controller.toJsonChatMessage(userid,userDisplayname, roomId, text);

            //Assert - this one excludes timestamp since it is time based and will always fail
            Assert.IsTrue(
                testChatMsg.Contains(
                    "{ \"_id\" : null, \"ByUserId\" : \"Test user id\", \"ByUserDisplayName\" : \"Test user displayname\", \"RoomId\" : \"Test room id\", \"Value\" : \"Test text\","));
        }

        [TestMethod]
        public void toJsonQuestionTestWithNullValues()
        {
            //Arrange
            var rabbitMock = new Mock<IRabbitSubscriber>();
            var controller = new RoomController(rabbitMock.Object);
            var createdBy = "Test user";
            var createdByDisplayname = "Test user displayname";
            var roomId = "Test room id";
            var image = "Test image";
            var questionText = "Test question text";
            string responseOptions = null;
            string questionResult = null;
            var CreationTimeStamp = "Test timestamp";
            var ExpireTimeStamp = "Test expire";
            var questionType = "Test Question Type";
            string votes = null;


            //Act
            var testQuestionMsg = controller.toJsonQuestion(createdBy,createdByDisplayname, roomId, image, questionText, responseOptions,
                questionResult, CreationTimeStamp, ExpireTimeStamp, questionType, votes);

            //Assert
            Assert.AreEqual(
                "{ \"_id\" : null, \"RoomId\" : \"Test room id\", \"CreatedById\" : \"Test user\", \"CreatedByUserDisplayName\" : \"Test user displayname\", \"Votes\" : [], \"Img\" : \"Test image\", \"QuestionText\" : \"Test question text\", \"ResponseOptions\" : [], \"Result\" : [], \"CreationTimestamp\" : \"Test timestamp\", \"ExpireTimestamp\" : \"Test expire\" }",
                testQuestionMsg);
        }

        [TestMethod]
        public void toJsonQuestionTestWithResponseOptions()
        {
            //Arrange
            var rabbitMock = new Mock<IRabbitSubscriber>();
            var controller = new RoomController(rabbitMock.Object);
            var createdBy = "Test user";
            var createdByDisplayname = "Test user displayname";
            var roomId = "Test room id";
            var image = "Test image";
            var questionText = "Test question text";
            var responseOptions = "Response a,Response b,Response c";
            string questionResult = null;
            var CreationTimeStamp = "Test timestamp";
            var ExpireTimeStamp = "Test expire";
            var questionType = "Test Question Type";
            string votes = null;


            //Act
            var testQuestionMsg = controller.toJsonQuestion(createdBy, createdByDisplayname, roomId, image, questionText, responseOptions,
                questionResult, CreationTimeStamp, ExpireTimeStamp, questionType, votes);

            //Assert
            Assert.AreEqual(
                "{ \"_id\" : null, \"RoomId\" : \"Test room id\", \"CreatedById\" : \"Test user\", \"CreatedByUserDisplayName\" : \"Test user displayname\", \"Votes\" : [], \"Img\" : \"Test image\", \"QuestionText\" : \"Test question text\", \"ResponseOptions\" : [{ \"Value\" : \"Response a\", \"Weight\" : 0 }, { \"Value\" : \"Response b\", \"Weight\" : 0 }, { \"Value\" : \"Response c\", \"Weight\" : 0 }], \"Result\" : [], \"CreationTimestamp\" : \"Test timestamp\", \"ExpireTimestamp\" : \"Test expire\" }",
                testQuestionMsg);
        }
    }
}