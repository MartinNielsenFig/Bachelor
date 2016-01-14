package com.example.tomas.wisrandroid.Activities;

import android.app.ActionBar;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.support.v7.app.AlertDialog;
import android.support.v7.app.AppCompatActivity;
import android.text.InputType;
import android.text.method.PasswordTransformationMethod;
import android.util.Base64;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.inputmethod.EditorInfo;
import android.widget.AdapterView;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ListView;
import android.widget.Toast;

import com.android.volley.Request;
import com.android.volley.RequestQueue;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.Volley;
import com.example.tomas.wisrandroid.Helpers.ActivityLayoutHelper;
import com.example.tomas.wisrandroid.Helpers.ErrorCodesDeserializer;
import com.example.tomas.wisrandroid.Helpers.ErrorTypesDeserializer;
import com.example.tomas.wisrandroid.Helpers.HttpHelper;
import com.example.tomas.wisrandroid.Helpers.CustomRoomAdapter;
import com.example.tomas.wisrandroid.Model.Coordinate;
import com.example.tomas.wisrandroid.Model.ErrorCodes;
import com.example.tomas.wisrandroid.Model.ErrorTypes;
import com.example.tomas.wisrandroid.Model.Notification;
import com.example.tomas.wisrandroid.Model.Room;
import com.example.tomas.wisrandroid.R;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

import java.lang.reflect.Method;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

public class SelectRoomActivity extends AppCompatActivity {

