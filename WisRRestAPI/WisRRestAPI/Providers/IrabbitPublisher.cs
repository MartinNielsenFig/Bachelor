using RabbitMQ.Client;
using RabbitMQ.Client.Events;

namespace WisRRestAPI.Providers
{
    public interface IRabbitPublisher
    {
        IConnection getConn();
        IModel getModel();
        void publishString(string routingKey,string value);
    }
}