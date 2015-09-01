package com.example.tomas.wisrandroid.Model;

import java.util.Properties;

public class Coordinate {

    //Fields
    private double _latitude;
    private double _longitude;
    private int _accuracyMeters;
    private String _formattedAddress;
    private String _timestamp;

    //Constructors
    public Coordinate(){}
    public Coordinate( double _latitude, double _longitude, int _accuracyMeters, String _formattedAddress, String _timestamp)
    {
        this._latitude = _latitude;
        this._longitude = _longitude;
        this._accuracyMeters = _accuracyMeters;
        this._formattedAddress = _formattedAddress;
        this._timestamp = _timestamp;
    }

    //Properties
    public double get_latitude(){return this._latitude;}
    public void set_latitude(double _latitude){this._latitude = _latitude;}

    public double get_longitude(){return this._longitude;}
    public void set_longitude(double _longitude){this._longitude = _longitude;}

    public int get_accuracyMeters(){return this._accuracyMeters;}
    public void set_accuracyMeters(int _accuracyMeters){this._accuracyMeters = _accuracyMeters;}

    public String get_formattedAddress(){return this._formattedAddress;}
    public void set_formattedAddress(String _formattedAddress){this._formattedAddress = _formattedAddress;}

    public String get_timestamp(){return this._timestamp;}
    public void set_timestamp(String _timestamp){this._timestamp = _timestamp;}
}
