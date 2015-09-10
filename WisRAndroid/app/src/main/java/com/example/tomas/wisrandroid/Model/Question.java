package com.example.tomas.wisrandroid.Model;

import java.util.List;

public abstract class Question {

    //Fields
    private String Id;
    private String QuestionText;
    private String Img;
    private int Upvotes;
    private int Downvotes;
    private String CreatedById;
    private String RoomId;
    private List<ResponseOption> ResponseOptions;
    private List<Answer> Result;

    //Constructors
    public Question(){};
    public Question(String Id, String QuestionText, String Img, int Upvotes,
                    int Downvotes, String CreatedById, String RoomId, List<ResponseOption> ResponseOptions,List<Answer> Result  )
    {
        this.Id = Id;
        this.QuestionText = QuestionText;
        this.Img = Img;
        this.Upvotes = Upvotes;
        this.Downvotes = Downvotes;
        this.CreatedById = CreatedById;
        this.RoomId = RoomId;
        this.ResponseOptions = ResponseOptions;
        this.Result = Result;
    }

    //Properties
    public String get_Id(){return this.Id;}
    public void set_Id(String Id){this.Id = Id;}

    public String get_QuestionText(){return this.QuestionText;}
    public void set_QuestionText(String QuestionText){this.QuestionText = QuestionText;}

    public String get_Img(){return this.Img;}
    public void set_Img(String Img){this.Img = Img;}

    public int get_Upvotes(){return this.Upvotes;}
    public void set_Upvotes(int Upvotes){this.Upvotes = Upvotes;}

    public int get_Downvotes(){return this.Downvotes;}
    public void set_Downvotes(int Downvotes){this.Downvotes = Downvotes;}

    public String get_CreatedById(){return this.CreatedById;}
    public void set_CreatedById(String CreatedById){this.CreatedById = CreatedById;}

    public String get_RoomId(){return this.RoomId;}
    public void set_RoomId(String RoomId){this.RoomId = RoomId;}

    public List<ResponseOption> get_ResponseOptions(){return this.ResponseOptions;}
    public void set_ResponseOptions(List<ResponseOption> ResponseOptions){this.ResponseOptions = ResponseOptions;}

    public List<Answer> get_Result(){return this.Result;}
    public void set_Result(List<Answer> Result){this.Result = Result;}
}
