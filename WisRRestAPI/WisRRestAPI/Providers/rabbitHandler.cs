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
        private List<string> routingKeyList; 

        public rabbitHandler()
        {
            ConnectionFactory factory = new ConnectionFactory();
            factory.RequestedHeartbeat = 30;
            //factory.Protocol = Protocols.FromEnvironment();
            factory.Uri = ConfigurationManager.AppSettings["rabbitMqHost"];
            _conn = factory.CreateConnection();
            _model = _conn.CreateModel();
            lock (_model)
            {
                _model.QueueDeclare(queue: "Wisr",
                                     durable: true,
                                     exclusive: false,
                                     autoDelete: false,
                                     arguments: null);
            }
            
            routingKeyList = new List<string>();
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
            lock(_model)
            {
                _model.BasicPublish(exchange: "WisrExchange",
                                 routingKey: routingKey,
                                 basicProperties: null,
                                 body: body);
            }
            
        }

        public void subscribe(string routingKey)
        {
            if (isSubscribed)
                return;
            lock (_model)
            {
                _consumer = new EventingBasicConsumer(_model);
                _consumer.Received += handle;
                _model.QueueBind("Wisr", "WisrExchange", routingKey);
                _model.BasicConsume("Wisr", false, _consumer);
            }
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
                    var questionHub = new QuestionHub();
                    questionHub.Send(message);
                    break;
                case "UpdateQuestion":
                    var updateQuestionHub = new QuestionHub();
                    updateQuestionHub.Update(message);
                    break;
                case "CreateChatMessage":
                    var chatHub=new ChatHub();
                    chatHub.Send(message);
                    break;
                
            }
            lock (_model)
            {
                _model.BasicAck(ea.DeliveryTag, false);
            }
            

        }
    }
}