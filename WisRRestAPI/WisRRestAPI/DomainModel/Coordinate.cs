using System;

namespace WisR.DomainModels
{
    public class Coordinate
    {
        public Double? Latitude { get; set; }
        public Double? Longitude { get; set; }
        public int AccuracyMeters { get; set; }
        public string FormattedAddress { get; set; }
        public string Timestamp { get; set; }
    }
}