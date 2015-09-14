package com.example.tomas.wisrandroid.Activities;

import android.support.v7.app.ActionBarActivity;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

import com.android.volley.Request;
import com.android.volley.RequestQueue;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.Volley;
import com.example.tomas.wisrandroid.Helpers.ActivityLayoutHelper;
import com.example.tomas.wisrandroid.Helpers.HttpHelper;
import com.example.tomas.wisrandroid.Model.BooleanQuestion;
import com.example.tomas.wisrandroid.Model.Question;
import com.example.tomas.wisrandroid.R;
import com.google.gson.Gson;

import org.json.JSONObject;

import java.util.HashMap;
import java.util.Map;

public class QuestionActivity extends AppCompatActivity {

    Button mButton;
    TextView mTextView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_question);
        ActivityLayoutHelper.HideLayout(getWindow(), getSupportActionBar());



        mTextView = (TextView) findViewById(R.id.textview_ask_question);

        mButton = (Button) findViewById(R.id.button_ask_question);
        mButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                Map<String,String> mParams = new HashMap<String, String>();

                Question mQuestion = new BooleanQuestion("bent");
                mQuestion.set_CreatedById("Tomas");
                mQuestion.set_Downvotes(5);
                mQuestion.set_Id(null);
                mQuestion.set_Img("base64");
                mQuestion.set_Upvotes(5);
                mQuestion.set_QuestionText("SoQuestion");
                Gson gson = new Gson();

                String json = gson.toJson(mQuestion);

                mTextView.setText(json);

                mParams.put("question", json);
                mParams.put("roomId", "doge" );
                mParams.put("type","BooleanQuestion");

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

                RequestQueue requestQueue = Volley.newRequestQueue(QuestionActivity.this);
                HttpHelper jsObjRequest = new HttpHelper(Request.Method.POST, "http://10.0.2.2:1337/Question/CreateQuestion", mParams, mListener , mErrorListener);

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
        getMenuInflater().inflate(R.menu.menu_question, menu);
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
