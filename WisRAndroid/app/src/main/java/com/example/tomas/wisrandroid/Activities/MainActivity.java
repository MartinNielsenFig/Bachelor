package com.example.tomas.wisrandroid.Activities;


import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Color;
import android.location.Location;
import android.os.Bundle;
import android.support.v7.app.AlertDialog;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.Button;
import android.widget.Toast;

import com.android.volley.Request;
import com.android.volley.RequestQueue;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.Volley;
import com.example.tomas.wisrandroid.Helpers.ErrorCodesDeserializer;
import com.example.tomas.wisrandroid.Helpers.ErrorTypesDeserializer;
import com.example.tomas.wisrandroid.Helpers.HttpHelper;
import com.example.tomas.wisrandroid.Model.ErrorCodes;
import com.example.tomas.wisrandroid.Model.ErrorTypes;
import com.example.tomas.wisrandroid.Model.MyUser;
import com.example.tomas.wisrandroid.Model.Notification;
import com.example.tomas.wisrandroid.Model.User;
import com.example.tomas.wisrandroid.R;
import com.facebook.AccessToken;
import com.facebook.FacebookSdk;
import com.facebook.login.LoginManager;
import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.api.GoogleApiClient;
import com.google.android.gms.location.LocationRequest;
import com.google.android.gms.location.LocationServices;
import com.google.android.gms.maps.*;
import com.google.android.gms.maps.model.*;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

import java.util.HashMap;
import java.util.Map;


public class MainActivity extends AppCompatActivity implements GoogleApiClient.ConnectionCallbacks, GoogleApiClient.OnConnectionFailedListener {

    private GoogleMap mMap;
    private GoogleApiClient mGoogleApiClient;
    private Location mLastLocation;
    private Gson gson;

    private Menu mMenu;
    private Button mCreateRoomButton;
    private Button mSelectRoomButton;

    private Boolean ifFirst = true;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        FacebookSdk.sdkInitialize(getApplicationContext());
        setContentView(R.layout.activity_main);
        if(getSupportActionBar() != null)
            getSupportActionBar().hide();

        GsonBuilder mGsonBuilder = new GsonBuilder();
        mGsonBuilder.registerTypeAdapter(ErrorTypes.class,new ErrorTypesDeserializer());
        mGsonBuilder.registerTypeAdapter(ErrorCodes.class,new ErrorCodesDeserializer());
        gson = mGsonBuilder.create();

        buildGoogleApiClient();

        setUpMapIfNeeded();

