package com.example.tomas.wisrandroid.Model;


import java.util.ArrayList;
import java.util.List;

public class MyUser extends User {

    private static MyUser myUser = null;

    private MyUser() {  }

    static public MyUser getMyuser()
    {
        if(myUser == null)
            myUser = new MyUser();
        return myUser;
    }


    @Override
    public String get_FacebookId() {
        return super.get_FacebookId();
    }

    @Override
    public void set_FacebookId(String _facebookId) {
        super.set_FacebookId(_facebookId);
    }

    @Override
    public ArrayList<String> get_ConnectedRooms() {
        return super.get_ConnectedRooms();
    }

    @Override
    public void set_ConnectedRooms(ArrayList<String> ConnectedRooms) { super.set_ConnectedRooms(ConnectedRooms); }

    @Override
    public String get_Id() {
        return super.get_Id();
    }

    @Override
    public void set_Id(String _id) {
        super.set_Id(_id);
    }

}
