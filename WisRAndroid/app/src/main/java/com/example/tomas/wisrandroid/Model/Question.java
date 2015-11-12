package com.example.tomas.wisrandroid.Model;

import java.lang.reflect.Array;
import java.util.ArrayList;
import java.util.List;

public abstract class Question {

    //Fields
    private String _id;
    private String QuestionText;
    private String Img;
    private ArrayList<Vote> Votes;
    private String CreatedById;
    private String CreatedByUserDisplayName;
    private String RoomId;
    private ArrayList<ResponseOption> ResponseOptions;
    private ArrayList<Answer> Result;
    private String CreationTimestamp;
    private String ExpireTimestamp;

    //Constructors
    public Question(){}
    public Question(String _id, String QuestionText, String Img, ArrayList<Vote> Votes, String CreatedById, String RoomId, ArrayList<ResponseOption> ResponseOptions,
                    ArrayList<Answer> Result, String CreationTimestamp, String ExpireTimestamp, String CreatedByUserDisplayName  )
    {
        this._id = _id;
        this.QuestionText = QuestionText;
        this.Img = Img;
        this.Votes = Votes;
        this.CreatedById = CreatedById;
        this.RoomId = RoomId;
        this.ResponseOptions = ResponseOptions;
        this.Result = Result;
        this.CreationTimestamp = CreationTimestamp;
        this.ExpireTimestamp = ExpireTimestamp;
        this.CreatedByUserDisplayName = CreatedByUserDisplayName;
    }

    //Properties
    public String get_Id(){return this._id;}
    public void set_Id(String _id){this._id = _id;}

    public String get_QuestionText(){return this.QuestionText;}
    public void set_QuestionText(String QuestionText){this.QuestionText = QuestionText;}

    public String get_Img(){return this.Img;}
    public void set_Img(String Img){this.Img = Img;}

    public ArrayList<Vote> get_Votes(){return this.Votes;}
    public void set_Votes(ArrayList<Vote> Votes){this.Votes = Votes;}

    public String get_CreatedById(){return this.CreatedById;}
    public void set_CreatedById(String CreatedById){this.CreatedById = CreatedById;}

    public String get_RoomId(){return this.RoomId;}
    public void set_RoomId(String RoomId){this.RoomId = RoomId;}

    public ArrayList<ResponseOption> get_ResponseOptions(){return this.ResponseOptions;}
    public void set_ResponseOptions(ArrayList<ResponseOption> ResponseOptions){this.ResponseOptions = ResponseOptions;}

    public ArrayList<Answer> get_Result(){return this.Result;}
    public void set_Result(ArrayList<Answer> Result){this.Result = Result;}

    public String get_CreationTimestamp(){return this.CreationTimestamp;}
    public void set_CreationTimestamp(String CreationTimestamp){this.CreationTimestamp = CreationTimestamp;}

    public String get_ExpireTimestamp(){return this.ExpireTimestamp;}
    public void set_ExpireTimestamp(String ExpireTimestamp){this.ExpireTimestamp = ExpireTimestamp;}

    public String getCreatedByUserDisplayName() { return CreatedByUserDisplayName;}
    public void setCreatedByUserDisplayName(String createdByUserDisplayName) {CreatedByUserDisplayName = createdByUserDisplayName;}
}
