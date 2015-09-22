package com.example.tomas.wisrandroid.Model;

public class ResponseOption {
    private String Value;
    private int Weight;

    public ResponseOption(){}
    public ResponseOption(String Value, int Weight) {
        this.Value = Value;
        this.Weight = Weight;
    }

    public String get_value(){return this.Value;}
    public void set_value(String Value){this.Value = Value;}

    public int get_weight(){return this.Weight;}
    public void set_weight(){this.Weight = Weight;}
}
