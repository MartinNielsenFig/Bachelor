using System;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Web;
using System.Web.Mvc;
using System.Web.Routing;
using Moq;

namespace WisR.Controllers.Tests
{

    //Helper class found at: http://www.hanselman.com/blog/ASPNETMVCSessionAtMix08TDDAndMvcMockHelpers.aspx
    //And at: http://stackoverflow.com/questions/524457/how-do-you-mock-the-session-object-collection-using-moq
    public static class MvcMockHelpers
    {
        public static Mock<HttpContextBase> mockContext { get; set; }
        public static Mock<HttpResponseBase> response { get; set; }
        /// <summary>
        /// A Class to allow simulation of SessionObject
        /// </summary>
        public class MockHttpSession : HttpSessionStateBase
        {
            Dictionary<string, object> m_SessionStorage = new Dictionary<string, object>();

            public override object this[string name]
            {
                get
                {
                    try
                    {

                        return m_SessionStorage[name];
                    }
                    catch (Exception e)
                    {
                        return null;
                    }
                }
                set { m_SessionStorage[name] = value; }
            }

            public override void RemoveAll()
            {
            }
        }

        //In the MVCMockHelpers I modified the FakeHttpContext() method as shown below
        public static HttpContextBase FakeHttpContext()
        {
            mockContext = new Mock<HttpContextBase>();
            var request = new Mock<HttpRequestBase>();
            response = new Mock<HttpResponseBase>();
            var session = new MockHttpSession();
            var server = new Mock<HttpServerUtilityBase>();
            request.Setup(m => m.UrlReferrer).Returns(new Uri("http://test.com/"));
            request.Setup(m => m.QueryString).Returns(new Mock<NameValueCollection>().Object);
            mockContext.Setup(ctx => ctx.Request).Returns(request.Object);
            mockContext.Setup(ctx => ctx.Response).Returns(response.Object);
            mockContext.Setup(ctx => ctx.Session).Returns(session);
            mockContext.Setup(ctx => ctx.Server).Returns(server.Object);

            return mockContext.Object;
        }




        public static HttpContextBase FakeHttpContext(string url)
        {
            HttpContextBase context = FakeHttpContext();
            context.Request.SetupRequestUrl(url);
            return context;
        }

        public static Mock<HttpContextBase> getContextMock(this Controller controller)
        {
            return mockContext;
        }
        public static Mock<HttpResponseBase> getResponseMock(this Controller controller)
        {
            return response;
        }
        public static void SetFakeControllerContext(this Controller controller)
        {
            var httpContext = FakeHttpContext();
            ControllerContext context = new ControllerContext(new RequestContext(httpContext, new RouteData()), controller);
            controller.ControllerContext = context;
        }

        static string GetUrlFileName(string url)
        {
            if (url.Contains("?"))
                return url.Substring(0, url.IndexOf("?"));
            else
                return url;
        }

        static NameValueCollection GetQueryStringParameters(string url)
        {
            if (url.Contains("?"))
            {
                NameValueCollection parameters = new NameValueCollection();

                string[] parts = url.Split("?".ToCharArray());
                string[] keys = parts[1].Split("&".ToCharArray());

                foreach (string key in keys)
                {
                    string[] part = key.Split("=".ToCharArray());
                    parameters.Add(part[0], part[1]);
                }

                return parameters;
            }
            else
            {
                return null;
            }
        }

        public static void SetHttpMethodResult(this HttpRequestBase request, string httpMethod)
        {
            Mock.Get(request)
                .Expect(req => req.HttpMethod)
                .Returns(httpMethod);
        }

        public static void SetupRequestUrl(this HttpRequestBase request, string url)
        {
            if (url == null)
                throw new ArgumentNullException("url");

            if (!url.StartsWith("~/"))
                throw new ArgumentException("Sorry, we expect a virtual url starting with \"~/\".");

            var mock = Mock.Get(request);

            mock.Expect(req => req.QueryString)
                .Returns(GetQueryStringParameters(url));
            mock.Expect(req => req.AppRelativeCurrentExecutionFilePath)
                .Returns(GetUrlFileName(url));
            mock.Expect(req => req.PathInfo)
                .Returns(string.Empty);
        }
    }
}