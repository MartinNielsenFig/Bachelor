package com.example.tomas.wisrandroid.Model;

import java.util.ArrayList;

public class Notification {

    private String Data;
    private ErrorTypes ErrorType;
    private ArrayList<ErrorCodes> Errors;

    public Notification(){}
    public Notification(String Data, ErrorTypes ErrorType, ArrayList<ErrorCodes> Errors)
    {
        this.Data = Data;
        this.ErrorType = ErrorType;
        this.Errors = Errors;
    }

    public String get_Data(){return this.Data;}
    public void set_Data(String Data){this.Data = Data;}

    public ErrorTypes get_ErrorType(){return this.ErrorType;}
    public void set_ErrorType(ErrorTypes ErrorType){this.ErrorType = ErrorType;}

    public ArrayList<ErrorCodes> get_Errors(){return this.Errors;}
    public void set_Errors(ArrayList<ErrorCodes> Errors){ this.Errors = Errors;}
}
