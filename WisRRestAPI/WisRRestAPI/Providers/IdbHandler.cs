using MongoDB.Driver;

namespace WisRRestAPI.DomainModel
{
    public interface IdbHandler
    {
        IMongoDatabase getDb();
    }
}