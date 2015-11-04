using Microsoft.VisualStudio.TestTools.UnitTesting;
using Moq;

namespace WisR.Controllers.Tests
{
    [TestClass]
    public class LoginControllerTests
    {
        [TestMethod]
        public void LoginWithFacebookShouldRedirect()
        {
            //Arrange
            var controller = new LoginController();
            //Mock the context of the controller so that the function can redirect
            controller.SetFakeControllerContext();
            controller.Session["CurrentCulture"] = 1;

            //Act
            controller.LoginWithFacebook();
            //Assert
            controller.getResponseMock().Verify(m => m.Redirect(It.IsAny<string>()), Times.Exactly(1));
        }

        [TestMethod]
        public void LoginCheckShouldRedirectWithoutAccessToken()
        {
            // Arrange
            var controller = new LoginController();
            //Mock the context of the controller so that the function can redirect
            controller.SetFakeControllerContext();

            //Act
            var actionresult = controller.LoginCheck();
            //Assert
            Assert.AreEqual(null, controller.Session["AccessToken"]);
        }
    }
}