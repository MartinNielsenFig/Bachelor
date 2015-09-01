package com.example.tomas.wisrandroid.Model;

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
