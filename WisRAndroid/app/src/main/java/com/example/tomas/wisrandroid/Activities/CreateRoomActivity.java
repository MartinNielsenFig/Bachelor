package com.example.tomas.wisrandroid.Activities;

import android.location.GpsStatus;
import android.support.v7.app.ActionBarActivity;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.Button;
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
import com.android.volley.toolbox.StringRequest;
import com.android.volley.toolbox.Volley;
import com.example.tomas.wisrandroid.Helpers.ActivityLayoutHelper;
import com.example.tomas.wisrandroid.Helpers.HttpHelper;
import com.example.tomas.wisrandroid.Model.BooleanQuestion;
import com.example.tomas.wisrandroid.Model.ChatMessage;
import com.example.tomas.wisrandroid.Model.MyUser;
import com.example.tomas.wisrandroid.Model.Question;
import com.example.tomas.wisrandroid.Model.Room;
import com.example.tomas.wisrandroid.R;
import com.facebook.Profile;
import com.facebook.ProfileTracker;
import com.google.gson.Gson;

import org.json.JSONException;
import org.json.JSONObject;
import org.json.JSONStringer;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.net.ssl.HttpsURLConnection;

public class CreateRoomActivity extends AppCompatActivity {

    // Buttons
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


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_create_room);
        ActivityLayoutHelper.HideLayout(getWindow(), getSupportActionBar());

        // Edit Text Logic
        mRoomNameEditText = (EditText) findViewById(R.id.room_name_edittext);
        mRoomTagEditText = (EditText) findViewById(R.id.room_tag_edittext);
        mPasswordEditText = (EditText) findViewById(R.id.room_password_edittext);

        // Switch Logic
        mEnablePasswordSwitch = (Switch) findViewById(R.id.room_enable_password_switch);
        mEnablePasswordSwitch.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                CheckState();
            }
        });
        mEnableChatSwitch = (Switch) findViewById(R.id.room_enable_chat_switch);
        mEnableAnonymousSwitch = (Switch) findViewById(R.id.room_anonymous_switch);
        mEnableUserQuestionSwitch = (Switch) findViewById(R.id.room_enable_userquestions_switch);
        mEnableUseLocationSwitch = (Switch)findViewById(R.id.room_enable_uselocation_switch);

        // Toggle Button Logic
        mFirstRadiusToggleButton = (ToggleButton) findViewById(R.id.first_radius_button);
//        mFirstRadiusToggleButton.setTextOn("10m");
//        mFirstRadiusToggleButton.setTextOff("10m");
        mFirstRadiusToggleButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if (mFirstRadiusToggleButton.isChecked()) {
                    if (mSecondRadiusToggleButton.isChecked() || mThirdRadiusToggleButton.isChecked()) {
                        mSecondRadiusToggleButton.setChecked(false);
                        mThirdRadiusToggleButton.setChecked(false);
                    }
                }

            }
        });
        mSecondRadiusToggleButton = (ToggleButton) findViewById(R.id.second_radius_button);
//        mSecondRadiusToggleButton.setTextOn("20m");
//        mSecondRadiusToggleButton.setTextOff("20m");
        mSecondRadiusToggleButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if (mSecondRadiusToggleButton.isChecked()) {
                    if (mFirstRadiusToggleButton.isChecked() || mThirdRadiusToggleButton.isChecked()) {
                        mFirstRadiusToggleButton.setChecked(false);
                        mThirdRadiusToggleButton.setChecked(false);
                    }
                }
            }
        });
        mThirdRadiusToggleButton = (ToggleButton) findViewById(R.id.third_radius_button);
//        mThirdRadiusToggleButton.setTextOn("40m");
//        mThirdRadiusToggleButton.setTextOff("40m");
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
                }
            }
        });

        mCreateRoomButton = (Button)findViewById(R.id.create_room_button);
        mCreateRoomButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {


                Map<String,String> mParams = new HashMap<String, String>();

                final Room mRoom = new Room();
                //mRoom.set_CreatedById(MyUser.getMyuser().get_Id()); // Husk at implementere at få user id under login,
                                                                      // samt at få tildelt en bruger under login hvis ingen bruger er tilstede på MongoDB
                mRoom.set_Name(mRoomNameEditText.getText().toString());
                mRoom.set_AllowAnonymous(mEnableAnonymousSwitch.isChecked());
                mRoom.set_HasPassword(mEnablePasswordSwitch.isChecked());
                mRoom.set_EncryptedPassword(mPasswordEditText.getText().toString());
                mRoom.set_HasChat(mEnableChatSwitch.isChecked());
                mRoom.set_Id(null);
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
                mRoom.set_Tag(mRoomTagEditText.getText().toString());
                mRoom.set_UseLocation(mEnableUseLocationSwitch.isChecked());
                mRoom.set_UsersCanAsk(mEnableUserQuestionSwitch.isChecked());

                Gson gson = new Gson();

                String json = gson.toJson(mRoom);

                mParams.put("Room", json);

                final TextView mErr = (TextView) findViewById(R.id.errortext);
                final TextView mResp = (TextView) findViewById(R.id.responsetext);

                Response.Listener<String> mListener = new Response.Listener<String>() {
                    @Override
                    public void onResponse(String response) {
                        Toast.makeText(getApplicationContext(), "In Listener", Toast.LENGTH_LONG).show();
                        mResp.setText(response.toString());
                    }
                };

                Response.ErrorListener mErrorListener = new Response.ErrorListener() {
                    @Override
                    public void onErrorResponse(VolleyError volleyError) {
                        Toast.makeText(getApplicationContext(),"In ErrorListener" + volleyError.getMessage(),Toast.LENGTH_LONG).show();
                        mErr.setText(volleyError.getMessage());
                    }
                };

                RequestQueue requestQueue = Volley.newRequestQueue(CreateRoomActivity.this);
                HttpHelper jsObjRequest = new HttpHelper(Request.Method.POST, "http://10.0.2.2:1337/Room/CreateRoom", mParams, mListener , mErrorListener);

                try {
                    requestQueue.add(jsObjRequest);
                }
                catch (Exception e){

                }

            }
        });

        CheckState();
    }

    @Override
    protected void onResume() {
        super.onResume();
        CheckState();
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

    private void CheckState()
    {
        if(mEnablePasswordSwitch.isChecked())
        {
            mPasswordEditText.setEnabled(true);
        }else {
            mPasswordEditText.setEnabled(false);
        }
    }

    // Skal muligvis fjernes
    private String getPostData(HashMap<String, String> params) throws UnsupportedEncodingException {
        StringBuilder result = new StringBuilder();
        boolean first = true;
        for(Map.Entry<String, String> entry : params.entrySet()){
            if (first)
                first = false;
            else
                result.append("&");

            result.append(URLEncoder.encode(entry.getKey(), "UTF-8"));
            result.append("=");
            result.append(URLEncoder.encode(entry.getValue(), "UTF-8"));
        }

        return result.toString();
    }
}
