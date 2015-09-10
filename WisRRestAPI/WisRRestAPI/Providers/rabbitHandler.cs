using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Net.WebSockets;
using System.Text;
using System.Web;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using WisR.Hubs;

namespace WisRRestAPI.Providers
{
    public class rabbitHandler : IrabbitHandler
    {
        private IConnection _conn;
        private IModel _model;
        private bool isSubscribed;
        private EventingBasicConsumer _consumer;

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
            if (stringToPublish == null) return;
            var body = Encoding.UTF8.GetBytes(stringToPublish);

            _model.BasicPublish(exchange: "exchangeFromVisualStudio",
                                 routingKey: routingKey,
                                 basicProperties: null,
                                 body: body);
        }

        public void subscribe(string routingKey)
        {
            if (isSubscribed)
                return;
            _consumer =new EventingBasicConsumer(_model);
            _consumer.Received += handle;
            _model.BasicConsume("Wisr", true, _consumer);
            isSubscribed = true;
        }

        public void handle(object messageModel, BasicDeliverEventArgs ea)
        {
            var body = ea.Body;
            var message = Encoding.UTF8.GetString(body);

            switch (ea.RoutingKey)
            {
                case "CreateRoom":
                    var rcHub=new RoomCreationHub();
                    rcHub.Send(message);
                    break;
                case "CreateQuestion":
                    break;
                case "CreateChatMessage":
                    break;
            }

        }
    }
}