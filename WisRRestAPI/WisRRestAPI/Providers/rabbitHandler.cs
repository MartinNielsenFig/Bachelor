using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Text;
using System.Web;
using RabbitMQ.Client;

namespace WisRRestAPI.Providers
{
    public class rabbitHandler : IrabbitHandler
    {
        private IConnection _conn;
        private IModel _model;

        public rabbitHandler()
        {
            ConnectionFactory factory = new ConnectionFactory();
            //factory.Protocol = Protocols.FromEnvironment();
            factory.Uri = ConfigurationManager.AppSettings["rabbitMqHost"];
            _conn = factory.CreateConnection();
            _model = _conn.CreateModel();
            _model.QueueDeclare(queue: "Wisr",
                                 durable: false,
                                 exclusive: false,
                                 autoDelete: false,
                                 arguments: null);
        }

        public IConnection getConn()
        {
            return _conn;
        }

        public IModel getModel()
        {
            return _model;
        }

        public void publishString(string routingKey,string stringToPublish)
        {
            var body = Encoding.UTF8.GetBytes(stringToPublish);

            _model.BasicPublish(exchange: "",
                                 routingKey: routingKey,
                                 basicProperties: null,
                                 body: body);
        }
    }
}