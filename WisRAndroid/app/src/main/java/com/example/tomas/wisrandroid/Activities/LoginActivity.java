package com.example.tomas.wisrandroid.Activities;

import android.content.Intent;
import android.content.res.Resources;
import android.media.session.MediaSession;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
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
import com.example.tomas.wisrandroid.Model.ErrorCodes;
import com.example.tomas.wisrandroid.Model.ErrorTypes;
import com.example.tomas.wisrandroid.Model.MyUser;
import com.example.tomas.wisrandroid.Model.Notification;
import com.example.tomas.wisrandroid.Model.User;
import com.example.tomas.wisrandroid.R;
import com.facebook.AccessToken;
import com.facebook.CallbackManager;
import com.facebook.FacebookCallback;
import com.facebook.FacebookException;
import com.facebook.GraphRequest;
import com.facebook.GraphResponse;
import com.facebook.HttpMethod;
import com.facebook.login.LoginManager;
import com.facebook.login.LoginResult;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

import org.json.JSONException;

import java.util.HashMap;
import java.util.Map;

public class LoginActivity extends AppCompatActivity {

    private CallbackManager cbm;
    private Gson gson;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_login);
        //ActivityLayoutHelper.HideLayout(getWindow(), getSupportActionBar());
        if(getSupportActionBar() != null)
        {
            getSupportActionBar().hide();
        }

        GsonBuilder mGsonBuilder = new GsonBuilder();
        mGsonBuilder.registerTypeAdapter(ErrorTypes.class,new ErrorTypesDeserializer());
        mGsonBuilder.registerTypeAdapter(ErrorCodes.class,new ErrorCodesDeserializer());
        gson = mGsonBuilder.create();

        cbm = CallbackManager.Factory.create();

        final Response.Listener<String> mListener = new Response.Listener<String>() {
            @Override
            public void onResponse(String response) {
                //Toast.makeText(getApplicationContext(), "In Listener", Toast.LENGTH_LONG).show();

                Notification mNotification = gson.fromJson(response, Notification.class);

                if (mNotification.get_ErrorType() == ErrorTypes.Ok || mNotification.get_ErrorType() == ErrorTypes.Complicated)
                    MyUser.getMyuser().set_Id(response);
                finish();
            }
        };

        final Response.ErrorListener mErrorListener = new Response.ErrorListener() {
            @Override
            public void onErrorResponse(VolleyError volleyError) {
                //Toast.makeText(getApplicationContext(),"In ErrorListener" + volleyError.getMessage(),Toast.LENGTH_LONG).show();
            }
        };

        LoginManager.getInstance().registerCallback(cbm, new FacebookCallback<LoginResult>() {
            @Override
            public void onSuccess(LoginResult loginResult) {

                MyUser.getMyuser().set_FacebookId(loginResult.getAccessToken().getUserId());

                new GraphRequest(AccessToken.getCurrentAccessToken(), "/me", null, HttpMethod.GET,
                        new GraphRequest.Callback() {
                            public void onCompleted(GraphResponse response) {
                                try {
                                    //Toast.makeText(getApplicationContext(), response.getRawResponse(), Toast.LENGTH_LONG).show();
                                    MyUser.getMyuser().set_DisplayName(response.getJSONObject().getString("name"));
                                    Log.w("NameVariableOfResponse", response.getJSONObject().getString("name"));

                                    Map<String,String> mParams = new HashMap<String,String>();
                                    User mUser = new User();
                                    mUser.set_DisplayName(MyUser.getMyuser().get_DisplayName());
                                    mUser.set_ConnectedRooms(null);
                                    mUser.set_Email(null);
                                    mUser.set_FacebookId(AccessToken.getCurrentAccessToken().getUserId());
                                    mUser.set_Id(null);
                                    mUser.set_LDAPUserName(null);
                                    mUser.set_EncryptedPassword(null);
                                    mParams.put("User",gson.toJson(mUser));

                                    RequestQueue requestQueue = Volley.newRequestQueue(LoginActivity.this);
                                    HttpHelper jsObjRequest = new HttpHelper(Request.Method.POST, getString(R.string.restapi_url) + "/User/CreateUser", mParams, mListener, mErrorListener); // "http://10.0.2.2:1337/Room/CreateRoom"

                                    try {
                                        requestQueue.add(jsObjRequest);
                                    } catch (Exception e) {
                                    }

                                } catch (JSONException e) {
                                    e.printStackTrace();
                                }
                            }
                        }
                ).executeAsync();
            }

            @Override
            public void onCancel() {

            }

            @Override
            public void onError(FacebookException e) {

                //Toast.makeText(getParent(), e.toString(), Toast.LENGTH_LONG).show();
            }
        });
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_login, menu);
        return true;
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

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        cbm.onActivityResult(requestCode,resultCode,data);
    }
}
