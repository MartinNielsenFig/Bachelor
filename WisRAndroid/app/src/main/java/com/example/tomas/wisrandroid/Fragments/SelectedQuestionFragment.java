package com.example.tomas.wisrandroid.Fragments;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.graphics.Matrix;
import android.graphics.drawable.AnimationDrawable;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.content.LocalBroadcastManager;
import android.util.Base64;
import android.util.Log;
import android.view.Display;
import android.view.DragEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewTreeObserver;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.NumberPicker;
import android.widget.ProgressBar;
import android.widget.TextView;
import android.widget.Toast;

import com.android.volley.Request;
import com.android.volley.RequestQueue;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.Volley;
import com.example.tomas.wisrandroid.Activities.RoomActivity;
import com.example.tomas.wisrandroid.Helpers.HttpHelper;
import com.example.tomas.wisrandroid.Model.Answer;
import com.example.tomas.wisrandroid.Model.MultipleChoiceQuestion;
import com.example.tomas.wisrandroid.Model.MyUser;
import com.example.tomas.wisrandroid.Model.Question;
import com.example.tomas.wisrandroid.Model.ResponseOption;
import com.example.tomas.wisrandroid.Model.TextualQuestion;
import com.example.tomas.wisrandroid.Model.Vote;
import com.example.tomas.wisrandroid.R;
import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonParser;

