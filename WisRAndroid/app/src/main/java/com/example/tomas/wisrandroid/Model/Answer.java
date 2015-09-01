package com.example.tomas.wisrandroid.Model;

public class Answer {

    //Fields
    private String _value;
    private String _userId;

    //Constructors
    public Answer(){}
    public Answer(String _value, String _userId)
    {
        this._value = _value;
        this._userId = _userId;
    }

    //Properties
    public String get_value(){return this._value;}
    public void set_value(String _value) { this._value = _value;}

    public String get_userId(){return this._userId;}
    public void set_userId(String _userId) { this._userId = _userId;}
}
