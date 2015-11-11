package com.example.tomas.wisrandroid.Activities;

import android.app.ActionBar;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Rect;
import android.location.Address;
import android.location.Geocoder;
import android.location.Location;
import android.os.Bundle;
import android.preference.DialogPreference;
import android.support.v7.app.AlertDialog;
import android.support.v7.app.AppCompatActivity;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewTreeObserver;
import android.widget.Button;
import android.widget.CompoundButton;
import android.widget.EditText;
import android.widget.RadioGroup;
import android.widget.Switch;
import android.widget.TextView;
import android.widget.Toast;
import android.widget.ToggleButton;

import com.android.volley.Request;
import com.android.volley.RequestQueue;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.Volley;
import com.example.tomas.wisrandroid.Helpers.ActivityLayoutHelper;
import com.example.tomas.wisrandroid.Helpers.ErrorCodesDeserializer;
import com.example.tomas.wisrandroid.Helpers.ErrorTypesDeserializer;
import com.example.tomas.wisrandroid.Helpers.HttpHelper;
import com.example.tomas.wisrandroid.Model.Coordinate;
import com.example.tomas.wisrandroid.Model.ErrorCodes;
import com.example.tomas.wisrandroid.Model.ErrorTypes;
import com.example.tomas.wisrandroid.Model.Notification;
import com.example.tomas.wisrandroid.Model.Room;
import com.example.tomas.wisrandroid.R;
import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.api.GoogleApiClient;
import com.google.android.gms.location.LocationRequest;
import com.google.android.gms.location.LocationServices;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

public class CreateRoomActivity extends AppCompatActivity implements GoogleApiClient.ConnectionCallbacks, GoogleApiClient.OnConnectionFailedListener {

    private Gson gson;

    // Classes needed to handle the coordinates of the room
    private GoogleApiClient mGoogleApiClient;
    private Location mLastLocation;

    // Buttons (Volatile might be redundant)
    private volatile Button mCreateRoomButton;

    // Inputs
    private volatile EditText mRoomNameEditText;
    private volatile EditText mRoomTagEditText;
    private volatile EditText mPasswordEditText;

    // Switches
    private volatile Switch mEnablePasswordSwitch;
    private volatile Switch mEnableChatSwitch;
    private volatile Switch mEnableAnonymousSwitch;
    private volatile Switch mEnableUserQuestionSwitch;
    private volatile Switch mEnableUseLocationSwitch;

    // ToggleButtons with RadioGroup
    private volatile RadioGroup mRadiusRadioGroup;
    private volatile ToggleButton mFirstRadiusToggleButton;
    private volatile ToggleButton mSecondRadiusToggleButton;
    private volatile ToggleButton mThirdRadiusToggleButton;

