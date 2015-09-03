package com.example.tomas.wisrandroid.Model;

public abstract class Question {

    //Fields
    private String Id;
    private String QuestionText;
    private String Img;
    private int Upvotes;
    private int Downvotes;
    private String CreatedById;

    //Constructors
    public Question(){};
    public Question(String Id, String QuestionText, String Img, int Upvotes, int Downvotes, String CreatedById)
    {
        this.Id = Id;
        this.QuestionText = QuestionText;
        this.Img = Img;
        this.Upvotes = Upvotes;
        this.Downvotes = Downvotes;
        this.CreatedById = CreatedById;
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
}
