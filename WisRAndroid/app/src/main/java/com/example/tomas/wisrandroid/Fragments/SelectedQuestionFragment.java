package com.example.tomas.wisrandroid.Fragments;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.content.LocalBroadcastManager;
import android.util.Base64;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.NumberPicker;
import android.widget.TextView;
import android.widget.Toast;

import com.android.volley.RequestQueue;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.Volley;
import com.example.tomas.wisrandroid.Helpers.HttpHelper;
import com.example.tomas.wisrandroid.Model.MultipleChoiceQuestion;
import com.example.tomas.wisrandroid.Model.Question;
import com.example.tomas.wisrandroid.Model.ResponseOption;
import com.example.tomas.wisrandroid.Model.TextualQuestion;
import com.example.tomas.wisrandroid.R;
import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonParser;

import java.io.ByteArrayInputStream;
import java.util.ArrayList;
import java.util.List;

public class SelectedQuestionFragment extends Fragment {

    // Current Question
    private Question mQuestion;
    private Bitmap mPicture;

    // TextView
    private TextView mDebugTextView;
    private TextView mQuestionTextView;

    // ImageView
    private ImageView mImageView;

    // NumberPicker used for boolean and multiplechoice quesitons
    private NumberPicker mNumberPicker;

    // Gson
    private final Gson gson = new Gson();

    public static SelectedQuestionFragment newInstance(int page, String title) {
        SelectedQuestionFragment mSelectedQuestionFragment = new SelectedQuestionFragment();

        return mSelectedQuestionFragment;
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_selected_question, container, false);
        mDebugTextView = (TextView) view.findViewById(R.id.selected_fragment_debugtextview);
        mQuestionTextView = (TextView) view.findViewById(R.id.selected_fragment_questiontextview);
        mImageView = (ImageView) view.findViewById(R.id.selected_fragment_imageview);
        mNumberPicker = (NumberPicker) view.findViewById(R.id.selected_fragment_numberpicker);
        Log.w("SelectedQuestion", "View Created");

        if (savedInstanceState != null)
        {
            String Question = savedInstanceState.getString("Question","");
            if(Question.contains("MultipleChoiceQuestion")) {
                mQuestion = gson.fromJson(Question, Question.class);
            }else {
                mQuestion = gson.fromJson(Question, Question.class);
            }
        }

        return view;
    }

    @Override
    public void onStart() {
        super.onStart();
    }

    @Override
    public void onResume() {
        super.onResume();
    }

    @Override
    public void onPause() {
        super.onPause();
    }

    public void setCurrentQuestion(Question currentQuestion)
    {
        mQuestion = currentQuestion;
        initView();
    }

    public void initView()
    {
        if(mQuestion.getClass().getName().equals(MultipleChoiceQuestion.class.toString().replace("class ", "")))
        {
            mDebugTextView.setText(gson.toJson(mQuestion));
            mQuestionTextView.setText(mQuestion.get_QuestionText());
            ArrayList<String> mResponses = new ArrayList<>();
            for( ResponseOption curString : mQuestion.get_ResponseOptions())
                mResponses.add(curString.get_value());
            String[] responses = new String[mResponses.size()];
            responses =  mResponses.toArray(responses);
            mNumberPicker.setMinValue(0);
            mNumberPicker.setMaxValue(responses.length-1);
            mNumberPicker.setDisplayedValues(responses);
        }else{
        }
        GetPicture();
    }

    @Override
    public void onSaveInstanceState(Bundle outState) {
        super.onSaveInstanceState(outState);
        outState.putString("Question", gson.toJson(mQuestion));
    }

    public void GetPicture()
    {
        Thread mThread = new Thread(new Runnable() {
            @Override
            public void run() {

                Response.Listener<String> mListener = new Response.Listener<String>() {
                    @Override
                    public void onResponse(String response) {

                        mQuestion.set_Img(response);
                        byte[] bytesDecoded = Base64.decode(response, Base64.DEFAULT);
                        mPicture = BitmapFactory.decodeByteArray(bytesDecoded, 0, bytesDecoded.length);
                        mImageView.setImageBitmap(mPicture);

                    }
                };

                Response.ErrorListener mErrorListener = new Response.ErrorListener() {
                    @Override
                    public void onErrorResponse(VolleyError volleyError) {
                        Toast.makeText(getContext(),String.valueOf(volleyError.networkResponse.statusCode),Toast.LENGTH_LONG).show();
                    }
                };

                RequestQueue requestQueue = Volley.newRequestQueue(getContext());
                HttpHelper jsObjRequest = new HttpHelper( getString(R.string.restapi_url) + "/Question/GetImageByQuestionId?questionId="+ mQuestion.get_Id(), null, mListener, mErrorListener);

                try {
                    requestQueue.add(jsObjRequest);
                } catch (Exception e) {

                }
            }
        });
        mThread.start();
    }
}

