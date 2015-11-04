using Microsoft.VisualStudio.TestTools.UnitTesting;
using WisR.Controllers;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Moq;
using WisR.Providers;

namespace WisR.Controllers.Tests
{
    [TestClass()]
    public class HomeControllerTests
    {
        [TestMethod()]
        public void toJsonRoomReturnsJsonMappedString()
        {
            //Arrange
            Mock<IRabbitSubscriber> rabbitMock = new Mock<IRabbitSubscriber>();
            var controller = new HomeController(rabbitMock.Object);
            string roomName = "Test Room";
            string CreatedBy = "Test creator";
            int radius = 10;
            string secret = "Test secret";
            string password = "Test password";
            bool hasPassword = true;
            bool userCanAsk = true;
            bool allowAnonymous = true;
            bool useLocation = true;
            string locationTimestamp = "10";
            double locationLatitude = 10;
            double locationLongitude = 10;
            int locationAccuracyMeters = 30;
            string locationFormattedAddress = "Aarhus School of engineering";

            //Act
            var myTestRoom = controller.toJsonRoom(roomName, CreatedBy, radius, secret, password, hasPassword, userCanAsk, allowAnonymous,
                useLocation, locationTimestamp, locationLatitude, locationLongitude, locationAccuracyMeters,
                locationFormattedAddress);

            //Assert
            Assert.AreEqual("'{ \"_id\" : null, \"Name\" : \"Test Room\", \"CreatedById\" : \"Test creator\", \"Location\" : { \"Latitude\" : 10.0, \"Longitude\" : 10.0, \"AccuracyMeters\" : 30, \"FormattedAddress\" : \"Aarhus School of engineering\", \"Timestamp\" : \"10\" }, \"Radius\" : 10, \"Secret\" : \"Test secret\", \"HasPassword\" : true, \"EncryptedPassword\" : \"Test password\", \"HasChat\" : true, \"UsersCanAsk\" : true, \"AllowAnonymous\" : true, \"UseLocation\" : true }'", "'" + myTestRoom + "'");
        }

        [TestMethod()]
        public void toJsonUserReturnsJsonMappedString()
        {
            //Arrange
            Mock<IRabbitSubscriber> rabbitMock = new Mock<IRabbitSubscriber>();
            var controller = new HomeController(rabbitMock.Object);
            string encryptedPassword = "Test password";
            string facebookId = "Facebook test id";
            string LDAPUserName = "LDAP test user name";
            string displayName = "Displayname";
            string email = "Testemail@test.com";
            string connectedRoomIds = "A,B,C,D";
            //Act
            var myTestUser = controller.toJsonUser(encryptedPassword, facebookId, LDAPUserName, displayName, email,
                connectedRoomIds);
            //Assert
            Assert.AreEqual("'{ \"_id\" : null, \"FacebookId\" : \"Facebook test id\", \"ConnectedRoomIds\" : [\"A\", \"B\", \"C\", \"D\"], \"LDAPUserName\" : \"LDAP test user name\", \"DisplayName\" : \"Displayname\", \"Email\" : \"Testemail@test.com\", \"EncryptedPassword\" : \"Test password\" }'", "'"+myTestUser+"'");
        }
    }
}