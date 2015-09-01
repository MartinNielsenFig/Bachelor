package com.example.tomas.wisrandroid.Model;

import java.util.List;

public class User {

    //Fields
    private String _id;
    private int _facebookId;
    private List<String> _connectedRooms;

    //Constructors
    public User(){}
    public User(String _id, int _facebookId, List<String> _connectedRooms)
    {
        this._id = _id;
        this._facebookId = _facebookId;
        this._connectedRooms = _connectedRooms;
    }

    //Properties
    public String get_id() { return _id; }
    public void set_id(String _id) {this._id = _id;}

    public int get_facebookId() {return _facebookId;}
    public void set_facebookId(int _facebookId){this._facebookId = _facebookId;}

    public List<String> get__connectedRooms() {return _connectedRooms;}
    public void set__connectedRooms(List<String> _connectedRooms){this._connectedRooms = _connectedRooms;}

}
