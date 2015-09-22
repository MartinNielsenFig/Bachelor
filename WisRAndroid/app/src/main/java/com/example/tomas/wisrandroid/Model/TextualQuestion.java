package com.example.tomas.wisrandroid.Model;

import java.util.ArrayList;
import java.util.List;

public class TextualQuestion extends Question{

    //Fields
    private String _SpecificText;

    //Constructors
    public TextualQuestion() {}
    public TextualQuestion(String _SpecificText)
    {
        this._SpecificText = _SpecificText;
    }

    //Properties
    public String get_SpecificText() {return this._SpecificText;}
    public void set_SpecificText(String _SpecificText) {this._SpecificText = _SpecificText;}

    //Overrides
    @Override
    public String get_Id() { return super.get_Id();}
    @Override
    public void set_Id(String _id) { super.set_Id(_id);}

    @Override
    public String get_QuestionText() { return super.get_QuestionText();}
    @Override
    public void set_QuestionText(String _questionText) { super.set_QuestionText(_questionText);}

    @Override
    public String get_Img() { return super.get_Img();}
    @Override
    public void set_Img(String _img) { super.set_Img(_img);}

     @Override
    public ArrayList<Vote> get_Votes() { return super.get_Votes(); }
    @Override
    public void set_Votes(ArrayList<Vote> _downvotes) { super.set_Votes(_downvotes);}

    @Override
    public String get_CreatedById() { return super.get_CreatedById();}
    @Override
    public void set_CreatedById(String _createdById) { super.set_CreatedById(_createdById);}

    @Override
    public String get_RoomId() { return super.get_RoomId();}
    @Override
    public void set_RoomId(String RoomId) { super.set_RoomId(RoomId);}

    @Override
    public ArrayList<ResponseOption> get_ResponseOptions() {return super.get_ResponseOptions();}
    @Override
    public void set_ResponseOptions(ArrayList<ResponseOption> ResponseOptions) {super.set_ResponseOptions(ResponseOptions);}

    @Override
    public ArrayList<Answer> get_Result() {return super.get_Result();}
    @Override
    public void set_Result(ArrayList<Answer> Result) {super.set_Result(Result);}

    @Override
    public String get_CreationTimestamp() {return super.get_CreationTimestamp();}
    @Override
    public void set_CreationTimestamp(String CreationTimestamp) {super.set_CreationTimestamp(CreationTimestamp);}

    @Override
    public String get_ExpireTimestamp() {return super.get_ExpireTimestamp();}
    @Override
    public void set_ExpireTimestamp(String ExpireTimestamp) {super.set_ExpireTimestamp(ExpireTimestamp);}
}
