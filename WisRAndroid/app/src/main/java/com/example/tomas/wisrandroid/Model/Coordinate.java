package com.example.tomas.wisrandroid.Model;

import java.util.Properties;

public class Coordinate {

    //Fields
    private double Latitude;
    private double Longitude;
    private int AccuracyMeters;
    private String FormattedAddress;
    private String Timestamp;

    //Constructors
    public Coordinate(){}
    public Coordinate( double Latitude, double Longitude, int AccuracyMeters, String FormattedAddress, String Timestamp)
    {
        this.Latitude = Latitude;
        this.Longitude = Longitude;
        this.AccuracyMeters = AccuracyMeters;
        this.FormattedAddress = FormattedAddress;
        this.Timestamp = Timestamp;
    }

    //Properties
    public double get_Latitude(){return this.Latitude;}
    public void set_Latitude(double Latitude){this.Latitude = Latitude;}

    public double get_Longitude(){return this.Longitude;}
    public void set_Longitude(double Longitude){this.Longitude = Longitude;}

    public int get_AccuracyMeters(){return this.AccuracyMeters;}
    public void set_AccuracyMeters(int AccuracyMeters){this.AccuracyMeters = AccuracyMeters;}

    public String get_FormattedAddress(){return this.FormattedAddress;}
    public void set_FormattedAddress(String FormattedAddress){this.FormattedAddress = FormattedAddress;}

    public String get_Timestamp(){return this.Timestamp;}
    public void set_Timestamp(String Timestamp){this.Timestamp = Timestamp;}
}
