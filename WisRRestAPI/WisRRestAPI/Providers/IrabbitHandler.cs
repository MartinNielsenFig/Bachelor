using RabbitMQ.Client;

namespace WisRRestAPI.Providers
{
    public interface IrabbitHandler
    {
        IConnection getConn();
        IModel getModel();
        void publishString(string routingKey,string value);
    }
}