import java.io.ByteArrayInputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class SelectedQuestionFragment extends Fragment {

    // Current Question
    private Question mQuestion;
    private Bitmap mPicture;

    // TextView
    private TextView mDebugTextView;
    private TextView mQuestionTextView;

    // ImageView
    private ImageView mImageView;
    private ProgressBar mProgressBar;

    // Buttons
    private Button mSendResponseButton;
    private Button mSeeResultButton;
    private ImageButton mDownVoteButton;
    private ImageButton mUpVoteButton;

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

        mQuestionTextView = (TextView) view.findViewById(R.id.selected_fragment_questiontextview);
        mImageView = (ImageView) view.findViewById(R.id.selected_fragment_imageview);
        mProgressBar = (ProgressBar) view.findViewById(R.id.progress);
        mNumberPicker = (NumberPicker) view.findViewById(R.id.selected_fragment_numberpicker);
        mNumberPicker.setDescendantFocusability(NumberPicker.FOCUS_BLOCK_DESCENDANTS);


        // Virker ikke skal nok lige kigges på igen
        mNumberPicker.setOnScrollListener(new NumberPicker.OnScrollListener() {
            @Override
            public void onScrollStateChange(NumberPicker numberPicker, int i) {
//                if (i == NumberPicker.OnScrollListener.SCROLL_STATE_IDLE)
//                {
//                    for (Answer answer : mQuestion.get_Result()) {
//                        if (answer.get_UserId() == MyUser.getMyuser().get_Id()) {
//                            int counter = 0;
//                            for (String responseoption : mNumberPicker.getDisplayedValues()) {
//                                if (responseoption == answer.get_Value()) {
//                                    EditText child = (EditText) mNumberPicker.getChildAt(counter);
//                                    child.setTextColor(Color.GREEN);
//                                }
//                                counter += 1;
//                            }
//                        }
//                    }
//                }
            }
        });

        mSendResponseButton = (Button) view.findViewById(R.id.selected_fragment_sendresponse_button);
        mSendResponseButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                SendResponse();
            }
        });
        mDownVoteButton = (ImageButton) view.findViewById(R.id.downvote_button);
        mDownVoteButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                DownVote();
            }
        });
        mUpVoteButton = (ImageButton) view.findViewById(R.id.upvote_button);
        mUpVoteButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                UpVote();
            }
        });
        mSeeResultButton = (Button) view.findViewById(R.id.selected_fragment_seeresult_button);
        mSeeResultButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {

            }
        });
        Log.w("SelectedQuestion", "View Created");

        return view;
    }

    @Override
    public void onStart() {
        super.onStart();
    }

    @Override
    public void onResume() {
        super.onResume();
        initView();
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
        if(mQuestion != null && mQuestion.getClass().getName().equals(MultipleChoiceQuestion.class.toString().replace("class ", "")))
        {
            mDownVoteButton.setEnabled(true);
            mUpVoteButton.setEnabled(true);
            //mDebugTextView.setText(gson.toJson(mQuestion));
            mQuestionTextView.setText(mQuestion.get_QuestionText());
            for (Vote vote : mQuestion.get_Votes())
            {
                if (vote.get_createdById() == MyUser.getMyuser().get_Id())
                {
                    if(vote.get_value() == -1)
                    {
                        mDownVoteButton.setEnabled(false);
                    }
                    else
                    {
                        mUpVoteButton.setEnabled(false);
                    }
                }
            }
            ArrayList<String> mResponses = new ArrayList<>();
            for( ResponseOption curString : mQuestion.get_ResponseOptions())
                mResponses.add(curString.get_value());
            String[] responses = new String[mResponses.size()];
            responses =  mResponses.toArray(responses);
            mNumberPicker.setMinValue(0);
            if(responses.length > 0)
            {
                mNumberPicker.setMaxValue(responses.length-1);
                mNumberPicker.setDisplayedValues(responses);
                mNumberPicker.setEnabled(true);
            }else
            {
                String[] noResponse = new String[1];
                noResponse[0] = "No Answers";
                mNumberPicker.setMaxValue(0);
                mNumberPicker.setDisplayedValues(noResponse);
                mNumberPicker.setEnabled(false);
            }
            GetPicture();


        }else{
        }

    }

    @Override
    public void onSaveInstanceState(Bundle outState) {
        super.onSaveInstanceState(outState);
        outState.putString("Question", gson.toJson(mQuestion));
    }

    public void GetPicture()
    {
        if(mQuestion.get_Img() == null) {
            mProgressBar.setVisibility(View.VISIBLE);
            Response.Listener<String> mListener = new Response.Listener<String>() {
                @Override
                public void onResponse(String response) {
                    if (!response.isEmpty()) {
                        mQuestion.set_Img(response);
                        mImageView.setImageBitmap(DecodeImage(mQuestion.get_Img()));
                        mProgressBar.setVisibility(View.INVISIBLE);
                        mPicture = null;
                    } else {
                        mImageView.setImageResource(R.mipmap.ic_noimage);
                        mProgressBar.setVisibility(View.INVISIBLE);
                    }

                }
            };

            Response.ErrorListener mErrorListener = new Response.ErrorListener() {
                @Override
                public void onErrorResponse(VolleyError volleyError) {
                    Toast.makeText(getContext(), String.valueOf(volleyError.networkResponse.statusCode), Toast.LENGTH_LONG).show();
                }
            };

            RequestQueue requestQueue = Volley.newRequestQueue(getContext());
            HttpHelper jsObjRequest = new HttpHelper(getString(R.string.restapi_url) + "/Question/GetImageByQuestionId?questionId=" + mQuestion.get_Id(), null, mListener, mErrorListener);

            try {
                requestQueue.add(jsObjRequest);
            } catch (Exception e) {

            }
        }else{
            mImageView.setImageBitmap(DecodeImage(mQuestion.get_Img()));
            //mPicture.recycle();
        }

    }

    private Bitmap DecodeImage(String Image)
    {
        // Getting width of the current display
        Display display = ((RoomActivity)getActivity()).getWindowManager().getDefaultDisplay();
        int width = display.getWidth();

        // Getting width of the current picture
        BitmapFactory.Options bitmapOptions = new BitmapFactory.Options();
        bitmapOptions.inJustDecodeBounds = true;
        byte[] bytesDecoded = Base64.decode(Image, Base64.DEFAULT);
        BitmapFactory.decodeByteArray(bytesDecoded, 0, bytesDecoded.length, bitmapOptions);

        // Calculating scaling factor to compress the picture to desired size
        if (bitmapOptions.outWidth > width) {
            bitmapOptions.inSampleSize = (bitmapOptions.outWidth / width) + 2;
        }
        bitmapOptions.inJustDecodeBounds = false;
        mPicture = BitmapFactory.decodeByteArray(bytesDecoded, 0, bytesDecoded.length,bitmapOptions);



        return mPicture;
    }

    private void SendResponse()
    {
        Map<String,String> mParams = new HashMap<String, String>();
        final Answer mAnswer = new Answer(mNumberPicker.getDisplayedValues()[mNumberPicker.getValue()], MyUser.getMyuser().get_Id());
        mParams.put("response",gson.toJson(mAnswer));
        mParams.put("questionId", mQuestion.get_Id());

        Response.Listener<String> mListener = new Response.Listener<String>() {
            @Override
            public void onResponse(String response) {
                int whatisvalue = mNumberPicker.getValue();
                if (response.isEmpty())
                {
                    //mQuestion.get_Result().add(mAnswer);
                    //EditText child = ((EditText) mNumberPicker.getChildAt(mNumberPicker.getValue()));
                    //child.setTextColor(Color.GREEN);
                }
                Toast.makeText(getContext(),response,Toast.LENGTH_LONG).show();
            }
        };

        Response.ErrorListener mErrorListener = new Response.ErrorListener() {
            @Override
            public void onErrorResponse(VolleyError volleyError) {
                Toast.makeText(getContext(),String.valueOf(volleyError.networkResponse.statusCode),Toast.LENGTH_LONG).show();
            }
        };

        RequestQueue requestQueue = Volley.newRequestQueue(getContext());
        HttpHelper jsObjRequest = new HttpHelper( Request.Method.POST, getString(R.string.restapi_url) + "/Question/AddQuestionResponse"  , mParams, mListener, mErrorListener);

        try {
            requestQueue.add(jsObjRequest);
        } catch (Exception e) {

        }
    }

    private void DownVote()
    {
        int entryFound = -1;
        for (Vote vote : mQuestion.get_Votes())
        {
            if(vote.get_createdById() == MyUser.getMyuser().get_Id())
            {
                entryFound = 1;
                vote.set_value(-1);

                Map<String,String> mParams = new HashMap<String, String>();
                mParams.put("vote",gson.toJson(vote));
                mParams.put("type", mQuestion.getClass().getName());
                mParams.put("id", mQuestion.get_Id());


                Response.Listener<String> mListener = new Response.Listener<String>() {
                    @Override
                    public void onResponse(String response) {
                        Toast.makeText(getContext(),response,Toast.LENGTH_LONG).show();
                        mUpVoteButton.setEnabled(true);
                        mDownVoteButton.setEnabled(false);
                    }
                };

                Response.ErrorListener mErrorListener = new Response.ErrorListener() {
                    @Override
                    public void onErrorResponse(VolleyError volleyError) {
                        Toast.makeText(getContext(),String.valueOf(volleyError.networkResponse.statusCode),Toast.LENGTH_LONG).show();
                    }
                };

                RequestQueue requestQueue = Volley.newRequestQueue(getContext());
                HttpHelper jsObjRequest = new HttpHelper( Request.Method.POST, getString(R.string.restapi_url) + "/Question/AddVote"  , mParams, mListener, mErrorListener);

                try {
                    requestQueue.add(jsObjRequest);
                } catch (Exception e) {

                }
                break;
            }
        }

        if(entryFound == -1)
        {
            Vote mVote = new Vote(MyUser.getMyuser().get_Id(),-1);

            Map<String,String> mParams = new HashMap<String, String>();
            mParams.put("vote",gson.toJson(mVote));
            mParams.put("type", mQuestion.getClass().getName());
            mParams.put("id", mQuestion.get_Id());


            Response.Listener<String> mListener = new Response.Listener<String>() {
                @Override
                public void onResponse(String response) {
                    Toast.makeText(getContext(),response,Toast.LENGTH_LONG).show();
                    mUpVoteButton.setEnabled(true);
                    mDownVoteButton.setEnabled(false);
                }
            };

            Response.ErrorListener mErrorListener = new Response.ErrorListener() {
                @Override
                public void onErrorResponse(VolleyError volleyError) {
                    Toast.makeText(getContext(),String.valueOf(volleyError.networkResponse.statusCode),Toast.LENGTH_LONG).show();
                }
            };

            RequestQueue requestQueue = Volley.newRequestQueue(getContext());
            HttpHelper jsObjRequest = new HttpHelper( Request.Method.POST, getString(R.string.restapi_url) + "/Question/AddVote"  , mParams, mListener, mErrorListener);

            try {
                requestQueue.add(jsObjRequest);
            } catch (Exception e) {

            }
        }
    }

    private void UpVote()
    {
        int entryFound = -1;
        for (Vote vote : mQuestion.get_Votes())
        {
            if(vote.get_createdById() == MyUser.getMyuser().get_Id())
            {
                entryFound = 1;
                vote.set_value(1);

                Map<String,String> mParams = new HashMap<String, String>();
                mParams.put("vote",gson.toJson(vote));
                mParams.put("type", mQuestion.getClass().getName());
                mParams.put("id", mQuestion.get_Id());


                Response.Listener<String> mListener = new Response.Listener<String>() {
                    @Override
                    public void onResponse(String response) {
                        Toast.makeText(getContext(),response,Toast.LENGTH_LONG).show();
                        mDownVoteButton.setEnabled(true);
                        mUpVoteButton.setEnabled(false);
                    }
                };

                Response.ErrorListener mErrorListener = new Response.ErrorListener() {
                    @Override
                    public void onErrorResponse(VolleyError volleyError) {
                        Toast.makeText(getContext(),String.valueOf(volleyError.networkResponse.statusCode),Toast.LENGTH_LONG).show();
                    }
                };

                RequestQueue requestQueue = Volley.newRequestQueue(getContext());
                HttpHelper jsObjRequest = new HttpHelper( Request.Method.POST, getString(R.string.restapi_url) + "/Question/AddVote"  , mParams, mListener, mErrorListener);

                try {
                    requestQueue.add(jsObjRequest);
                } catch (Exception e) {

                }
                break;
            }
        }
        if(entryFound == -1)
        {
            Vote mVote = new Vote(MyUser.getMyuser().get_Id(),1);

            Map<String,String> mParams = new HashMap<String, String>();
            mParams.put("vote",gson.toJson(mVote));
            mParams.put("type", mQuestion.getClass().getName());
            mParams.put("id", mQuestion.get_Id());

            Response.Listener<String> mListener = new Response.Listener<String>() {
                @Override
                public void onResponse(String response) {
                    Toast.makeText(getContext(),response,Toast.LENGTH_LONG).show();
                    mDownVoteButton.setEnabled(true);
                    mUpVoteButton.setEnabled(false);

                }
            };

            Response.ErrorListener mErrorListener = new Response.ErrorListener() {
                @Override
                public void onErrorResponse(VolleyError volleyError) {
                    Toast.makeText(getContext(),String.valueOf(volleyError.networkResponse.statusCode),Toast.LENGTH_LONG).show();
                }
            };

            RequestQueue requestQueue = Volley.newRequestQueue(getContext());
            HttpHelper jsObjRequest = new HttpHelper( Request.Method.POST, getString(R.string.restapi_url) + "/Question/AddVote"  , mParams, mListener, mErrorListener);

            try {
                requestQueue.add(jsObjRequest);
            } catch (Exception e) {

            }
        }
    }

    public void ClearImage()
    {
        mImageView.setImageBitmap(null);
    }

}