    // View


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_create_room);
        //ActivityLayoutHelper.HideLayout(getWindow(), getSupportActionBar());
        if(getSupportActionBar() != null)
            getSupportActionBar().hide();

        GsonBuilder mGsonBuilder = new GsonBuilder();
        mGsonBuilder.registerTypeAdapter(ErrorTypes.class,new ErrorTypesDeserializer());
        mGsonBuilder.registerTypeAdapter(ErrorCodes.class,new ErrorCodesDeserializer());
        gson = mGsonBuilder.create();

        buildGoogleApiClient();
        mGoogleApiClient.connect();

        // Edit Text Logic
        mRoomNameEditText = (EditText) findViewById(R.id.room_name_edittext);
        mRoomTagEditText = (EditText) findViewById(R.id.room_tag_edittext);
        mPasswordEditText = (EditText) findViewById(R.id.room_password_edittext);

        // Switch Logic
        mEnablePasswordSwitch = (Switch) findViewById(R.id.room_enable_password_switch);
        //mEnablePasswordSwitch.setThumbResource(R.drawable.button_style);
        mEnablePasswordSwitch.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton compoundButton, boolean b) {
                CheckPasswordSwitchState();
            }
        });

        mEnableChatSwitch = (Switch) findViewById(R.id.room_enable_chat_switch);
        mEnableAnonymousSwitch = (Switch) findViewById(R.id.room_anonymous_switch);
        mEnableUserQuestionSwitch = (Switch) findViewById(R.id.room_enable_userquestions_switch);
        mEnableUseLocationSwitch = (Switch)findViewById(R.id.room_enable_uselocation_switch);

        // Toggle Button Logic
        mFirstRadiusToggleButton = (ToggleButton) findViewById(R.id.first_radius_button);
        mFirstRadiusToggleButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if (mFirstRadiusToggleButton.isChecked()) {
                    if (mSecondRadiusToggleButton.isChecked() || mThirdRadiusToggleButton.isChecked()) {
                        mSecondRadiusToggleButton.setChecked(false);
                        mThirdRadiusToggleButton.setChecked(false);
                    }
                    mFirstRadiusToggleButton.setChecked(true);
                }

            }
        });
        mSecondRadiusToggleButton = (ToggleButton) findViewById(R.id.second_radius_button);
        mSecondRadiusToggleButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if (mSecondRadiusToggleButton.isChecked()) {
                    if (mFirstRadiusToggleButton.isChecked() || mThirdRadiusToggleButton.isChecked()) {
                        mFirstRadiusToggleButton.setChecked(false);
                        mThirdRadiusToggleButton.setChecked(false);
                    }
                    mSecondRadiusToggleButton.setChecked(true);
                }
            }
        });
        mThirdRadiusToggleButton = (ToggleButton) findViewById(R.id.third_radius_button);
        mThirdRadiusToggleButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if(mThirdRadiusToggleButton.isChecked())
                {
                    if(mFirstRadiusToggleButton.isChecked() || mSecondRadiusToggleButton.isChecked())
                    {
                        mFirstRadiusToggleButton.setChecked(false);
                        mSecondRadiusToggleButton.setChecked(false);
                    }
                    mThirdRadiusToggleButton.setChecked(true);
                }

            }
        });

        mCreateRoomButton = (Button)findViewById(R.id.create_room_button);
        mCreateRoomButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                Map<String,String> mParams = new HashMap<String, String>();

                final Room mRoom = new Room();
                //mRoom.set_CreatedById(MyUser.getMyuser().get_Id());
                mRoom.set_Name(mRoomNameEditText.getText().toString());
                mRoom.set_AllowAnonymous(mEnableAnonymousSwitch.isChecked());
                mRoom.set_HasPassword(mEnablePasswordSwitch.isChecked());
                mRoom.set_EncryptedPassword(mPasswordEditText.getText().toString());
                mRoom.set_HasChat(mEnableChatSwitch.isChecked());
                mRoom.set_id(null);
                if (mFirstRadiusToggleButton.isChecked())
                {
                    mRoom.set_Radius(Integer.parseInt(mFirstRadiusToggleButton.getTextOn().toString().replace("m","")));
                }else if(mSecondRadiusToggleButton.isChecked())
                {
                    mRoom.set_Radius(Integer.parseInt(mSecondRadiusToggleButton.getTextOn().toString().replace("m","")));
                }else if(mThirdRadiusToggleButton.isChecked())
                {
                    mRoom.set_Radius(Integer.parseInt(mThirdRadiusToggleButton.getTextOn().toString().replace("m","")));
                }
                mRoom.set_Secret(mRoomTagEditText.getText().toString());
                mRoom.set_UseLocation(mEnableUseLocationSwitch.isChecked());
                mRoom.set_UsersCanAsk(mEnableUserQuestionSwitch.isChecked());

                // Location
                Geocoder mGeoCoder = new Geocoder(getApplicationContext(), Locale.getDefault());
                Coordinate mCoordinate = new Coordinate();
                try {
                    List<Address> mAddresses = mGeoCoder.getFromLocation(mLastLocation.getLatitude(), mLastLocation.getLongitude(), 1);
                    mCoordinate.set_Latitude(mLastLocation.getLatitude());
                    mCoordinate.set_Longitude(mLastLocation.getLongitude());
                    mCoordinate.set_AccuracyMeters(Math.round(mLastLocation.getAccuracy()));
                    mCoordinate.set_FormattedAddress(mAddresses.get(0).getAddressLine(0) + ", " + mAddresses.get(0).getAddressLine(1) + ", " + mAddresses.get(0).getAddressLine(2));
                    mCoordinate.set_Timestamp(String.valueOf(mLastLocation.getTime()));
                    mRoom.set_Locatin(mCoordinate);
                } catch (IOException e) {
                    e.printStackTrace();
                }

                String json = gson.toJson(mRoom);

                mParams.put("Room", json);

                Response.Listener<String> mListener = new Response.Listener<String>() {
                    @Override
                    public void onResponse(String response) {
                        Toast.makeText(getApplicationContext(), "In Listener", Toast.LENGTH_LONG).show();

                        Notification mNotification = gson.fromJson(response, Notification.class);

                        if (mNotification.get_ErrorType() == ErrorTypes.Ok || mNotification.get_ErrorType() == ErrorTypes.Complicated) {
                            mRoom.set_id(mNotification.get_Data());
                            //mResp.setText(response);

                            Bundle mBundle = new Bundle();
                            mBundle.putString("Room", gson.toJson(mRoom));
                            Intent mIntent = new Intent(getApplicationContext(), RoomActivity.class);
                            mIntent.putExtra("CurrentRoom", mBundle);
                            startActivity(mIntent, mBundle);
                        } else {Toast.makeText(getApplicationContext(), ErrorTypes.Error.toString(), Toast.LENGTH_LONG).show();}
                    }
                };

                Response.ErrorListener mErrorListener = new Response.ErrorListener() {
                    @Override
                    public void onErrorResponse(VolleyError volleyError) {
                        Toast.makeText(getApplicationContext(),"In ErrorListener" + volleyError.getMessage(),Toast.LENGTH_LONG).show();
                    }
                };

                RequestQueue requestQueue = Volley.newRequestQueue(CreateRoomActivity.this);
                HttpHelper jsObjRequest = new HttpHelper(Request.Method.POST, getString(R.string.restapi_url) + "/Room/CreateRoom", mParams, mListener , mErrorListener); // "http://10.0.2.2:1337/Room/CreateRoom"

                try {
                    requestQueue.add(jsObjRequest);
                }
                catch (Exception e){

                }

            }
        });

        CheckPasswordSwitchState();
    }

    @Override
    protected void onResume() {
        super.onResume();
        CheckPasswordSwitchState();
//        final View mActivityRootView = findViewById(R.id.root);
//        mActivityRootView.getViewTreeObserver().addOnGlobalLayoutListener(new ViewTreeObserver.OnGlobalLayoutListener() {
//            @Override
//            public void onGlobalLayout() {
//                int heightDiff = mActivityRootView.getRootView().getHeight() - mActivityRootView.getHeight();
//                if (heightDiff > 40) { // if more than 100 pixels, its probably a keyboard...
//                    mActivityRootView.getLayoutParams().height -= 120;
//
//                }
//            }
//        });
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_create_room, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        //noinspection SimplifiableIfStatement
        if (id == R.id.action_settings) {
            return true;
        }

        return super.onOptionsItemSelected(item);
    }

    @Override
    public void onConnected(Bundle bundle) {
        LocationServices.FusedLocationApi.requestLocationUpdates(mGoogleApiClient, LocationRequest.create().setPriority(LocationRequest.PRIORITY_HIGH_ACCURACY), new com.google.android.gms.location.LocationListener() {
            @Override
            public void onLocationChanged(Location location) {
                mLastLocation = location;
            }
        });
    }

    @Override
    public void onConnectionSuspended(int i) {

    }

    @Override
    public void onConnectionFailed(ConnectionResult connectionResult) {

    }

    private void CheckPasswordSwitchState()
    {
        if(mEnablePasswordSwitch.isChecked())
        {
            mPasswordEditText.setEnabled(true);
        }else {
            mPasswordEditText.setEnabled(false);
        }
    }

    protected synchronized void buildGoogleApiClient() {
        mGoogleApiClient = new GoogleApiClient.Builder(this)
                .addConnectionCallbacks(this)
                .addOnConnectionFailedListener(this)
                .addApi(LocationServices.API)
                .build();
    }

    @Override
    public void onBackPressed() {
        final AlertDialog.Builder mBackPressedAlertDialog = new AlertDialog.Builder(this);
        mBackPressedAlertDialog.setCancelable(false);
        mBackPressedAlertDialog.setTitle("Are you sure ?");
        mBackPressedAlertDialog.setMessage("You're about to cancel room creation!");
        mBackPressedAlertDialog.setNeutralButton("Cancel", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialogInterface, int i) {
                ((AlertDialog) dialogInterface).cancel();
            }
        });
        mBackPressedAlertDialog.setPositiveButton("Ok", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialogInterface, int i) {
            finish();
            }
        });
        mBackPressedAlertDialog.show();

    }
}
