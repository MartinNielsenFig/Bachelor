package com.example.tomas.wisrandroid.Model;

public class Error {
    private String ErrorMessage;
    private int ErrorCode;
    private String StackTrace;

    public Error(){}
    public Error(String ErrorMessage, int ErrorCode, String StackTrace)
    {
        this.ErrorMessage = ErrorMessage;
        this.ErrorCode = ErrorCode;
        this.StackTrace = StackTrace;
    }

    public String get_ErrorMessage(){return this.ErrorMessage;}
    public void set_ErrorMessage(String ErrorMessage){this.ErrorMessage = ErrorMessage;}

    public int get_ErrorCode(){return this.ErrorCode;}
    public void set_ErrorCode(int ErrorCode){this.ErrorCode = ErrorCode;}

    public String get_StackTrace(){return this.StackTrace;}
    public void set_StackTrace(String StackTrace){ this.StackTrace = StackTrace;}
}
