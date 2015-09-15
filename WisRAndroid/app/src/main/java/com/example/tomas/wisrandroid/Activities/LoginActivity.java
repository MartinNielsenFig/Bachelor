package com.example.tomas.wisrandroid.Activities;

import android.content.Intent;
import android.support.v7.app.ActionBarActivity;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.widget.Toast;

import com.example.tomas.wisrandroid.Helpers.ActivityLayoutHelper;
import com.example.tomas.wisrandroid.Model.MyUser;
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
import com.facebook.login.widget.LoginButton;
import com.google.gson.Gson;

import org.json.JSONException;

public class LoginActivity extends AppCompatActivity {

    CallbackManager cbm;
    LoginButton lb;
    //LoginManager lm;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_login);
        ActivityLayoutHelper.HideLayout(getWindow(), getSupportActionBar());

        final Gson gson = new Gson();
        cbm = CallbackManager.Factory.create();

        //lb = (LoginButton) findViewById(R.id.authButton);

        LoginManager.getInstance().registerCallback(cbm, new FacebookCallback<LoginResult>() {
            @Override
            public void onSuccess(LoginResult loginResult) {

                MyUser.getMyuser().set_FacebookId(loginResult.getAccessToken().getUserId());

                /* make the API call */
                new GraphRequest(
                        AccessToken.getCurrentAccessToken(),
                        "/me",
                        null,
                        HttpMethod.GET,
                        new GraphRequest.Callback() {
                            public void onCompleted(GraphResponse response) {
                                try {
                                    Toast.makeText(getApplicationContext(), response.getRawResponse(), Toast.LENGTH_LONG);
                                    MyUser.getMyuser().set_DisplayName(response.getJSONObject().getString("name"));
                                    Log.w("NameVariableOfResponse", response.getJSONObject().getString("name"));
                                } catch (JSONException e) {
                                    e.printStackTrace();
                                }
                            }
                        }
                ).executeAsync();



//                Map<String,String> mParams = new HashMap<String, String>();
//
//
//                String json = gson.toJson(MyUser.getMyuser().get_FacebookId());
//
//                RequestQueue requestQueue = Volley.newRequestQueue(LoginActivity.this);
//                HttpHelper jsObjRequest = new HttpHelper(Request.Method.GET, "http://10.0.2.2:1337/User/CreateUser", mParams, mListener , mErrorListener);
//
//                try {
//                    requestQueue.add(jsObjRequest);
//                }
//                catch (Exception e){
//
//                }

            }

            @Override
            public void onCancel() {

            }

            @Override
            public void onError(FacebookException e) {

                Toast.makeText(getParent(), e.toString() ,Toast.LENGTH_LONG).show();
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
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        cbm.onActivityResult(requestCode,resultCode,data);
    }

//    Response.Listener<JSONObject> mListener = new Response.Listener<JSONObject>() {
//        @Override
//        public void onResponse(JSONObject jsonObject) {
//            String response = null;
//            try {
//                MyUser.getMyuser().set_Id(jsonObject.getString("Id"));
//                //MyUser.getMyuser().set;
//            } catch (JSONException e) {
//                e.printStackTrace();
//            }
//        }
//    };
//
//    Response.ErrorListener mErrorListener = new Response.ErrorListener() {
//        @Override
//        public void onErrorResponse(VolleyError volleyError) {
//        }
//    };
}
