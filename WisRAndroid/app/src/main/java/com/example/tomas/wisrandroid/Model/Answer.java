package com.example.tomas.wisrandroid.Model;

public class Answer {

    //Fields
    private String Value;
    private String UserId;

    //Constructors
    public Answer(){}
    public Answer(String Value, String UserId)
    {
        this.Value = Value;
        this.UserId = UserId;
    }

    //Properties
    public String get_Value(){return this.Value;}
    public void set_Value(String Value) { this.Value = Value;}

    public String get_UserId(){return this.UserId;}
    public void set_UserId(String UserId) { this.UserId = UserId;}
}
