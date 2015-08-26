using System;

namespace WisR.DomainModels
{
    public class Coordinate
    {
        public Double Latitude { get; set; }
        public Double Longitude { get; set; }
        public int Acouracy { get; set; }
        public string FormattedAdress { get; set; }
        public string TimeStamp { get; set; }
    }
}