package com.example.tomas.wisrandroid.Model;

public class ChatMessage {

    //Fields
    private String _byUserId;
    private String _value;
    private String _date;

    //Constructors
    public ChatMessage(){}
    public ChatMessage(String _byUserId, String _value, String _date)
    {
        this._byUserId = _byUserId;
        this._value = _value;
        this._date = _date;
    }

    //Properties
    public String get_byUserId(){return this._byUserId;}
    public void set_byUserId(String _byUserId){this._byUserId = _byUserId;}

    public String get_value(){return this._value;}
    public void set_value(String _value){this._value = _value;}

    public String get_date(){return this._date;}
    public void set_date(String _date){this._date = _date;}

}