        mCreateRoomButton = (Button) findViewById(R.id.button_create_room);
        mCreateRoomButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (AccessToken.getCurrentAccessToken() != null || (MyUser.getMyuser().get_Id() != null && !MyUser.getMyuser().get_Id().isEmpty())) {
                    Intent mCreateRoomIntent = new Intent(MainActivity.this, CreateRoomActivity.class);
                    mCreateRoomIntent.addFlags(Intent.FLAG_ACTIVITY_NO_HISTORY);
                    startActivity(mCreateRoomIntent);
                } else {
                    final AlertDialog.Builder mBackPressedAlertDialog = new AlertDialog.Builder(v.getContext());
                    mBackPressedAlertDialog.setCancelable(false);
                    mBackPressedAlertDialog.setTitle("Cant Create Room");
                    mBackPressedAlertDialog.setMessage("You have to login through the settings menu to create a room!");
                    mBackPressedAlertDialog.setPositiveButton("Ok", new DialogInterface.OnClickListener() {
                        @Override
                        public void onClick(DialogInterface dialogInterface, int i) {
                            dialogInterface.cancel();
                        }
                    });
                    mBackPressedAlertDialog.show();
                }
            }
        });

        mSelectRoomButton = (Button) findViewById(R.id.button_find_room);
        mSelectRoomButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent mIntent = new Intent(MainActivity.this, SelectRoomActivity.class);
                if(mLastLocation != null) {
                    Bundle mBundle = new Bundle();
                    mBundle.putDouble("Lat", mLastLocation.getLatitude());
                    mBundle.putDouble("Long", mLastLocation.getLongitude());
                    mIntent.putExtra("Bundle", mBundle);
                }
                startActivity(mIntent);
            }
        });
    }

    @Override
    protected void onStart() {
        super.onStart();
        mGoogleApiClient.connect();
    }

    @Override
    protected void onStop() {
        super.onStop();
        mGoogleApiClient.disconnect();
    }

    @Override
    protected void onResume() {
        super.onResume();
        setUpMapIfNeeded();
        if (mMenu != null) {
            HandleLoginMenuTitle();
        }
        if(AccessToken.getCurrentAccessToken() != null) {
            FBActiveGetUserInfo();
        }
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_main, menu);
        mMenu =  menu;
        HandleLoginMenuTitle();
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        int id = item.getItemId();

        //noinspection SimplifiableIfStatement
        if (id == R.id.action_settings) {
            return true;
        }
        if (id == R.id.action_logout)
        {
            if(AccessToken.getCurrentAccessToken() != null)
            {
                LoginManager.getInstance().logOut();
                HandleLoginMenuTitle();
                MyUser.getMyuser().set_FacebookId(null);
                MyUser.getMyuser().set_Id(null);
            }else{
                Intent mIntent = new Intent(MainActivity.this, LoginActivity.class);
                startActivity(mIntent);
            }


        }

        return super.onOptionsItemSelected(item);
    }

    @Override
    public void onConnected(Bundle bundle) {

        LocationRequest mLocationRequest = new LocationRequest();
        mLocationRequest.setInterval(3000);
        mLocationRequest.setFastestInterval(1500);
        mLocationRequest.setExpirationDuration(15000);
        mLocationRequest.setPriority(LocationRequest.PRIORITY_HIGH_ACCURACY);

        LocationServices.FusedLocationApi.requestLocationUpdates(mGoogleApiClient, mLocationRequest, new com.google.android.gms.location.LocationListener() {
            @Override
            public void onLocationChanged(Location location) {
                mMap.clear();
                mLastLocation = location;

                if (mLastLocation != null) {
                    setUpMap();
                }
            }
        });

    }

    @Override
    public void onConnectionSuspended(int i) {

    }

    @Override
    public void onConnectionFailed(ConnectionResult connectionResult) {

    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
    }

    private void setUpMapIfNeeded() {
        // Do a null check to confirm that we have not already instantiated the map.
        if (mMap == null) {
            // Try to obtain the map from the SupportMapFragment.
            mMap = ((SupportMapFragment) getSupportFragmentManager().findFragmentById(R.id.map)).getMap();
            // Check if we were successful in obtaining the map.
            if (mMap != null) {
                setUpMap();
            }
        }
    }

    private void setUpMap() {
        if(mLastLocation != null) {
            mMap.addMarker(new MarkerOptions().position(new LatLng(mLastLocation.getLatitude(), mLastLocation.getLongitude())).title("Marker"));
            mMap.addCircle(new CircleOptions().center(new LatLng(mLastLocation.getLatitude(), mLastLocation.getLongitude())).radius(mLastLocation.getAccuracy()).strokeColor(Color.RED).strokeWidth(3));
            if(ifFirst) {
                ifFirst = false;
                mMap.moveCamera(CameraUpdateFactory.newLatLngZoom(new LatLng(mLastLocation.getLatitude(), mLastLocation.getLongitude()), 17));}
        }

    }

    protected synchronized void buildGoogleApiClient() {
        mGoogleApiClient = new GoogleApiClient.Builder(getApplicationContext())
                .addApi(LocationServices.API)
                .addConnectionCallbacks(this)
                .addOnConnectionFailedListener(this)
                .build();
    }

    private void FBActiveGetUserInfo()
    {
        MyUser.getMyuser().set_FacebookId(AccessToken.getCurrentAccessToken().getUserId());
        Map<String,String> mParams = new HashMap<String, String>();
        mParams.put("facebookId", AccessToken.getCurrentAccessToken().getUserId());

        Response.Listener<String> mListener = new Response.Listener<String>() {
            @Override
            public void onResponse(String response) {
                //Toast.makeText(getApplicationContext(), response, Toast.LENGTH_LONG).show();

                Notification mNotification = gson.fromJson(response,Notification.class);

                if (mNotification.get_ErrorType() == ErrorTypes.Ok || mNotification.get_ErrorType() == ErrorTypes.Complicated) {
                    MyUser.getMyuser().set_Id(mNotification.get_Data());
                    GetUserInfo();
                }
            }
        };

        Response.ErrorListener mErrorListener = new Response.ErrorListener() {
            @Override
            public void onErrorResponse(VolleyError volleyError) {
                //Toast.makeText(getApplicationContext(),String.valueOf(volleyError.networkResponse.statusCode),Toast.LENGTH_LONG).show();
            }
        };

        RequestQueue requestQueue = Volley.newRequestQueue(getApplicationContext());
        HttpHelper jsObjRequest = new HttpHelper( Request.Method.POST, getString(R.string.restapi_url) + "/User/GetWisrIdFromFacebookId"  , mParams, mListener, mErrorListener);

        try {
            requestQueue.add(jsObjRequest);
        } catch (Exception e) {

        }
    }

    private void GetUserInfo()
    {
        Map<String,String> mParams = new HashMap<String, String>();
        mParams.put("id", MyUser.getMyuser().get_Id());


        Response.Listener<String> mListener = new Response.Listener<String>() {
            @Override
            public void onResponse(String response) {
                //Toast.makeText(getApplicationContext(), response, Toast.LENGTH_LONG).show();

                Notification mNotification = gson.fromJson(response,Notification.class);

                if (mNotification.get_ErrorType() == ErrorTypes.Ok || mNotification.get_ErrorType() == ErrorTypes.Complicated) {
                    User mTempUser;
                    try {
                        mTempUser = gson.fromJson(mNotification.get_Data(), User.class);
                    } catch (Exception e) {
                        Log.w("GsonConversionError", e.toString());
                        mTempUser = new User();
                    }

                    MyUser.getMyuser().set_ConnectedRooms(mTempUser.get_ConnectedRooms());
                    MyUser.getMyuser().set_DisplayName(mTempUser.get_DisplayName());
                    MyUser.getMyuser().set_Email(mTempUser.get_Email());
                    MyUser.getMyuser().set_LDAPUserName(mTempUser.get_ILDAPUserName());
                    MyUser.getMyuser().set_EncryptedPassword(mTempUser.get_EncryptedPassword());
                }
            }
        };

        Response.ErrorListener mErrorListener = new Response.ErrorListener() {
            @Override
            public void onErrorResponse(VolleyError volleyError) {
                //Toast.makeText(getApplicationContext(),String.valueOf(volleyError.networkResponse.statusCode),Toast.LENGTH_LONG).show();
            }
        };

        RequestQueue requestQueue = Volley.newRequestQueue(getApplicationContext());
        HttpHelper jsObjRequest = new HttpHelper( Request.Method.POST, getString(R.string.restapi_url) + "/User/GetById"  , mParams, mListener, mErrorListener);

        try {
            requestQueue.add(jsObjRequest);
        } catch (Exception e) {

        }
    }


    private void HandleLoginMenuTitle()
    {
        MenuItem mLogInMenuItem = mMenu.findItem(R.id.action_logout);
        if(AccessToken.getCurrentAccessToken() != null)
        {
            mLogInMenuItem.setTitle("Log out");
        }else {
            mLogInMenuItem.setTitle("Log in");
        }

    }

    @Override
    public void onBackPressed() {
        super.onBackPressed();
    }
}
