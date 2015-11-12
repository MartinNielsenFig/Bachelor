package com.example.tomas.wisrandroid.Model;

public class ChatMessage {

    //Fields
    private String ByUserId;
    private String Value;
    private String Id;
    private String RoomId;
    private String Timestamp;
    private String ByUserDisplayName;

    //Constructors
    public ChatMessage(){}
    public ChatMessage(String Id, String ByUserId, String ByUserDisplayName, String RoomId, String Value, String Timestamp)
    {
        this.Id = Id;
        this.ByUserId = ByUserId;
        this.Value = Value;
        this.Timestamp = Timestamp;
        this.RoomId = RoomId;
        this.ByUserDisplayName = ByUserDisplayName;
    }

    //Properties
    public String get_ByUserId(){return this.ByUserId;}
    public void set_ByUserId(String ByUserId){this.ByUserId = ByUserId;}

    public String get_Value(){return this.Value;}
    public void set_Value(String Value){this.Value = Value;}

    public String getId() { return Id;}
    public void setId(String id) {Id = id;}

    public String getRoomId() {return RoomId;}
    public void setRoomId(String roomId) {RoomId = roomId;}

    public String getTimestamp() {return Timestamp;}
    public void setTimestamp(String timestamp) {Timestamp = timestamp;}

    public String getByUserDisplayName() {return ByUserDisplayName;}
    public void setByUserDisplayName(String byUserDisplayName) {ByUserDisplayName = byUserDisplayName;}

}
