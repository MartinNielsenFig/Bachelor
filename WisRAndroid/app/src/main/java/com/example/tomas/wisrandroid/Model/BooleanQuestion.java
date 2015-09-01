package com.example.tomas.wisrandroid.Model;

public class BooleanQuestion extends Question {

    //Fields
    private String _manyBool;

    //Constructors
    public BooleanQuestion() {}
    public BooleanQuestion(String _manyBool)
    {
        this._manyBool = _manyBool;
    }

    //Properties
    public String get_manyBool() {return this._manyBool;}
    public void set_manyBool(String _manyBool) {this._manyBool = _manyBool;}

    //Overrides
    @Override
    public String get_id() { return super.get_id();}
    @Override
    public void set_id(String _id) { super.set_id(_id);}

    @Override
    public String get_questionText() { return super.get_questionText();}
    @Override
    public void set_questionText(String _questionText) { super.set_questionText(_questionText);}

    @Override
    public String get_img() { return super.get_img();}
    @Override
    public void set_img(String _img) { super.set_img(_img);}

    @Override
    public int get_upvotes() { return super.get_upvotes();}
    @Override
    public void set_upvotes(int _upvotes) { super.set_upvotes(_upvotes);}

    @Override
    public int get_downvotes() { return super.get_downvotes(); }
    @Override
    public void set_downvotes(int _downvotes) { super.set_downvotes(_downvotes);}

    @Override
    public String get_createdById() { return super.get_createdById();}
    @Override
    public void set_createdById(String _createdById) { super.set_createdById(_createdById);}

}
