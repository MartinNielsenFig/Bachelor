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
import com.example.tomas.wisrandroid.Model.Question;
import com.example.tomas.wisrandroid.Model.Room;
import com.example.tomas.wisrandroid.R;
import com.facebook.Profile;
import com.facebook.ProfileTracker;
import com.google.gson.Gson;

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
    private Button mCreateRoomButton;

    // Inputs
    private EditText mRoomNameEditText;
    private EditText mRoomTagEditText;
    private EditText mPasswordEditText;

    // Switches
    private Switch mEnablePasswordSwitch;
    private Switch mEnableChatSwitch;
    private Switch mEnableAnonymousSwitch;
    private Switch mEnableUserQuestionSwitch;

    // ToggleButtons with RadioGroup
    private RadioGroup mRadiusRadioGroup;
    private ToggleButton mFirstRadiusToggleButton;
    private ToggleButton mSecondRadiusToggleButton;
    private ToggleButton mThirdRadiusToggleButton;


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
                if(mEnablePasswordSwitch.isChecked())
                {
                    mPasswordEditText.setEnabled(true);
                }else {
                    mPasswordEditText.setEnabled(false);
                }
            }
        });
        mEnableChatSwitch = (Switch) findViewById(R.id.room_enable_chat_switch);
        mEnableAnonymousSwitch = (Switch) findViewById(R.id.room_anonymous_switch);
        mEnableUserQuestionSwitch = (Switch) findViewById(R.id.room_enable_userquestions_switch);

        // Toggle Button Logic
        mFirstRadiusToggleButton = (ToggleButton) findViewById(R.id.first_radius_button);
        mFirstRadiusToggleButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if(mFirstRadiusToggleButton.isChecked())
                {
                    if(mSecondRadiusToggleButton.isChecked() || mThirdRadiusToggleButton.isChecked())
                    {
                        mSecondRadiusToggleButton.setChecked(false);
                        mThirdRadiusToggleButton.setChecked(false);
                    }
                }

            }
        });
        mSecondRadiusToggleButton = (ToggleButton) findViewById(R.id.second_radius_button);
        mSecondRadiusToggleButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if(mSecondRadiusToggleButton.isChecked())
                {
                    if(mFirstRadiusToggleButton.isChecked() || mThirdRadiusToggleButton.isChecked())
                    {
                        mFirstRadiusToggleButton.setChecked(false);
                        mThirdRadiusToggleButton.setChecked(false);
                    }
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
                }
            }
        });

        mCreateRoomButton = (Button)findViewById(R.id.create_room_button);
        mCreateRoomButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {


                final TextView mTextView = (TextView) findViewById(R.id.room_name_textview);

                Map<String,String> mParams = new HashMap<String, String>();

                Room mRoom = new Room();
                mRoom.set_CreatedById("Tomas");
                mRoom.set_AllowAnonymous(false);
                mRoom.set_EncryptedPassword("password");
                mRoom.set_HasChat(false);
                mRoom.set_HasPassword(false);
                mRoom.set_Id(null);
                mRoom.set_Radius(10);
                mRoom.set_Name("ViggoBent");
                mRoom.set_Tag("TAG");
                mRoom.set_UseLocation(false);
                mRoom.set_UsersCanAsk(false);

                Gson gson = new Gson();

                String json = gson.toJson(mRoom);

                mTextView.setText(json);

                mParams.put("Room", json);

                Response.Listener<JSONObject> mListener = new Response.Listener<JSONObject>() {
                    @Override
                    public void onResponse(JSONObject jsonObject) {
                        mTextView.setText(jsonObject.toString());
                    }
                };

                Response.ErrorListener mErrorListener = new Response.ErrorListener() {
                    @Override
                    public void onErrorResponse(VolleyError volleyError) {
                        mTextView.setText( String.valueOf(volleyError.networkResponse.statusCode));
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
