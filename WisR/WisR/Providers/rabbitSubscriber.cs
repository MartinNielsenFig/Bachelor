using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Text;
using System.Web;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using WisR.Hubs;

namespace WisR.Providers
{
    public class RabbitSubscriber : IRabbitSubscriber
    {
        private IConnection _conn;
        private IModel _model;
        private bool isSubscribed;
        private EventingBasicConsumer _consumer;
        private string _queuename;

        public RabbitSubscriber()
        {
            ConnectionFactory factory = new ConnectionFactory();
            factory.RequestedHeartbeat = 30;
            //factory.Protocol = Protocols.FromEnvironment();
            factory.Uri = ConfigurationManager.AppSettings["rabbitMqHost"];
            _conn = factory.CreateConnection();
            _model = _conn.CreateModel();
            _queuename = "Wisr " + DateTime.Now.Ticks;
            lock (_model)
            {
                _model.QueueDeclare(queue: _queuename,
                                     durable: false,
                                     exclusive: false,
                                     autoDelete: true,
                                     arguments: null);
            }
        }

        public IConnection getConn()
        {
            return _conn;
        }

        public IModel getModel()
        {
            return _model;
        }

        public void publishString(string routingKey, string stringToPublish)
        {
            if (stringToPublish == null) return;
            var body = Encoding.UTF8.GetBytes(stringToPublish);
            lock (_model)
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
                _model.QueueBind(_queuename, "WisrExchange", routingKey);
                _model.BasicConsume(_queuename, false, _consumer);
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
                    var rcHub = new RoomHub();
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
                    var chatHub = new ChatHub();
                    chatHub.Send(message);
                    break;
                case "AddQuestionResponse":
                    var qhub = new QuestionHub();
                    qhub.AddResponse(message);
                    break;
                case "AddQuestionVote":
                    var qhub2 = new QuestionHub();
                    qhub2.AddVote(message);
                    break;
                case "UpdateRoom":
                    var ruHub = new RoomHub();
                    ruHub.Update(message);
                    break;
            }
            lock (_model)
            {
                _model.BasicAck(ea.DeliveryTag, false);
            }


        }
    }
}