    private final ArrayList<Room> mRoomList = new ArrayList();
    private Gson mGson;
    private ListView mListView;
    private Button mButton;
    private Coordinate mCurrentCoordinate = new Coordinate();


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_select_room);
        //ActivityLayoutHelper.HideLayout(getWindow(), getSupportActionBar());

        if(getSupportActionBar() != null)
            getSupportActionBar().hide();

        GsonBuilder mGsonBuilder = new GsonBuilder();
        mGsonBuilder.registerTypeAdapter(ErrorTypes.class,new ErrorTypesDeserializer());
        mGsonBuilder.registerTypeAdapter(ErrorCodes.class,new ErrorCodesDeserializer());
        mGson = mGsonBuilder.create();

        Bundle mTempBundle = getIntent().getBundleExtra("Bundle");

        if(mTempBundle != null) {
            mCurrentCoordinate.set_Latitude(getIntent().getBundleExtra("Bundle").getDouble("Lat"));
            mCurrentCoordinate.set_Longitude(getIntent().getBundleExtra("Bundle").getDouble("Long"));
        }

        mButton = (Button) findViewById(R.id.use_secret_button_select_room_activity);
        mButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                final Context mContext = view.getContext();
                final AlertDialog.Builder mSecretAlertDialog = new AlertDialog.Builder(mContext);
                final EditText input = new EditText(getApplicationContext());
                input.setBackgroundColor(Color.WHITE);
                input.setTextColor(Color.BLACK);
                input.setHint("Enter secret");
                input.setHintTextColor(Color.GRAY);
                input.setPadding(50, 0, 0, 0);
                mSecretAlertDialog.setCancelable(false);
                mSecretAlertDialog.setTitle("Use secret");
                mSecretAlertDialog.setMessage("Please enter secret");
                mSecretAlertDialog.setView(input);
                mSecretAlertDialog.setPositiveButton("Ok", new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialogInterface, int i) {
                        final Response.Listener<String> mListener = new Response.Listener<String>() {
                            @Override
                            public void onResponse(String response) {
                                //Toast.makeText(getApplicationContext(), "In Listener", Toast.LENGTH_LONG).show();

                                try {

                                    Notification mNotification = mGson.fromJson(response, Notification.class);

                                    if(mNotification.get_ErrorType() == ErrorTypes.Ok ||mNotification.get_ErrorType() == ErrorTypes.Complicated) {
                                        final Room mRoom = mGson.fromJson(mNotification.get_Data(), Room.class);
                                        if (mRoom.get_id() != null) {
                                            if (mRoom.get_HasPassword()) {
                                                final AlertDialog.Builder mPasswordAlertDialog = new AlertDialog.Builder(mContext);
                                                final EditText input = new EditText(getApplicationContext());
                                                //input.setTransformationMethod(PasswordTransformationMethod.getInstance());
                                                input.setInputType(InputType.TYPE_TEXT_VARIATION_PASSWORD|InputType.TYPE_CLASS_TEXT);
                                                input.setBackgroundColor(Color.WHITE);
                                                input.setTextColor(Color.BLACK);
                                                input.setHint("Enter room password");
                                                input.setHintTextColor(Color.GRAY);
                                                input.setPadding(50, 0, 0, 0);
                                                mPasswordAlertDialog.setCancelable(false);
                                                mPasswordAlertDialog.setTitle("Password");
                                                mPasswordAlertDialog.setMessage("Please enter password");
                                                mPasswordAlertDialog.setView(input);
                                                mPasswordAlertDialog.setPositiveButton("Ok", new DialogInterface.OnClickListener() {
                                                    @Override
                                                    public void onClick(DialogInterface dialogInterface, int i) {
                                                        String currentText = input.getText().toString();
                                                        String password = "";
                                                        MessageDigest md;
                                                        try {
                                                            md = MessageDigest.getInstance("SHA-512");
                                                            md.update(currentText.getBytes());
                                                            byte byteData[] = md.digest();

                                                            StringBuffer hashCodeBuffer = new StringBuffer();
                                                            for (int index = 0; index < byteData.length; index++) {
                                                                hashCodeBuffer.append(Integer.toString((byteData[index] & 0xff) + 0x100, 16).substring(1));
                                                            }
                                                            password = hashCodeBuffer.toString();
                                                        }catch (NoSuchAlgorithmException e) {
                                                            Log.w("PWCovErr", "Could not load MessageDigest: SHA-512");
                                                        }
                                                        if (mRoom.get_EncryptedPassword().equals(password)) {
                                                            Bundle mBundle = new Bundle();
                                                            mBundle.putString("Room", mGson.toJson(mRoom));
                                                            Intent mIntent = new Intent(getApplicationContext(), RoomActivity.class);
                                                            mIntent.putExtra("CurrentRoom", mBundle);
                                                            startActivity(mIntent, mBundle);
                                                        } else {
                                                            final AlertDialog.Builder mWrongPasswordAlertDialog = new AlertDialog.Builder(mContext);
                                                            mWrongPasswordAlertDialog.setCancelable(false);
                                                            mWrongPasswordAlertDialog.setTitle("Wrong Password");
                                                            mWrongPasswordAlertDialog.setMessage("Invalid password, please try again");
                                                            mWrongPasswordAlertDialog.setPositiveButton("Ok", new DialogInterface.OnClickListener() {
                                                                @Override
                                                                public void onClick(DialogInterface dialogInterface, int i) {
                                                                    dialogInterface.dismiss();
                                                                }
                                                            });
                                                            mWrongPasswordAlertDialog.show();
                                                        }
                                                    }
                                                });
                                                mPasswordAlertDialog.setNeutralButton("Cancel", new DialogInterface.OnClickListener() {
                                                    @Override
                                                    public void onClick(DialogInterface dialogInterface, int i) {
                                                        dialogInterface.dismiss();
                                                    }
                                                });
                                                mPasswordAlertDialog.show();
                                            } else {
                                                Bundle mBundle = new Bundle();
                                                mBundle.putString("Room", mGson.toJson(mRoom));
                                                Intent mIntent = new Intent(getApplicationContext(), RoomActivity.class);
                                                mIntent.putExtra("CurrentRoom", mBundle);
                                                startActivity(mIntent, mBundle);
                                            }
                                        } else {
                                            final AlertDialog.Builder mNoRoomFoundAlertDialog = new AlertDialog.Builder(mContext);
                                            mNoRoomFoundAlertDialog.setCancelable(false);
                                            mNoRoomFoundAlertDialog.setTitle("No room found!");
                                            mNoRoomFoundAlertDialog.setMessage("No room with the entered secret were found");
                                            mNoRoomFoundAlertDialog.setPositiveButton("Ok", new DialogInterface.OnClickListener() {
                                                @Override
                                                public void onClick(DialogInterface dialogInterface, int i) {
                                                    dialogInterface.dismiss();
                                                }
                                            });
                                            mNoRoomFoundAlertDialog.show();
                                        }
                                    }
                                } catch (Exception e) {

                                }



                            }
                        };

                        Response.ErrorListener mErrorListener = new Response.ErrorListener() {
                            @Override
                            public void onErrorResponse(VolleyError volleyError) {
                                //Toast.makeText(getApplicationContext(), "In ErrorListener" + volleyError.getMessage(), Toast.LENGTH_LONG).show();
                            }
                        };

                        Map<String, String> mmap= new HashMap<String,String>();

                        mmap.put("secret", input.getText().toString());
                        RequestQueue requestQueue = Volley.newRequestQueue(SelectRoomActivity.this);

                        HttpHelper jsObjRequest = new HttpHelper(Request.Method.POST,getString(R.string.restapi_url) +"/Room/GetByUniqueSecret", mmap, mListener , mErrorListener);

                        try { requestQueue.add(jsObjRequest);
                        } catch (Exception e){
                        }
                    }
                });
                mSecretAlertDialog.setNeutralButton("Cancel", new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialogInterface, int i) {
                        dialogInterface.dismiss();
                    }
                });
                mSecretAlertDialog.show();
            }
        });

        mListView = (ListView) findViewById(R.id.select_room_listview);
        mListView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> adapterView, View view, int i, long l) {

                final Context mContext = view.getContext();
                final Room mRoom = mRoomList.get(i);
                if(mRoom.get_HasPassword())
                {
                    final AlertDialog.Builder mPasswordAlertDialog = new AlertDialog.Builder(mContext);
                    final EditText input = new EditText(getApplicationContext());
                    //input.setTransformationMethod(PasswordTransformationMethod.getInstance());
                    input.setInputType(InputType.TYPE_TEXT_VARIATION_PASSWORD | InputType.TYPE_CLASS_TEXT);
                    input.setBackgroundColor(Color.WHITE);
                    input.setTextColor(Color.BLACK);
                    input.setHint("Enter room password");
                    input.setHintTextColor(Color.GRAY);
                    input.setPadding(50, 0, 0, 0);
                    mPasswordAlertDialog.setCancelable(false);
                    mPasswordAlertDialog.setTitle("Password");
                    mPasswordAlertDialog.setMessage("Please enter password");
                    mPasswordAlertDialog.setView(input);
                    mPasswordAlertDialog.setPositiveButton("Ok", new DialogInterface.OnClickListener() {
                        @Override
                        public void onClick(DialogInterface dialogInterface, int i) {
                            String currentText = input.getText().toString();
                            String password = "";
                            MessageDigest md;
                            try {
                                md = MessageDigest.getInstance("SHA-512");
                                md.update(currentText.getBytes());
                                byte byteData[] = md.digest();

                                StringBuffer hashCodeBuffer = new StringBuffer();
                                for (int index = 0; index < byteData.length; index++) {
                                    hashCodeBuffer.append(Integer.toString((byteData[index] & 0xff) + 0x100, 16).substring(1));
                                }
                                password = hashCodeBuffer.toString();
                            }catch (NoSuchAlgorithmException e) {
                                Log.w("PWCovErr", "Could not load MessageDigest: SHA-512");
                            }
                            String password2 = mRoom.get_EncryptedPassword();
                            if (mRoom.get_EncryptedPassword().equals(password)) {
                                Gson mGson = new Gson();
                                Bundle mBundle = new Bundle();
                                mBundle.putString("Room", mGson.toJson(mRoom));
                                Intent mIntent = new Intent(getApplicationContext(), RoomActivity.class);
                                mIntent.putExtra("CurrentRoom", mBundle);
                                startActivity(mIntent, mBundle);
                            } else {
                                final AlertDialog.Builder mWrongPasswordAlertDialog = new AlertDialog.Builder(mContext);
                                mWrongPasswordAlertDialog.setCancelable(false);
                                mWrongPasswordAlertDialog.setTitle("Wrong Password");
                                mWrongPasswordAlertDialog.setMessage("Invalid password, please try again");
                                mWrongPasswordAlertDialog.setPositiveButton("Ok", new DialogInterface.OnClickListener() {
                                    @Override
                                    public void onClick(DialogInterface dialogInterface, int i) {
                                        dialogInterface.dismiss();
                                    }
                                });
                                mWrongPasswordAlertDialog.show();
                            }
                        }
                    });
                    mPasswordAlertDialog.setNeutralButton("Cancel", new DialogInterface.OnClickListener() {
                        @Override
                        public void onClick(DialogInterface dialogInterface, int i) {
                            dialogInterface.dismiss();
                        }
                    });
                    mPasswordAlertDialog.show();
                } else {
                    Gson mGson = new Gson();
                    Bundle mBundle = new Bundle();
                    mBundle.putString("Room", mGson.toJson(mRoom));
                    Intent mIntent = new Intent(getApplicationContext(), RoomActivity.class);
                    mIntent.putExtra("CurrentRoom",mBundle);
                    startActivity(mIntent, mBundle);
                }


            }
        });

        final Response.Listener<String> mListener = new Response.Listener<String>() {
            @Override
            public void onResponse(String response) {
                //Toast.makeText(getApplicationContext(), "In Listener", Toast.LENGTH_LONG).show();

                Notification mNotification = mGson.fromJson(response,Notification.class);

                if (mNotification.get_ErrorType() == ErrorTypes.Ok || mNotification.get_ErrorType() == ErrorTypes.Complicated) {
                    Room[] mRooms = mGson.fromJson(mNotification.get_Data(), Room[].class);
                    for (Room room : mRooms) {
                        if (distanceBetweenTwoCoordinatesMeters(mCurrentCoordinate.get_Latitude(), mCurrentCoordinate.get_Longitude(), room.get_Location().get_Latitude(), room.get_Location().get_Longitude()) < (room.get_Radius() + room.get_Location().get_AccuracyMeters() + mCurrentCoordinate.get_AccuracyMeters()))
                            mRoomList.add(room);
                    }
                    CustomRoomAdapter temp = (CustomRoomAdapter) mListView.getAdapter();
                    temp.notifyDataSetChanged();
                }
            }
        };

        final CustomRoomAdapter mAdapter = new CustomRoomAdapter(this, mRoomList);
        mListView.setAdapter(mAdapter);

        Response.ErrorListener mErrorListener = new Response.ErrorListener() {
            @Override
            public void onErrorResponse(VolleyError volleyError) {
                Toast.makeText(getApplicationContext(), "In ErrorListener" + volleyError.getMessage(), Toast.LENGTH_LONG).show();
            }
        };

        Map<String, String> mmap= new HashMap<String,String>();

        RequestQueue requestQueue = Volley.newRequestQueue(SelectRoomActivity.this);

        HttpHelper jsObjRequest = new HttpHelper(getString(R.string.restapi_url) +"/Room/GetAll", mmap, mListener , mErrorListener);

        try {
            requestQueue.add(jsObjRequest);
        }
        catch (Exception e){

        }
    }

    //Calculation based upon http://www.movable-type.co.uk/scripts/latlong.html Calculates the distance between to latitude-longitude pairs.
    //- parameter lat1: latitude of the first coordinate
    //- parameter long1: longitude of the first coordinate
    //- parameter lat2: latitude of the second coordinate
    //- parameter long2: longitude of the second coordinate
    //- returns: Distance between the two coordinates
    //
    static Double distanceBetweenTwoCoordinatesMeters( Double lat1,  Double long1, Double lat2, Double long2) {
        Double r = 6371000.0;
        Double dLat = Math.toRadians(lat2-lat1);
        Double dLong = Math.toRadians(long2-long1);

        Double a = Math.sin(dLat / 2)*Math.sin(dLat / 2) + Math.cos(Math.toRadians(lat1))*Math.cos(Math.toRadians(lat2)) * Math.sin(dLong / 2)*Math.sin(dLong / 2);
        Double c = 2*Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        Double d = r*c;
        return d;
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_select_room, menu);
        return true;
    }

    @Override
    protected void onStart() {
        super.onStart();
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        int id = item.getItemId();

        //noinspection SimplifiableIfStatement
        if (id == R.id.action_settings) {
            return true;
        }

        return super.onOptionsItemSelected(item);
    }
}
