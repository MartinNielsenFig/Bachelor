using RabbitMQ.Client;
using RabbitMQ.Client.Events;

namespace WisR.Providers
{
    public interface IRabbitSubscriber
    {
        IConnection getConn();
        IModel getModel();
        void handle(object messageModel, BasicDeliverEventArgs ea);
        void publishString(string routingKey, string stringToPublish);
        void subscribe(string routingKey);
    }
}