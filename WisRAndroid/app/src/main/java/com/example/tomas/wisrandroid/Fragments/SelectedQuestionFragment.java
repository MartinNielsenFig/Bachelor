package com.example.tomas.wisrandroid.Fragments;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.content.LocalBroadcastManager;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;
import android.widget.Toast;

import com.android.volley.RequestQueue;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.Volley;
import com.example.tomas.wisrandroid.Helpers.HttpHelper;
import com.example.tomas.wisrandroid.Model.MultipleChoiceQuestion;
import com.example.tomas.wisrandroid.Model.Question;
import com.example.tomas.wisrandroid.Model.TextualQuestion;
import com.example.tomas.wisrandroid.R;
import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonParser;

public class SelectedQuestionFragment extends Fragment {

    private Question mQuestion;
    private BroadcastReceiver mBroadcastReceiver = null;
    private TextView mTextView;
    final Gson gson = new Gson();

    public static SelectedQuestionFragment newInstance(int page, String title) {
        SelectedQuestionFragment mSelectedQuestionFragment = new SelectedQuestionFragment();

        return mSelectedQuestionFragment;
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        // Setting up Broadcastreceiver for intercommunication between fragments
//        LocalBroadcastManager.getInstance(getActivity()).registerReceiver(mBroadcastReceiver, new IntentFilter("com.example.tomas.wisrandroid.QUESTION_EVENT"));
//        mBroadcastReceiver = new BroadcastReceiver() {
//            @Override
//            public void onReceive(Context context, Intent intent) {
//                Log.w("OnReceive", intent.getStringExtra("Question"));
//                String mResponse = intent.getStringExtra("Question");
//                Toast.makeText(getActivity(), mResponse, Toast.LENGTH_LONG).show();
//                if(mResponse.contains("MultipleChoiceQuestion")){
//                    MultipleChoiceQuestion mQuestion = gson.fromJson(mResponse, MultipleChoiceQuestion.class);
//                }else {
//                    TextualQuestion mQuestion = gson.fromJson(mResponse, TextualQuestion.class);
//                }
//            }
//        };
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_selected_question, container, false);
        mTextView = (TextView) view.findViewById(R.id.selected_fragment_textview);
        Log.w("SelectedQuestion", "View Created");
        return view;
    }

    @Override
    public void onStart() {
        super.onStart();
        LocalBroadcastManager.getInstance(getActivity()).registerReceiver(mBroadcastReceiver, new IntentFilter("com.example.tomas.wisrandroid.QUESTION_EVENT"));
    }

    @Override
    public void onPause() {
        super.onPause();
        LocalBroadcastManager.getInstance(getActivity()).unregisterReceiver(mBroadcastReceiver);
    }

    public void setCurrentQuestion(Question currentQuestion)
    {
        mQuestion = currentQuestion;
        if(currentQuestion.getClass().getName().equals(MultipleChoiceQuestion.class))
        {
            mTextView.setText(gson.toJson(mQuestion));
        }
        mTextView.setText(gson.toJson(mQuestion));

        Thread mThread = new Thread(new Runnable() {
            @Override
            public void run() {

                Response.Listener<String> mListener = new Response.Listener<String>() {
                    @Override
                    public void onResponse(String response) {

                        mQuestion.set_Img(response);

                    }
                };

                Response.ErrorListener mErrorListener = new Response.ErrorListener() {
                    @Override
                    public void onErrorResponse(VolleyError volleyError) {
                        Toast.makeText(getContext(),String.valueOf(volleyError.networkResponse.statusCode),Toast.LENGTH_LONG).show();
                    }
                };

                RequestQueue requestQueue = Volley.newRequestQueue(getContext());
                HttpHelper jsObjRequest = new HttpHelper( getString(R.string.restapi_url) + "/Question/GetImageByQuestionId?roomId="+ mQuestion.get_Id(), null, mListener, mErrorListener);

                try {
                    requestQueue.add(jsObjRequest);
                } catch (Exception e) {

                }
            }
        });
        mThread.start();
    }

}

