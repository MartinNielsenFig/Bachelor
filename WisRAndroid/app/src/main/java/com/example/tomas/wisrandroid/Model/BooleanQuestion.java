package com.example.tomas.wisrandroid.Model;

import java.util.List;

public class BooleanQuestion extends Question {

    //Fields
    private String ManyBool;

    //Constructors
    public BooleanQuestion() {}
    public BooleanQuestion(String ManyBool)
    {
        this.ManyBool = ManyBool;
    }

    //Properties
    public String get_ManyBool() {return this.ManyBool;}
    public void set_ManyBool(String ManyBool) {this.ManyBool = ManyBool;}

    //Overrides
    @Override
    public String get_Id() { return super.get_Id();}
    @Override
    public void set_Id(String Id) { super.set_Id(Id);}

    @Override
    public String get_QuestionText() { return super.get_QuestionText();}
    @Override
    public void set_QuestionText(String _questionText) { super.set_QuestionText(_questionText);}

    @Override
    public String get_Img() { return super.get_Img();}
    @Override
    public void set_Img(String _img) { super.set_Img(_img);}

    @Override
    public int get_Upvotes() { return super.get_Upvotes();}
    @Override
    public void set_Upvotes(int _upvotes) { super.set_Upvotes(_upvotes);}

    @Override
    public int get_Downvotes() { return super.get_Downvotes(); }
    @Override
    public void set_Downvotes(int _downvotes) { super.set_Downvotes(_downvotes);}

    @Override
    public String get_CreatedById() { return super.get_CreatedById();}
    @Override
    public void set_CreatedById(String _createdById) { super.set_CreatedById(_createdById);}

    @Override
    public String get_RoomId() { return super.get_RoomId();}
    @Override
    public void set_RoomId(String RoomId) { super.set_RoomId(RoomId);}

    @Override
    public List<ResponseOption> get_ResponseOptions() {return super.get_ResponseOptions();}
    @Override
    public void set_ResponseOptions(List<ResponseOption> ResponseOptions) {super.set_ResponseOptions(ResponseOptions);}

    @Override
    public List<Answer> get_Result() {return super.get_Result();}
    @Override
    public void set_Result(List<Answer> Result) {super.set_Result(Result);}
}
