package com.example.tomas.wisrandroid.Model;

public abstract class Question {

    //Fields
    private String _id;
    private String _questionText;
    private String _img;
    private int _upvotes;
    private int _downvotes;
    private String _createdById;

    //Constructors
    public Question(){};
    public Question(String _id, String _questionText, String _img, int _upvotes, int _downvotes, String _createdById)
    {
        this._id = _id;
        this._questionText = _questionText;
        this._img = _img;
        this._upvotes = _upvotes;
        this._downvotes = _downvotes;
        this._createdById = _createdById;
    }

    //Properties
    public String get_id(){return this._id;}
    public void set_id(String _id){this._id = _id;}

    public String get_questionText(){return this._questionText;}
    public void set_questionText(String _questionText){this._questionText = _questionText;}

    public String get_img(){return this._img;}
    public void set_img(String _img){this._img = _img;}

    public int get_upvotes(){return this._upvotes;}
    public void set_upvotes(int _upvotes){this._upvotes = _upvotes;}

    public int get_downvotes(){return this._downvotes;}
    public void set_downvotes(int _downvotes){this._downvotes = _downvotes;}

    public String get_createdById(){return this._createdById;}
    public void set_createdById(String _createdById){this._createdById = _createdById;}
}
