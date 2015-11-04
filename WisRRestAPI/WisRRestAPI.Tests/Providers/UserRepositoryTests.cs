using Microsoft.VisualStudio.TestTools.UnitTesting;
using WisRRestAPI.DomainModel;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WisRRestAPI.DomainModel.Tests
{
    [TestClass()]
    public class UserRepositoryTests
    {
        [TestMethod()]
        public void getUsersByRoomIdTest()
        {
            //Arrange
            var _ur = new UserRepository(new dbHandler());
           
            
            //Act
             var result = _ur.getUsersByRoomId("5628e38cc7f5627fe84fbc45");
            //Assert
            Assert.AreNotEqual("[]",result);
        }
    }
}