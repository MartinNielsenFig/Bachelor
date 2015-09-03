package com.example.tomas.wisrandroid.Model;

public class ChatMessage {

    //Fields
    private String ByUserId;
    private String Value;
    private String Date;

    //Constructors
    public ChatMessage(){}
    public ChatMessage(String ByUserId, String Value, String Date)
    {
        this.ByUserId = ByUserId;
        this.Value = Value;
        this.Date = Date;
    }

    //Properties
    public String get_ByUserId(){return this.ByUserId;}
    public void set_ByUserId(String ByUserId){this.ByUserId = ByUserId;}

    public String get_Value(){return this.Value;}
    public void set_Value(String Value){this.Value = Value;}

    public String get_Date(){return this.Date;}
    public void set_Date(String Date){this.Date = Date;}

}
