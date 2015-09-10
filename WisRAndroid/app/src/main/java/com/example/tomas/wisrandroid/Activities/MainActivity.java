package com.example.tomas.wisrandroid.Activities;


import android.content.Intent;
import android.support.v7.app.ActionBarActivity;
import android.os.Bundle;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.Button;
import android.widget.Toast;

import com.example.tomas.wisrandroid.Fragments.LoginFragment;
import com.example.tomas.wisrandroid.Helpers.ActivityLayoutHelper;
import com.example.tomas.wisrandroid.Model.MyUser;
import com.example.tomas.wisrandroid.R;
import com.facebook.AccessToken;
import com.facebook.FacebookSdk;
import com.facebook.internal.FacebookWebFallbackDialog;


public class MainActivity extends ActionBarActivity {

    Button mCreateRoomButton = null;
    Button mSelectRoomButton = null;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        FacebookSdk.sdkInitialize(getApplicationContext());
        setContentView(R.layout.activity_main);
        ActivityLayoutHelper.HideLayout(getWindow(), getSupportActionBar());

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
                Intent mIntent = new Intent(MainActivity.this, LoginActivity.class);
                mIntent.putExtra("Bundle", mBundle);
                startActivity(mIntent);


                //if (MyUser.getMyuser().get_FacebookId() != new Integer(null))
                //{
                //    AccessToken token = AccessToken.getCurrentAccessToken();
//                    MyUser.getMyuser().set_FacebookId(Integer.parseInt(token.getUserId()));
//                    if (MyUser.getMyuser().get_Id() != null) {
//                        Toast.makeText(getApplicationContext(), token.getUserId(), Toast.LENGTH_LONG).show();
//                        Intent mCreatRoomIntent = new Intent(MainActivity.this, CreateRoomActivity.class);
//                        startActivity(mIntent);
//                    }
//                }
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

    }

    @Override
    protected void onStart() {
        super.onStart();

        Toast.makeText(this,"viggo",Toast.LENGTH_LONG).show();
        if(AccessToken.getCurrentAccessToken() != null)
            Toast.makeText(this,AccessToken.getCurrentAccessToken().getUserId(),Toast.LENGTH_LONG).show();
    }

    @Override
    protected void onResume() {
        super.onResume();


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
}
