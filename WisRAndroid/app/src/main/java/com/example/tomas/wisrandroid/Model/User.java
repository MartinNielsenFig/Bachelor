package com.example.tomas.wisrandroid.Model;

import java.util.ArrayList;
import java.util.List;

public class User {

    //Fields
    private String _id;
    private String FacebookId;
    private ArrayList<String> ConnectedRoomIds;
    private String LDAPUserName;
    private String DisplayName;
    private String Email;
    private String EncryptedPassword;

    //Constructors
    public User(){}
    public User(String _id, String FacebookId, ArrayList<String> ConnectedRoomIds, String LDAPUserName
    , String DisplayName, String Email, String EncryptedPassword)
    {
        this._id = _id;
        this.FacebookId = FacebookId;
        this.ConnectedRoomIds = ConnectedRoomIds;
        this.LDAPUserName = LDAPUserName;
        this.DisplayName = DisplayName;
        this.Email = Email;
        this.EncryptedPassword = EncryptedPassword;

    }

    //Properties
    public String get_Id() { return _id; }
    public void set_Id(String _id) {this._id = _id;}

    public String get_FacebookId() {return FacebookId;}
    public void set_FacebookId(String FacebookId){this.FacebookId = FacebookId;}

    public ArrayList<String> get_ConnectedRooms() {return ConnectedRoomIds;}
    public void set_ConnectedRooms(ArrayList<String> ConnectedRoomIds){this.ConnectedRoomIds = ConnectedRoomIds;}

    public String get_ILDAPUserName() { return LDAPUserName; }
    public void set_LDAPUserName(String LDAPUserName) {this.LDAPUserName = LDAPUserName;}

    public String get_DisplayName() { return DisplayName; }
    public void set_DisplayName(String DisplayName) {this.DisplayName = DisplayName;}

    public String get_Email() { return Email; }
    public void set_Email(String Email) {this.Email = Email;}

    public String get_EncryptedPassword() { return EncryptedPassword; }
    public void set_EncryptedPassword(String EncryptedPassword) {this.EncryptedPassword = EncryptedPassword;}
}
