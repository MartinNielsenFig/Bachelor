package com.example.tomas.wisrandroid.Model;

public class Vote {
    private String CreatedById;
    private int Value;

    public Vote(){}
    public Vote(String createdById, int value)
    {
        this.CreatedById = createdById;
        this.Value = value;
    }

    public String get_createdById(){return CreatedById;}
    public void set_createdById(String createdById){this.CreatedById = createdById;}

    public int get_value(){return Value;}
    public void set_value(int value){this.Value = value;}
}
