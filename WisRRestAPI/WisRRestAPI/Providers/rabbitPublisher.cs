using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Net.WebSockets;
using System.Text;
using System.Web;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;

namespace WisRRestAPI.Providers
{
    public class rabbitPublisher : IRabbitPublisher
    {
        private IConnection _conn;
        private IModel _model;
        private bool isSubscribed;
        private EventingBasicConsumer _consumer;
        private string _queuename;

        public rabbitPublisher()
        {
            ConnectionFactory factory = new ConnectionFactory();
            factory.RequestedHeartbeat = 30;
            //factory.Protocol = Protocols.FromEnvironment();
            factory.Uri = ConfigurationManager.AppSettings["rabbitMqHost"];
            _conn = factory.CreateConnection();
            _model = _conn.CreateModel();
            _queuename = "WisrRestAPI";
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
    }
}