package com.example.tomas.wisrandroid.Model;

import java.util.List;

public class User {

    //Fields
    private String Id;
    private String FacebookId;
    private List<String> ConnectedRooms;
    private String LDAPUserName;
    private String DisplayName;
    private String Email;
    private String EncryptedPassword;

    //Constructors
    public User(){}
    public User(String Id, String FacebookId, List<String> ConnectedRooms, String LDAPUserName
    , String DisplayName, String Email, String EncryptedPassword)
    {
        this.Id = Id;
        this.FacebookId = FacebookId;
        this.ConnectedRooms = ConnectedRooms;
        this.LDAPUserName = LDAPUserName;
        this.DisplayName = DisplayName;
        this.Email = Email;
        this.EncryptedPassword = EncryptedPassword;

    }

    //Properties
    public String get_Id() { return Id; }
    public void set_Id(String Id) {this.Id = Id;}

    public String get_FacebookId() {return FacebookId;}
    public void set_FacebookId(String FacebookId){this.FacebookId = FacebookId;}

    public List<String> get_ConnectedRooms() {return ConnectedRooms;}
    public void set_ConnectedRooms(List<String> ConnectedRooms){this.ConnectedRooms = ConnectedRooms;}

    public String get_ILDAPUserName() { return LDAPUserName; }
    public void set_LDAPUserName(String LDAPUserName) {this.LDAPUserName = LDAPUserName;}

    public String get_DisplayName() { return DisplayName; }
    public void set_DisplayName(String DisplayName) {this.DisplayName = DisplayName;}

    public String get_Email() { return Email; }
    public void set_Email(String Email) {this.Email = Email;}

    public String get_EncryptedPassword() { return EncryptedPassword; }
    public void set_EncryptedPassword(String EncryptedPassword) {this.EncryptedPassword = EncryptedPassword;}
}
