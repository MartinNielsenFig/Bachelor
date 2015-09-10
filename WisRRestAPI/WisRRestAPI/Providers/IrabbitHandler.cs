using RabbitMQ.Client;
using RabbitMQ.Client.Events;

namespace WisRRestAPI.Providers
{
    public interface IrabbitHandler
    {
        IConnection getConn();
        IModel getModel();
        void publishString(string routingKey,string value);
        void subscribe(string routingKey);
        void handle(object messageModel, BasicDeliverEventArgs ea);
    }
}