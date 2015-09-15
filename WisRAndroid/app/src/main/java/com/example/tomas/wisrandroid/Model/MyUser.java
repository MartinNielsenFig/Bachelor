package com.example.tomas.wisrandroid.Model;


import java.util.List;

public final class MyUser extends User {

//    private static boolean isLoggedIn;

    private static MyUser myUser = null;

    private MyUser()
    {
    }

    static public User getMyuser()
    {
        if(myUser == null)
            myUser = new MyUser();
        return myUser;
    }

//    public static boolean get_isLoggedIn(){return isLoggedIn;}
//    public static void set_isLoggedIn( boolean isLoggedIn){isLoggedIn = isLoggedIn;}

    @Override
    public String get_FacebookId() {
        return super.get_FacebookId();
    }

    @Override
    public void set_FacebookId(String _facebookId) {
        super.set_FacebookId(_facebookId);
    }

    @Override
    public List<String> get_ConnectedRooms() {
        return super.get_ConnectedRooms();
    }

    @Override
    public void set_ConnectedRooms(List<String> ConnectedRooms) {
        super.set_ConnectedRooms(ConnectedRooms);
    }

    @Override
    public String get_Id() {
        return super.get_Id();
    }

    @Override
    public void set_Id(String _id) {
        super.set_Id(_id);
    }

}
