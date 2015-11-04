using Microsoft.VisualStudio.TestTools.UnitTesting;
using Moq;
using WisR.Providers;

namespace WisR.Controllers.Tests
{
    [TestClass]
    public class HomeControllerTests
    {
        [TestMethod]
        public void toJsonRoomReturnsJsonMappedString()
        {
            //Arrange
            var rabbitMock = new Mock<IRabbitSubscriber>();
            var controller = new HomeController(rabbitMock.Object);
            var roomName = "Test Room";
            var CreatedBy = "Test creator";
            var radius = 10;
            var secret = "Test secret";
            var password = "Test password";
            var hasPassword = true;
            var userCanAsk = true;
            var allowAnonymous = true;
            var useLocation = true;
            var locationTimestamp = "10";
            double locationLatitude = 10;
            double locationLongitude = 10;
            var locationAccuracyMeters = 30;
            var locationFormattedAddress = "Aarhus School of engineering";

            //Act
            var myTestRoom = controller.toJsonRoom(roomName, CreatedBy, radius, secret, password, hasPassword,
                userCanAsk, allowAnonymous,
                useLocation, locationTimestamp, locationLatitude, locationLongitude, locationAccuracyMeters,
                locationFormattedAddress);

            //Assert
            Assert.AreEqual(
                "'{ \"_id\" : null, \"Name\" : \"Test Room\", \"CreatedById\" : \"Test creator\", \"Location\" : { \"Latitude\" : 10.0, \"Longitude\" : 10.0, \"AccuracyMeters\" : 30, \"FormattedAddress\" : \"Aarhus School of engineering\", \"Timestamp\" : \"10\" }, \"Radius\" : 10, \"Secret\" : \"Test secret\", \"HasPassword\" : true, \"EncryptedPassword\" : \"Test password\", \"HasChat\" : true, \"UsersCanAsk\" : true, \"AllowAnonymous\" : true, \"UseLocation\" : true }'",
                "'" + myTestRoom + "'");
        }

        [TestMethod]
        public void toJsonUserReturnsJsonMappedString()
        {
            //Arrange
            var rabbitMock = new Mock<IRabbitSubscriber>();
            var controller = new HomeController(rabbitMock.Object);
            var encryptedPassword = "Test password";
            var facebookId = "Facebook test id";
            var LDAPUserName = "LDAP test user name";
            var displayName = "Displayname";
            var email = "Testemail@test.com";
            var connectedRoomIds = "A,B,C,D";
            //Act
            var myTestUser = controller.toJsonUser(encryptedPassword, facebookId, LDAPUserName, displayName, email,
                connectedRoomIds);
            //Assert
            Assert.AreEqual(
                "'{ \"_id\" : null, \"FacebookId\" : \"Facebook test id\", \"ConnectedRoomIds\" : [\"A\", \"B\", \"C\", \"D\"], \"LDAPUserName\" : \"LDAP test user name\", \"DisplayName\" : \"Displayname\", \"Email\" : \"Testemail@test.com\", \"EncryptedPassword\" : \"Test password\" }'",
                "'" + myTestUser + "'");
        }

        [TestMethod]
        public void ChangeCurrentCultureTest()
        {
            //Arrange
            var rabbitMock = new Mock<IRabbitSubscriber>();
            var controller = new HomeController(rabbitMock.Object);
            //Mock the context of the controller so that the function can redirect
            controller.SetFakeControllerContext();

            var cultureid = 1;
            //Act
            var request = controller.ChangeCurrentCulture(cultureid);
            //Assert
            Assert.AreEqual(1, controller.Session["CurrentCulture"]);
        }
    }
}