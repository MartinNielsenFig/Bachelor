package com.example.tomas.wisrandroid.Model;

import android.renderscript.Allocation;

import java.util.List;

public class Room {

    //Fields
    private String Id;
    private String Name;
    private String CreatedById;
    private Coordinate Location;
    private int Radius;
    private String Tag;
    private boolean HasPassword;
    private String EncryptedPassword;
    private boolean HasChat;
    private boolean UsersCanAsk;
    private boolean AllowAnonymous;
    private boolean UseLocation;


    //Constructors
    public Room(){}
    public Room(String Id, String Name, String CreatedById, int Radius, String Tag,
                boolean HasPassword, String EncryptedPassword, boolean HasChat,
                boolean UsersCanAsk, boolean AllowAnonymous, boolean UseLocation, Coordinate Location)
    {
        this.Id = Id;
        this.Name = Name;
        this.CreatedById = CreatedById;
        this.Radius = Radius;
        this.Tag = Tag;
        this.HasPassword = HasPassword;
        this.EncryptedPassword = EncryptedPassword;
        this.HasChat = HasChat;
        this.UsersCanAsk = UsersCanAsk;
        this.AllowAnonymous = AllowAnonymous;
        this.UseLocation = UseLocation;
        this.Location = Location;
    }

    //Properties
    public String get_Id(){return this.Id;}
    public void set_Id(String Id) {this.Id = Id;}

    public String get_Name(){return this.Name;}
    public void set_Name(String Name) {this.Name = Name;}

    public String get_CreatedById(){return this.CreatedById;}
    public void set_CreatedById(String CreatedById) {this.CreatedById = CreatedById;}

    public int get_Radius(){return this.Radius;}
    public void set_Radius(int Radius) {this.Radius = Radius;}

    public String get_Tag(){return this.Tag;}
    public void set_Tag(String Tag) {this.Tag = Tag;}

    public boolean get_HasPassword(){return this.HasPassword;}
    public void set_HasPassword(boolean HasPassword) {this.HasPassword = HasPassword;}

    public String get_EncryptedPassword(){return this.EncryptedPassword;}
    public void set_EncryptedPassword(String EncryptedPassword) {this.EncryptedPassword = EncryptedPassword;}

    public boolean get_HasChat(){return this.HasChat;}
    public void set_HasChat(boolean HasChat) {this.HasChat = HasChat;}

    public boolean get_UsersCanAsk(){return this.UsersCanAsk;}
    public void set_UsersCanAsk(boolean UsersCanAsk) {this.UsersCanAsk = UsersCanAsk;}

    public boolean get_AllowAnonymous(){return this.AllowAnonymous;}
    public void set_AllowAnonymous(boolean AllowAnonymous) {this.AllowAnonymous = AllowAnonymous;}

    public boolean get_UseLocation(){return this.UseLocation;}
    public void set_UseLocation(boolean UseLocation) {this.UseLocation = UseLocation;}

    public Coordinate get_Location(){return this.Location;}
    public void set_Locatin(Coordinate Location) {this.Location = Location;}

}
