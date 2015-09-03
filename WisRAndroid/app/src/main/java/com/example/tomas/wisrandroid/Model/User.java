package com.example.tomas.wisrandroid.Model;

import java.util.List;

public class User {

    //Fields
    private String Id;
    private int FacebookId;
    private List<String> ConnectedRooms;

    //Constructors
    public User(){}
    public User(String Id, int FacebookId, List<String> ConnectedRooms)
    {
        this.Id = Id;
        this.FacebookId = FacebookId;
        this.ConnectedRooms = ConnectedRooms;
    }

    //Properties
    public String get_Id() { return Id; }
    public void set_Id(String _id) {this.Id = Id;}

    public int get_FacebookId() {return FacebookId;}
    public void set_FacebookId(int _facebookId){this.FacebookId = FacebookId;}

    public List<String> get_ConnectedRooms() {return ConnectedRooms;}
    public void set_ConnectedRooms(List<String> ConnectedRooms){this.ConnectedRooms = ConnectedRooms;}

}
