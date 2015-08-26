using System.Configuration;

namespace WisRRestAPI.DomainModel
{
    public class QuestionRepository
    {
        public QuestionRepository(string connection)
        {
            if (string.IsNullOrWhiteSpace(connection))
            {
                connection = ConfigurationManager.AppSettings["mongoString"];
            }
            
        } 
    }
}