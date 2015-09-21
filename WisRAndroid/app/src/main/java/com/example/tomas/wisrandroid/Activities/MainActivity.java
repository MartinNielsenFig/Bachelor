package com.example.tomas.wisrandroid.Activities;


import android.app.Activity;
import android.content.Intent;
import android.graphics.Color;
import android.location.Location;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentActivity;
import android.support.v4.app.FragmentManager;
import android.support.v7.app.ActionBarActivity;
import android.os.Bundle;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.Toast;

import com.example.tomas.wisrandroid.Helpers.ActivityLayoutHelper;
import com.example.tomas.wisrandroid.Model.MyUser;
import com.example.tomas.wisrandroid.R;
import com.facebook.AccessToken;
import com.facebook.FacebookSdk;
import com.facebook.login.LoginManager;
import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.api.GoogleApiClient;
import com.google.android.gms.location.LocationServices;
import com.google.android.gms.maps.*;
import com.google.android.gms.maps.model.*;


public class MainActivity extends FragmentActivity implements GoogleApiClient.ConnectionCallbacks, GoogleApiClient.OnConnectionFailedListener {

    private GoogleMap mMap;
    private GoogleApiClient mGoogleApiClient;
    private Location mLastLocation;

    private Button mCreateRoomButton;
    private Button mSelectRoomButton;
    private Button mLogoutButton;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        FacebookSdk.sdkInitialize(getApplicationContext());
        setContentView(R.layout.activity_main);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);
        getWindow().getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN);

        buildGoogleApiClient();

        mGoogleApiClient.connect();

        setUpMapIfNeeded();

//        if (AccessToken.getCurrentAccessToken() != null)
//        {
//            MyUser.getMyuser().set_FacebookId(Integer.parseInt(AccessToken.getCurrentAccessToken().getUserId()));
//            Toast.makeText(getApplicationContext(),MyUser.getMyuser().get_FacebookId(),Toast.LENGTH_LONG).show();
//        }

        mCreateRoomButton = (Button) findViewById(R.id.button_create_room);
        mCreateRoomButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Bundle mBundle = new Bundle();

                if (AccessToken.getCurrentAccessToken() != null) {
                    MyUser.getMyuser().set_FacebookId(AccessToken.getCurrentAccessToken().getUserId());
                    //Toast.makeText(getApplicationContext(), AccessToken.getCurrentAccessToken().getUserId(), Toast.LENGTH_LONG).show();
                    Intent mCreateRoomIntent = new Intent(MainActivity.this, CreateRoomActivity.class);
                    startActivity(mCreateRoomIntent);
                } else {
                    Intent mIntent = new Intent(MainActivity.this, LoginActivity.class);
                    mIntent.putExtra("Bundle", mBundle);
                    startActivity(mIntent);
                }
            }
        });

        mSelectRoomButton = (Button) findViewById(R.id.button_find_room);
        mSelectRoomButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Bundle mBundle = new Bundle();
                //mBundle.putString("FindRoom","FR");
                Intent mIntent = new Intent(MainActivity.this, SelectRoomActivity.class);
                startActivity(mIntent);
            }
        });

        mLogoutButton = (Button) findViewById(R.id.button_logout);
        mLogoutButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                LoginManager.getInstance().logOut();
                mLogoutButton.setEnabled(false);
            }
        });

    }

    @Override
    protected void onStart() {
        super.onStart();

        Toast.makeText(this,"viggo", Toast.LENGTH_LONG).show();
        if(AccessToken.getCurrentAccessToken() != null)
            Toast.makeText(this,AccessToken.getCurrentAccessToken().getUserId(),Toast.LENGTH_LONG).show();

        if(AccessToken.getCurrentAccessToken() == null)
        {
            mLogoutButton.setEnabled(false);
        }else {
            mLogoutButton.setEnabled(true);
        }
    }

    @Override
    protected void onResume() {
        super.onResume();
        setUpMapIfNeeded();

        if(AccessToken.getCurrentAccessToken() == null)
        {
            mLogoutButton.setEnabled(false);
        }else {
            mLogoutButton.setEnabled(true);
        }


    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_main, menu);
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

    private void setUpMapIfNeeded() {
        // Do a null check to confirm that we have not already instantiated the map.
        if (mMap == null) {
            // Try to obtain the map from the SupportMapFragment.
            mMap = ((SupportMapFragment) getSupportFragmentManager().findFragmentById(R.id.map))
                    .getMap();
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
            mMap.moveCamera(CameraUpdateFactory.newLatLngZoom(new LatLng(mLastLocation.getLatitude(), mLastLocation.getLongitude()), 17));

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
    public void onConnected(Bundle bundle) {
        mLastLocation = LocationServices.FusedLocationApi.getLastLocation(mGoogleApiClient);
        if (mLastLocation != null) {
            setUpMap();
        }
    }

    @Override
    public void onConnectionSuspended(int i) {

    }

    @Override
    public void onConnectionFailed(ConnectionResult connectionResult) {

    }
}
