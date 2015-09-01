package com.example.tomas.wisrandroid.Model;

import android.renderscript.Allocation;

public class Room {

    //Fields
    private String _id;
    private String _name;
    private String _createdById;
    private int _radius;
    private String _tag;
    private boolean _hasPassword;
    private String _encryptedPassword;
    private boolean _hasChat;
    private boolean _usersCanAsk;
    private boolean _allowAnonymous;

    //Constructors
    public Room(){}
    public Room(String _id, String _name, String _createdById, int _radius, String _tag,
                boolean _hasPassword, String _encryptedPassword, boolean _hasChat, boolean _usersCanAsk,
                boolean _allowAnonymous)
    {
        this._id = _id;
        this._name = _name;
        this._createdById = _createdById;
        this._radius = _radius;
        this._tag = _tag;
        this._hasPassword = _hasPassword;
        this._encryptedPassword = _encryptedPassword;
        this._hasChat = _hasChat;
        this._usersCanAsk = _usersCanAsk;
        this._allowAnonymous = _allowAnonymous;
    }

    //Properties
    public String get_id(){return this._id;}
    public void set_id(String _id) {this._id = _id;}

    public String get_name(){return this._name;}
    public void set_name(String _name) {this._name = _name;}

    public String get_createdById(){return this._createdById;}
    public void set_createdById(String _createdById) {this._createdById = _createdById;}

    public int get_radius(){return this._radius;}
    public void set_radius(int _radius) {this._radius = _radius;}

    public String get_tag(){return this._tag;}
    public void set_tag(String _tag) {this._tag = _tag;}

    public boolean get_hasPassword(){return this._hasPassword;}
    public void set_hasPassword(boolean _hasPassword) {this._hasPassword = _hasPassword;}

    public String get_encryptedPassword(){return this._encryptedPassword;}
    public void set_encryptedPassword(String _encryptedPassword) {this._encryptedPassword = _encryptedPassword;}

    public boolean get_hasChat(){return this._hasChat;}
    public void set_hasChat(boolean _hasChat) {this._hasChat = _hasChat;}

    public boolean get_usersCanAsk(){return this._usersCanAsk;}
    public void set_usersCanAsk(boolean _usersCanAsk) {this._usersCanAsk = _usersCanAsk;}

    public boolean get_allowAnonymous(){return this._allowAnonymous;}
    public void set_allowAnonymous(boolean _allowAnonymous) {this._allowAnonymous = _allowAnonymous;}
}
