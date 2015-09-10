package com.example.tomas.wisrandroid.Activities;

import android.content.Intent;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentActivity;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentTransaction;
import android.support.v7.app.ActionBarActivity;
import android.os.Bundle;
import android.view.Menu;
import android.view.MenuItem;
import android.widget.Toast;

import com.example.tomas.wisrandroid.Fragments.FindRoomFragment;
import com.example.tomas.wisrandroid.Fragments.LoginFragment;
import com.example.tomas.wisrandroid.Helpers.ActivityLayoutHelper;
import com.example.tomas.wisrandroid.Model.MyUser;
import com.example.tomas.wisrandroid.R;
import com.facebook.AccessToken;
import com.rabbitmq.client.AMQP;

public class StartActivity extends FragmentActivity {

    private LoginFragment loginFragment;
    private FindRoomFragment findRoomFragment;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_start);
        //ActivityLayoutHelper.HideLayout(this.getWindow(),this.getSupportActionBar());

        Intent myIntent = getIntent();

        String mString = myIntent.getBundleExtra("Bundle").getString("CreateRoom");

        FragmentManager fm = getSupportFragmentManager();
        if( mString.equals("CR") )
        {
            if (findViewById(R.id.start_fragment_container) != null) {
                // Section for adding login fragment
                if (savedInstanceState == null) {
                    // Add the fragment on initial activity setup
                    loginFragment = new LoginFragment();
                    loginFragment.setRetainInstance(true);
                    loginFragment.setArguments(getIntent().getExtras());
                    getSupportFragmentManager()
                            .beginTransaction()
                            .replace(R.id.start_fragment_container, loginFragment)
                            .commit();
                } else {
                    // Or set the fragment from restored state info
                    loginFragment = (LoginFragment) getSupportFragmentManager()
                            .findFragmentById(R.id.start_fragment_container);
                }
            }
//        }else {
//            if(findViewById(R.id.start_fragment_container) != null)
//            {
//                // Section for adding login fragment
//                if (savedInstanceState == null) {
//                    // Add the fragment on initial activity setup
//                    findRoomFragment = new FindRoomFragment();
//                    findRoomFragment.setRetainInstance(true);
//                    findRoomFragment.setArguments(getIntent().getExtras());
//                    getSupportFragmentManager()
//                            .beginTransaction()
//                            .replace(R.id.start_fragment_container, findRoomFragment)
//                            .addToBackStack(null)
//                            .commit();
//                } else {
//                    // Or set the fragment from restored state info
//                    findRoomFragment = (FindRoomFragment) getSupportFragmentManager()
//                            .findFragmentById(R.id.start_fragment_container);
//                }
//            }
        }


        //tart_fragment_container




    }

    @Override
    protected void onStart()
    {
        super.onStart();
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_start, menu);
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
}
