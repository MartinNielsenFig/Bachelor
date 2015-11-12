package com.example.tomas.wisrandroid.Model;

import java.util.ArrayList;

public class MultipleChoiceQuestion extends Question {

    public MultipleChoiceQuestion(){}

    @Override
    public String get_Id() {return super.get_Id();}
    @Override
    public void set_Id(String Id) {super.set_Id(Id);}

    @Override
    public String get_QuestionText() {return super.get_QuestionText();}
    @Override
    public void set_QuestionText(String QuestionText) {super.set_QuestionText(QuestionText);}

    @Override
    public String get_Img() {return super.get_Img();}
    @Override
    public void set_Img(String Img) {super.set_Img(Img);}

    @Override
    public ArrayList<Vote> get_Votes() {return super.get_Votes();}
    @Override
    public void set_Votes(ArrayList<Vote> Votes) {super.set_Votes(Votes);}

    @Override
    public String get_CreatedById() {return super.get_CreatedById();}
    @Override
    public void set_CreatedById(String CreatedById) {super.set_CreatedById(CreatedById);}

    @Override
    public String get_RoomId() {return super.get_RoomId();}
    @Override
    public void set_RoomId(String RoomId) {super.set_RoomId(RoomId);}

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

    @Override
    public String getCreatedByUserDisplayName() {return super.getCreatedByUserDisplayName();}
    @Override
    public void setCreatedByUserDisplayName(String createdByUserDisplayName) {super.setCreatedByUserDisplayName(createdByUserDisplayName);}
}
